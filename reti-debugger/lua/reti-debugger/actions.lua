local windows = require("reti-debugger.windows")
local utils = require("reti-debugger.utils")
local global_vars = require("reti-debugger.global_vars")

local M = {}

local function scroll_left_window(bfline, buf_height)
  utils.set_no_scrollbind()

  vim.api.nvim_win_set_cursor(windows.popups.sram1.winid, { bfline + 1, 0 })
  -- vim.fn.win_gotoid(windows.popups.sram1.winid)
  vim.api.nvim_set_current_win(windows.popups.sram1.winid)
  local win1_end = vim.fn.line("w$", windows.popups.sram1.winid)

  vim.api.nvim_win_set_cursor(windows.popups.sram2.winid,
    { win1_end + 1 <= buf_height and win1_end + 1 or buf_height, 0 })
  -- vim.fn.win_gotoid(windows.popups.sram2.winid)
  vim.api.nvim_set_current_win(windows.popups.sram2.winid)
  vim.cmd("normal! zt")
  local win2_end = vim.fn.line("w$", windows.popups.sram2.winid)

  vim.api.nvim_win_set_cursor(windows.popups.sram3.winid,
    { win2_end + 1 <= buf_height and win2_end + 1 or buf_height, 0 })
  -- vim.fn.win_gotoid(windows.popups.sram3.winid)
  vim.api.nvim_set_current_win(windows.popups.sram3.winid)
  vim.cmd("normal! zt")

  utils.set_scrollbind(win1_end + 1 <= buf_height, win2_end + 1 <= buf_height)
end


local function autoscrolling(pc_address)
  local win_height = vim.api.nvim_win_get_height(windows.popups.sram1.winid)
  local buf_height = vim.api.nvim_buf_line_count(windows.popups.sram1.bufnr)
  if pc_address >= 2 ^ 31 then -- sram
    local bfline = pc_address - 2 ^ 31
    scroll_left_window(bfline, buf_height)
  else -- uart and eprom
    -- scroll_middle_window(win_height + math.floor(win_height / 2), buf_height)
    scroll_left_window(math.floor(win_height / 2), buf_height)
  end
end

function M.update_registers()
  vim.loop.read_start(global_vars.stdout, vim.schedule_wrap(function(err, registers)
    assert(not err, err)
    if registers then
      vim.api.nvim_buf_set_lines(windows.popups.registers.bufnr, 0, -1, true, utils.split(registers))
    end
    vim.loop.write(global_vars.stdin, "ack")
    vim.loop.shutdown(global_vars.stdin, function(err)
      vim.loop.close(global_vars.handle, function()
      end)
    end)
    M.update_registers_rel()
  end))
  -- vim.loop.shutdown(global_vars.stdout, function(err)
  --   -- vim.loop.close(global_vars.handle, function()
  --   -- end)
  -- end)
end

function M.update_registers_rel()
  vim.loop.read_start(global_vars.stdout, vim.schedule_wrap(function(err, registers)
    assert(not err, err)
    if registers then
      vim.api.nvim_buf_set_lines(windows.popups.registers.bufnr, 0, -1, true, utils.split(registers))
    end
  end))
  vim.loop.write(global_vars.stdin, "ack\n")
  vim.loop.shutdown(global_vars.stdin, function(err)
    vim.loop.close(global_vars.handle, function()
    end)
  end)
end

function M.update2()
  local registers
  local registers_rel
  local eprom
  local uart
  local sram
  local ack

  while true do
    ack = utils.read_from_pipe("acknowledge")
    if ack == nil then
      return
    elseif ack == "ack" then
      break
    elseif ack == "end" then
      global_vars.completed = true
      return
    end
  end

  registers = utils.read_from_pipe("registers")
  registers_rel = utils.read_from_pipe("registers_rel")
  eprom = utils.read_from_pipe("eprom")
  uart = utils.read_from_pipe("uart")
  sram = utils.read_from_pipe("sram")

  vim.api.nvim_buf_set_lines(windows.popups.registers.bufnr, 0, -1, true, utils.split(registers))
  vim.api.nvim_buf_set_lines(windows.popups.registers_rel.bufnr, 0, -1, true, utils.split(registers_rel))
  vim.api.nvim_buf_set_lines(windows.popups.eprom.bufnr, 0, -1, true, utils.split(eprom))
  vim.api.nvim_buf_set_lines(windows.popups.uart.bufnr, 0, -1, true, utils.split(uart))
  vim.api.nvim_buf_set_lines(windows.popups.sram1.bufnr, 0, -1, true, utils.split(sram))
  vim.api.nvim_buf_set_lines(windows.popups.sram2.bufnr, 0, -1, true, utils.split(sram))
  vim.api.nvim_buf_set_lines(windows.popups.sram3.bufnr, 0, -1, true, utils.split(sram))

  local pc_address = tonumber(string.match(registers, "PC: *(%d+)"))
  autoscrolling(pc_address)
end

function M.next()
  if global_vars.completed then
    return
  end
  -- send continue command to pipe
  utils.write_to_pipe("next ")
  M.update_registers()
end

function M.switch_windows()
  global_vars.current_popup = global_vars.current_popup + 1 <= #windows.popups_order and global_vars.current_popup + 1 or
      1
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
