local configs = require("reti-debugger.configs")
local windows = require("reti-debugger.windows")
local actions = require("reti-debugger.actions")
local state = require("reti-debugger.state")

local M = {}

local function save_state()
	state.bufnr_on_leaving = vim.api.nvim_get_current_buf()
	state.winid_on_leaving = vim.api.nvim_get_current_win()
end

local function set_pipes()
	state.stdin = vim.loop.new_pipe(false)
	state.stdout = vim.loop.new_pipe(false)
	state.stderr = vim.loop.new_pipe(false)
end

local function start_interpreter()
	state.handle, state.interpreter_id = vim.loop.spawn("picoc_compiler", {
		args = { "-E", "reti", "-P" },
		stdio = { state.stdin, state.stdout, state.stderr },
	}, function(code, signal)
		state.delta_actions("complete")
		vim.loop.shutdown(state.stdin, function(err)
			assert(not err, err)
			vim.loop.close(state.handle, function() end)
		end)
		print("Interpreter terminated with exit code " .. code .. " and signal " .. signal)
	end)
end

local function set_window_options()
	vim.api.nvim_win_set_option(windows.popups.sram1.winid, "scrolloff", 999)

	actions.apply_scrolling_mode_to_windows()
	state.timer = vim.loop.new_timer()
	state.timer:start(
		1000,
		1000,
		vim.schedule_wrap(function()
			local width = vim.api.nvim_get_option("columns")
			local height = vim.api.nvim_get_option("lines")
			if state.width == width and state.height == height or not state.delta_actions("layout") then
				return
			end
			state.width = width
			state.height = height
			windows.layout:update({
				size = {
					width = width,
					height = height,
				},
			})
			actions.apply_scrolling_mode_to_windows()
		end)
	)
end

local function set_keybindings()
	for _, popup in pairs(windows.popups) do
		vim.keymap.set(
			"n",
			state.opts.keys.next,
			actions.next,
			{ buffer = popup.bufnr, silent = true, desc = "Next instruction" }
		)
		vim.keymap.set(
			"n",
			state.opts.keys.switch_window,
			actions.switch_windows,
			{ buffer = popup.bufnr, silent = true, desc = "Switch windows" }
		)
		vim.keymap.set("n", state.opts.keys.switch_window_backwards, function()
			actions.switch_windows(true)
		end, { buffer = popup.bufnr, silent = true, desc = "Switch windows backward" })
		vim.keymap.set("n", state.opts.keys.switch_mode, function()
			state.delta_actions("popup appears")
			windows.menu_modes:mount()
		end, { buffer = popup.bufnr, silent = true, desc = "Menu to switch mode" })
		vim.keymap.set("n", state.opts.keys.focus_memory, function()
			state.first_focus_over = false
			actions.memory_visible()
		end, { buffer = popup.bufnr, silent = true, desc = "Focus memory" })
		vim.keymap.set(
			"n",
			state.opts.keys.restart,
			M.restart,
			{ buffer = popup.bufnr, silent = true, desc = "Restart RETI-Debugger" }
		)
		vim.keymap.set(
			"n",
			state.opts.keys.quit,
			actions.quit,
			{ buffer = popup.bufnr, silent = true, desc = "Quit RETI-Debugger" }
		)
	end
	if state.opts.keys.hide then
		vim.keymap.set(
			"n",
			state.opts.keys.hide,
			actions.hide_toggle,
			{ silent = true, desc = "Hide RETI-Debugger layout" }
		)
	end
end

local function set_global_keybindings()
	if state.opts.keys.load_example then
		vim.keymap.set(
			"n",
			state.opts.keys.load_example,
			":LoadPicoCExample<cr>",
			{ silent = true, desc = "Load an example PicoC program" }
		)
	end
	if state.opts.keys.compile then
		vim.keymap.set(
			"n",
			state.opts.keys.compile,
			actions.compile,
			{ silent = true, desc = "Compile from PicoC to RETI" }
		)
	end
	if state.opts.keys.start then
		vim.keymap.set("n", state.opts.keys.start, M.start, { silent = true, desc = "Start RETI-Debugger" })
	end
end

local function set_commands()
	vim.api.nvim_create_user_command(
		"LoadPicoCExample",
		actions.load_example,
		{ desc = "Load an example PicoC program", nargs = "?" }
	)
	vim.api.nvim_create_user_command("CompilePicoCBuffer", actions.compile, { desc = "Compile from PicoC to RETI" })
	vim.api.nvim_create_user_command("StartRETIBuffer", M.start, { desc = "Start RETI-Debugger" })
end

function M.setup(opts)
	state.opts = vim.tbl_deep_extend("keep", opts, configs)

	set_commands()
	set_global_keybindings()
end

function M.start()
	if not state.delta_actions("start") then
		return
	end
	state.delta_focus("start")
	save_state()
	set_pipes()
	start_interpreter()
	actions.init_buffer()
	windows.layout:mount()
	set_window_options()
	set_keybindings()
end

function M.restart()
	if not state.delta_actions("restart") then
		return
	end
	actions.quit()
	vim.api.nvim_set_current_win(state.winid_on_leaving)
	if not (state.bufnr_on_leaving == vim.api.nvim_get_current_buf()) then
		print("Can't restart, window from which code was taken doesn't have the same buffer anymore.")
		return
	end
	if not vim.wait(5000, function()
		return state.interpreter_terminated
	end) then
		return
	end
	M.start()
end

return M
