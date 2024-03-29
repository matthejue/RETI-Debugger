local windows = require("reti-debugger.windows")
local utils = require("reti-debugger.utils")
local state = require("reti-debugger.state")

local M = {}

-- ┌────────────────────────┐
-- │ Keybindings and events │
-- └────────────────────────┘
-- to prevent window closing immediately after opening in autoscrolling mode
M.autoscrolling_over = false

local function set_layout_events_and_keybindings(popup)
	M.autoscrolling_over = false
	popup:on("BufLeave", function()
		if not M.autoscrolling_over then
			return
		end
		popup:unmount()
		state.delta_actions("popup closed")
	end, { once = true })

	vim.keymap.set("n", state.opts.keys.quit, function()
		popup:unmount()
		state.delta_actions("popup closed")
	end, { buffer = popup.bufnr, silent = true })
	vim.keymap.set("n", "<cr>", function()
		popup:unmount()
		state.delta_actions("popup closed")
	end, { buffer = popup.bufnr, silent = true })
	vim.keymap.set("n", "<esc>", function()
		popup:unmount()
		state.delta_actions("popup closed")
	end, { buffer = popup.bufnr, silent = true })
	-- else it is annoying to get an error message for failed to find pattern when suddently walking into a print call instruction
	vim.keymap.set("n", state.opts.keys.next, "", { buffer = popup.bufnr, silent = true })
end

-- ┌────────────────────────┐
-- │ Scrolling and focusing │
-- └────────────────────────┘
local function set_no_scrollbind()
	vim.api.nvim_win_set_option(windows.popups.sram1.winid, "scrollbind", false)
	vim.api.nvim_win_set_option(windows.popups.sram2.winid, "scrollbind", false)
	vim.api.nvim_win_set_option(windows.popups.sram3.winid, "scrollbind", false)
end

local function set_scrollbind(one_and_two, two_and_three)
	if one_and_two and two_and_three then
		vim.api.nvim_win_set_option(windows.popups.sram1.winid, "scrollbind", true)
		vim.api.nvim_win_set_option(windows.popups.sram2.winid, "scrollbind", true)
		vim.api.nvim_win_set_option(windows.popups.sram3.winid, "scrollbind", true)
	elseif one_and_two then
		vim.api.nvim_win_set_option(windows.popups.sram1.winid, "scrollbind", true)
		vim.api.nvim_win_set_option(windows.popups.sram2.winid, "scrollbind", true)
	elseif two_and_three then
		vim.api.nvim_win_set_option(windows.popups.sram2.winid, "scrollbind", true)
		vim.api.nvim_win_set_option(windows.popups.sram3.winid, "scrollbind", true)
	end
end

local function scroll_windows(bfline, buf_height)
	set_no_scrollbind()

	vim.api.nvim_win_set_cursor(windows.popups.sram1.winid, { bfline + 1, 0 })
	vim.api.nvim_set_current_win(windows.popups.sram1.winid)
	local win1_end = vim.fn.line("w$", windows.popups.sram1.winid)

	vim.api.nvim_win_set_cursor(
		windows.popups.sram2.winid,
		{ win1_end + 1 <= buf_height and win1_end + 1 or buf_height, 0 }
	)
	vim.api.nvim_set_current_win(windows.popups.sram2.winid)
	vim.cmd("normal! zt")
	local win2_end = vim.fn.line("w$", windows.popups.sram2.winid)

	vim.api.nvim_win_set_cursor(
		windows.popups.sram3.winid,
		{ win2_end + 1 <= buf_height and win2_end + 1 or buf_height, 0 }
	)
	vim.api.nvim_set_current_win(windows.popups.sram3.winid)
	vim.cmd("normal! zt")

	set_scrollbind(win1_end + 1 <= buf_height, win2_end + 1 <= buf_height)
end

local function autoscrolling()
	local pc_address = tonumber(string.match(state.registers, "PC: *(%d+)"))
	local buf_height = vim.api.nvim_buf_line_count(windows.popups.sram1.bufnr)
	if pc_address >= 2 ^ 31 then -- sram
		local bfline = pc_address - 2 ^ 31
		scroll_windows(bfline, buf_height)
	else -- uart and eprom
		local win_height = vim.api.nvim_win_get_height(windows.popups.sram1.winid)
		scroll_windows(math.floor(win_height / 2), buf_height)
	end
end

