local windows = require("reti-debugger.windows")
local utils = require("reti-debugger.utils")
local global_vars = require("reti-debugger.global_vars")
local event = require("nui.utils.autocmd").event

local M = {}

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

  vim.api.nvim_win_set_cursor(windows.popups.sram2.winid,
    { win1_end + 1 <= buf_height and win1_end + 1 or buf_height, 0 })
  vim.api.nvim_set_current_win(windows.popups.sram2.winid)
  vim.cmd("normal! zt")
  local win2_end = vim.fn.line("w$", windows.popups.sram2.winid)

  vim.api.nvim_win_set_cursor(windows.popups.sram3.winid,
    { win2_end + 1 <= buf_height and win2_end + 1 or buf_height, 0 })
  vim.api.nvim_set_current_win(windows.popups.sram3.winid)
  vim.cmd("normal! zt")

  set_scrollbind(win1_end + 1 <= buf_height, win2_end + 1 <= buf_height)
end

local function autoscrolling()
  local pc_address = tonumber(string.match(global_vars.registers, "PC: *(%d+)"))
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
  local pc_address = tonumber(string.match(global_vars.registers, "PC: *(%d+)"))

  if pc_address >= 2 ^ 31 then -- sram
    local bfline = pc_address - 2 ^ 31
    vim.api.nvim_win_set_cursor(windows.popups.sram1.winid, { bfline + 1, 0 })
  else -- uart and eprom
    local win_height = vim.api.nvim_win_get_height(windows.popups.sram1.winid)
    vim.api.nvim_win_set_cursor(windows.popups.sram1.winid, { math.floor(win_height / 2), 0 })
  end

  if global_vars.first_focus_over then
    return
  end

  local start_datasegment = tonumber(string.match(global_vars.eprom, "ADDI DS (%d+)"))
  local buf_height = vim.api.nvim_buf_line_count(windows.popups.sram1.bufnr)

  vim.api.nvim_win_set_cursor(windows.popups.sram2.winid, { start_datasegment + 1, 0 })
  vim.api.nvim_set_current_win(windows.popups.sram2.winid)
  vim.cmd("normal! zt")

  vim.api.nvim_win_set_cursor(windows.popups.sram3.winid, { buf_height, 0 })
  vim.api.nvim_set_current_win(windows.popups.sram3.winid)
  vim.cmd("normal! zb")

  global_vars.first_focus_over = true
end

-- ┌─────────────────────────────────────────┐
-- │ Dealing with errors, inputs and outputs │
-- └─────────────────────────────────────────┘
local function set_proper_keybindings_and_events(popup)
  popup:on(event.BufLeave, function()
    popup:unmount()
  end)
  vim.keymap.set("n", global_vars.opts.keys.quit, function()
      popup:unmount()
    end,
    { buffer = popup.bufnr, silent = true })
  vim.keymap.set("n", "<cr>", function()
      popup:unmount()
    end,
    { buffer = popup.bufnr, silent = true })
  vim.keymap.set("n", global_vars.opts.keys.next, "",
    { buffer = popup.bufnr, silent = true })
end

local function display_error(data)
  windows.error_window:mount()
  vim.api.nvim_buf_set_lines(windows.error_window.bufnr, 0, -1, false, utils.elements_in_range(utils.split(data), 2))
  set_proper_keybindings_and_events(windows.error_window)
end

local function display_output(data)
  local val = string.match(data, "Output: (%d*)")
  windows.output_window:mount()
  vim.api.nvim_buf_set_lines(windows.output_window.bufnr, 0, -1, false, { val })
  set_proper_keybindings_and_events(windows.output_window)
end

local function ask_for_input()
  -- it should not be possible to execute next command in a buffer oustide the input window
  global_vars.next_blocked = true
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
    return
  end
  return utils.split(data)
end

