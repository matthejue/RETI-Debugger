local windows = require("reti-debugger.windows")
local utils = require("reti-debugger.utils")
local global_vars = require("reti-debugger.global_vars")

local M = {}

local function scroll_windows(bfline, buf_height)
  utils.set_no_scrollbind()

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

  utils.set_scrollbind(win1_end + 1 <= buf_height, win2_end + 1 <= buf_height)
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
  local start_datasegment = tonumber(string.match(global_vars.eprom, "ADDI DS (%d+)"))
  local buf_height = vim.api.nvim_buf_line_count(windows.popups.sram1.bufnr)

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

  vim.api.nvim_win_set_cursor(windows.popups.sram2.winid, { start_datasegment + 1, 0 })
  vim.api.nvim_set_current_win(windows.popups.sram2.winid)
  vim.cmd("normal! zt")

  vim.api.nvim_win_set_cursor(windows.popups.sram3.winid, { buf_height, 0 })
  vim.api.nvim_set_current_win(windows.popups.sram3.winid)
  vim.cmd("normal! zb")

  global_vars.first_focus_over = true
end

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

function update_registers()
  vim.loop.read_start(global_vars.stdout, vim.schedule_wrap(function(err, data)
    assert(not err, err)
    if data then
      vim.api.nvim_buf_set_lines(windows.popups.registers.bufnr, 0, -1, true, utils.split(data))
      global_vars.registers = data
      update_registers_rel()
    end
  end))
end

function M.init_buffer()
  local bfcontent = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  bfcontent = bfcontent:gsub("\n", "newline")

  vim.loop.write(global_vars.stdin, bfcontent .. "\n")
  update_registers()
end

function next_cycle()
  vim.loop.write(global_vars.stdin, "next \n")
  update_registers()
end

function M.next()
  if global_vars.completed then
    return
  end
  next_cycle()
end

function M.switch_windows(backward)
  backward = backward or false

  if backward then
    global_vars.current_popup = global_vars.current_popup - 1 >= 1 and global_vars.current_popup - 1 or
        #windows.popups_order
  else
    global_vars.current_popup = global_vars.current_popup + 1 <= #windows.popups_order and global_vars.current_popup + 1 or
        1
  end
  vim.api.nvim_set_current_win(windows.popups[windows.popups_order[global_vars.current_popup]].winid)
end

function M.hide_toggle()
  if global_vars.visible then
    windows.layout:hide()
    global_vars.visible = false
  else
    windows.layout:show()
    vim.api.nvim_set_current_win(windows.popups[windows.popups_order[global_vars.current_popup]].winid)
    global_vars.visible = true
  end
end

local function del_keybindings()
  if global_vars.opts.keys.hide then
    vim.keymap.del("n", global_vars.opts.keys.hide)
  end
end

function M.quit()
  windows.layout:unmount()
  del_keybindings()
  vim.loop.kill(global_vars.interpreter_id, "sigterm")
end

return M