function M.memory_visible()
	local pc_address = tonumber(string.match(state.registers, "PC: *(%d+)"))

	if pc_address >= 2 ^ 31 then -- sram
		local bfline = pc_address - 2 ^ 31
		vim.api.nvim_win_set_cursor(windows.popups.sram1.winid, { bfline + 1, 0 })
	else -- uart and eprom
		local win_height = vim.api.nvim_win_get_height(windows.popups.sram1.winid)
		local buf_height = vim.api.nvim_buf_line_count(windows.popups.sram1.bufnr)
		vim.api.nvim_win_set_cursor(windows.popups.sram1.winid, { math.min(math.floor(win_height / 2), buf_height), 0 })
	end

	if not state.delta_focus("first focus") then
		return
	end

	local start_datasegment = tonumber(string.match(state.eprom, "ADDI DS (%d+)"))
	local buf_height = vim.api.nvim_buf_line_count(windows.popups.sram1.bufnr)

	vim.api.nvim_win_set_cursor(windows.popups.sram2.winid, { start_datasegment + 1, 0 })
	vim.api.nvim_set_current_win(windows.popups.sram2.winid)
	vim.cmd("normal! zt")

	vim.api.nvim_win_set_cursor(windows.popups.sram3.winid, { buf_height, 0 })
	vim.api.nvim_set_current_win(windows.popups.sram3.winid)
	vim.cmd("normal! zb")

	state.first_focus_over = true
end

-- ┌─────────────────────────────────────────┐
-- │ Dealing with errors, inputs and outputs │
-- └─────────────────────────────────────────┘

local function display_error(data)
	state.delta_actions("popup appears")
	windows.error_window:mount()
	vim.api.nvim_buf_set_lines(windows.error_window.bufnr, 0, -1, false, utils.elements_in_range(utils.split(data), 2))
	set_layout_events_and_keybindings(windows.error_window)
end

local function display_output(data)
	state.delta_actions("popup appears")
	windows.output_window:mount()
	local val = string.match(data, "Output: (%-?%d*)")
	vim.api.nvim_buf_set_lines(windows.output_window.bufnr, 0, -1, false, { val })
	set_layout_events_and_keybindings(windows.output_window)
end

local function ask_for_input()
	state.delta_actions("popup appears")
	windows.input_window:mount()
end

local function check_for_previous_outputs(data)
	if string.match(data, "Error") then
		display_error(data)
		return
	elseif string.match(data, "Output:") then
		display_output(data)
		return utils.elements_in_range(utils.split(data), 2)
	elseif string.match(data, "Input:") then
		ask_for_input()
    windows.current_window = windows.current_window - 1
		return
	end
	return utils.split(data)
end

-- ┌───────────────────────────────────────────┐
-- │ Read buffer content and acknowledge chain │
-- └───────────────────────────────────────────┘
M.left_window = nil
M.current_window = 1

local function update_window()
	vim.loop.read_start(
		state.stdout,
		vim.schedule_wrap(function(err, data)
			assert(not err, err)
			if data then
				windows.current_window = windows.current_window + 1

				if windows.popups_order[windows.current_window] == "registers" then
					state.registers = data
					data = check_for_previous_outputs(data)
					if not data then
						return
					end
        elseif windows.popups_order[windows.current_window] == "eprom" then
					state.eprom = data
					data = utils.split(data)
				elseif windows.popups_order[windows.current_window] == "sram1" then
					local content = utils.split(data)
					vim.api.nvim_buf_set_lines(windows.popups.sram1.bufnr, 0, -1, true, content)
					vim.api.nvim_buf_set_lines(windows.popups.sram2.bufnr, 0, -1, true, content)
					vim.api.nvim_buf_set_lines(windows.popups.sram3.bufnr, 0, -1, true, content)

					-- ignore Cursor position outside buffer error because of a bug in Neovim API
					M.left_window = vim.api.nvim_get_current_win()
					if state.scrolling_mode == state.scrolling_modes.autoscrolling then
						pcall(autoscrolling)
					else
						M.memory_visible()
					end
					vim.api.nvim_set_current_win(M.left_window)
					M.autoscrolling_over = true
					return
				else
					data = utils.split(data)
				end

				vim.api.nvim_buf_set_lines(
					windows.popups[windows.popups_order[windows.current_window]].bufnr,
					0,
					-1,
					true,
					data
				)
				vim.loop.write(state.stdin, "ack\n")
			end
		end)
	)
end

-- ┌───────────────────────┐
-- │ Functions for keymaps │
-- └───────────────────────┘
function M.init_buffer()
	windows.current_window = 0

	local bfcontent = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
	bfcontent = bfcontent:gsub("\n", string.char(30))

	vim.loop.write(state.stdin, bfcontent .. "\n")
	update_window()
end

local function next_cycle()
	windows.current_window = 0

	vim.loop.write(state.stdin, "next \n")
	update_window()
end

function M.next()
	if not state.delta_actions("next") then
		return
	end
	next_cycle()
end

function M.switch_windows(backward)
	backward = backward or false

	if backward then
		windows.current_popup = windows.current_popup - 1 >= 1 and windows.current_popup - 1 or #windows.popups_order
	else
		windows.current_popup = windows.current_popup + 1 <= #windows.popups_order and windows.current_popup + 1 or 1
	end
	vim.api.nvim_set_current_win(windows.popups[windows.popups_order[windows.current_popup]].winid)
end

function M.apply_scrolling_mode_to_windows()
	if state.scrolling_mode == state.scrolling_modes.autoscrolling then
		windows.window_titles_autoscrolling()
	else
		windows.window_titles_memory_focus()
	end