-- ┌───────────────────────────────────────────┐
-- │ Read buffer content and acknowledge chain │
-- └───────────────────────────────────────────┘
local function update_sram()
  vim.loop.write(global_vars.stdin, "ack\n")

  vim.loop.read_start(global_vars.stdout, vim.schedule_wrap(function(err, data)
    assert(not err, err)
    if data then
      local content = utils.split(data)
      vim.api.nvim_buf_set_lines(windows.popups.sram1.bufnr, 0, -1, true, content)
      vim.api.nvim_buf_set_lines(windows.popups.sram2.bufnr, 0, -1, true, content)
      vim.api.nvim_buf_set_lines(windows.popups.sram3.bufnr, 0, -1, true, content)

      -- ignore Cursor position outside buffer error because of a bug in Neovim API
      if global_vars.scrolling_mode == global_vars.scrolling_modes.autoscrolling then
        pcall(autoscrolling)
      else
        pcall(M.memory_visible)
      end
    end
  end))
end

local function update_uart()
  vim.loop.write(global_vars.stdin, "ack\n")

  vim.loop.read_start(global_vars.stdout, vim.schedule_wrap(function(err, data)
    assert(not err, err)
    if data then
      vim.api.nvim_buf_set_lines(windows.popups.uart.bufnr, 0, -1, true, utils.split(data))
      update_sram()
    end
  end))
end

local function update_eprom()
  vim.loop.write(global_vars.stdin, "ack\n")

  vim.loop.read_start(global_vars.stdout, vim.schedule_wrap(function(err, data)
    assert(not err, err)
    if data then
      vim.api.nvim_buf_set_lines(windows.popups.eprom.bufnr, 0, -1, true, utils.split(data))
      global_vars.eprom = data
      update_uart()
    end
  end))
end

local function update_registers_rel()
  vim.loop.write(global_vars.stdin, "ack\n")

  vim.loop.read_start(global_vars.stdout, vim.schedule_wrap(function(err, data)
    assert(not err, err)
    if data then
      vim.api.nvim_buf_set_lines(windows.popups.registers_rel.bufnr, 0, -1, true, utils.split(data))
      update_eprom()
    end
  end))
end

local function update_registers()
  vim.loop.read_start(global_vars.stdout, vim.schedule_wrap(function(err, data)
    assert(not err, err)
    if data then
      local data_table_slice = check_for_previous_outputs(data)
      if not data_table_slice then
        return
      end
      vim.api.nvim_buf_set_lines(windows.popups.registers.bufnr, 0, -1, true, data_table_slice)
      global_vars.registers = data
      update_registers_rel()
    end
  end))
end

-- ┌───────────────────────┐
-- │ Functions for keymaps │
-- └───────────────────────┘
function M.init_buffer()
  local bfcontent = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  bfcontent = bfcontent:gsub("\n", "newline")

  vim.loop.write(global_vars.stdin, bfcontent .. "\n")
  update_registers()
end

local function next_cycle()
  vim.loop.write(global_vars.stdin, "next \n")
  update_registers()
end

function M.next()
  if global_vars.next_blocked then
    return
  end
  next_cycle()
end

function M.switch_windows(backward)
  backward = backward or false

  if backward then
    windows.current_popup = windows.current_popup - 1 >= 1 and windows.current_popup - 1 or
        #windows.popups_order
  else
    windows.current_popup = windows.current_popup + 1 <= #windows.popups_order and windows.current_popup + 1 or
        1
  end
  vim.api.nvim_set_current_win(windows.popups[windows.popups_order[windows.current_popup]].winid)
end

function M.hide_toggle()
  if global_vars.visible then
    windows.layout:hide()
    global_vars.visible = false
  else
    windows.layout:show()
    vim.api.nvim_set_current_win(windows.popups[windows.popups_order[windows.current_popup]].winid)
    global_vars.visible = true
  end
end

local function del_keybindings()
  if global_vars.opts.keys.hide then
    vim.keymap.del("n", global_vars.opts.keys.hide)
  end
end

function M.quit()
  if not global_vars.completed then
    windows.layout:unmount()
    del_keybindings()
    vim.loop.kill(global_vars.interpreter_id, "sigterm")
  else
    windows.layout:unmount()
    del_keybindings()
  end
end

return M