end

function M.hide_toggle()
	if state.delta_actions("hide") then
		windows.layout:hide()
	elseif state.delta_actions("show") then
		windows.layout:show()
    M.apply_scrolling_mode_to_windows()
		vim.api.nvim_set_current_win(windows.popups[windows.popups_order[windows.current_popup]].winid)
		vim.api.nvim_win_set_option(windows.popups.sram1.winid, "scrolloff", 999)
	end
end

local function del_keybindings()
	if state.opts.keys.hide then
		vim.keymap.del("n", state.opts.keys.hide)
	end
end

function M.quit()
	if not state.delta_actions("quit") then
		return
	end
  windows.layout:unmount()
  del_keybindings()
  state.timer:close()
	if not state.interpreter_terminated then
		vim.loop.kill(state.interpreter_id, "sigterm")
	else
	end
end

-- ┌────────────────────────┐
-- │ Functions for commands │
-- └────────────────────────┘

function M.load_example(tbl)
  if not state.delta_actions("load") then
    return
  end
	state.async_event = vim.loop.new_async(vim.schedule_wrap(function()
		local script_path = debug.getinfo(1, "S").source:sub(2)
		local plugin_path = script_path:match("(.*)/lua/reti%-debugger/actions%.lua")

		local bufnr = vim.api.nvim_create_buf(false, true)

		local exampltbl = {
			[1] = "bsearch_it.picoc",
			[2] = "bsearch_rec.picoc",
			[3] = "bubble_sort.picoc",
			[4] = "exercise_from_sheets1.picoc",
			[5] = "exercise_from_sheets2.picoc",
			[6] = "exercise_from_sheets3.picoc",
			[7] = "exercise_from_sheets4.picoc",
			[8] = "exercise_from_sheets5.picoc",
			[9] = "exercise_from_sheets6.picoc",
			[10] = "faculty_it.picoc",
			[11] = "faculty_rec.picoc",
			[12] = "fib_it.picoc",
			[13] = "fib_rec.picoc",
			[14] = "fib_rec_efficient.picoc",
			[15] = "gcd.picoc",
			[16] = "log2.picoc",
			[17] = "min_sort.picoc",
			[18] = "pair_sort.picoc",
			[19] = "pair_sort2.picoc",
			[20] = "power_it.picoc",
			[21] = "power_it_efficient.picoc",
			[22] = "power_rec.picoc",
			[23] = "power_rec_efficient.picoc",
			[24] = "prime_numbers.picoc",
			[25] = "simple_input_output.picoc",
		}

		print(exampltbl[tbl.args ~= "" and tonumber(tbl.args) or windows.example] .. " choosen")
		vim.loop.fs_open(
			plugin_path .. "/examples/" .. exampltbl[tbl.args ~= "" and tonumber(tbl.args) or windows.example],
			"r",
			438,
			function(err, fd)
				assert(not err, err)
				vim.loop.fs_fstat(fd, function(err, stat)
					assert(not err, err)
					vim.loop.fs_read(
						fd,
						stat.size,
						0,
						vim.schedule_wrap(function(err, data)
							assert(not err, err)
							vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, utils.split(data))
							vim.api.nvim_set_current_buf(bufnr)
							vim.loop.fs_close(fd, function(err)
								assert(not err, err)
							end)
						end)
					)
				end)
			end
		)
	end))

	if tbl.args == "" then
		state.delta_actions("popup appears")
		windows.menu_examples:mount()
		return
	end
	vim.loop.async_send(state.async_event)
end

local function run_compiler()
	state.handle, state.interpreter_id = vim.loop.spawn("picoc_compiler", {
		args = { "-E", "picoc", "-P", "-p", "-v" },
		stdio = { state.stdin, state.stdout, state.stderr },
	}, function(code, signal)
		vim.loop.shutdown(state.stdin, function(err)
			assert(not err, err)
			vim.loop.close(state.handle, function() end)
		end)
		print("Compiler terminated with exit code " .. code .. " and signal " .. signal)
	end)

	local bfcontent = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
	bfcontent = bfcontent:gsub("\n", string.char(30))
	vim.loop.write(state.stdin, bfcontent .. "\n")

	vim.loop.read_start(
		state.stdout,
		vim.schedule_wrap(function(err, data)
			assert(not err, err)
			if data then
				if string.match(data, "Error") then
					display_error(data)
					return
				end

				local bufnr = vim.api.nvim_create_buf(false, true)
				vim.api.nvim_set_current_buf(bufnr)
				vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, utils.elements_in_range(utils.split(data), 2))
				vim.loop.read_stop(state.stdout)
			end
		end)
	)
end

function M.compile()
  if not state.delta_actions("compile") then
    return
  end
	state.stdin = vim.loop.new_pipe(false)
	state.stdout = vim.loop.new_pipe(false)
	state.stderr = vim.loop.new_pipe(false)
	run_compiler()
end

return M
