local windows = require("reti-debugger.windows")
local util = require("reti-debugger.util")

local M = {}

local function scroll_windows(line, buf_height)
  -- vim.api.nvim_win_set_option(windows.popups.sram1.winid, "scrollbind", false)
  -- vim.api.nvim_win_set_option(windows.popups.sram2.winid, "scrollbind", false)
  -- vim.api.nvim_win_set_option(windows.popups.sram3.winid, "scrollbind", false)

  vim.api.nvim_win_set_cursor(windows.popups.sram2.winid, { line + 1, 0 })
  vim.fn.win_gotoid(windows.popups.sram2.winid)
  win2_start = vim.fn.line("w0", windows.popups.sram2.winid)
  win2_end = vim.fn.line("w$", windows.popups.sram2.winid)

  vim.api.nvim_win_set_cursor(windows.popups.sram1.winid,
    { win2_start - 1 >= 1 and win2_start - 1 or 1, 0 })
  vim.api.nvim_win_set_cursor(windows.popups.sram3.winid,
    { win2_end + 1 <= buf_height and win2_end + 1 or buf_height, 0 })
  vim.fn.win_gotoid(windows.popups.sram1.winid)
  vim.api.nvim_input("zb")
  vim.fn.win_gotoid(windows.popups.sram3.winid)
  vim.api.nvim_input("zt")

  -- vim.api.nvim_win_set_option(windows.popups.sram1.winid, "scrollbind", true)
  -- vim.api.nvim_win_set_option(windows.popups.sram2.winid, "scrollbind", true)
  -- vim.api.nvim_win_set_option(windows.popups.sram3.winid, "scrollbind", true)

  -- local virtual_linenr = vim.fn.winline()
end

local function autoscrolling(pc_address)
  local win_height = vim.api.nvim_win_get_height(windows.popups.sram1.winid)
  local buf_height = vim.api.nvim_buf_line_count(windows.popups.sram1.bufnr)
  if pc_address > 2 ^ 31 then -- sram
    scroll_windows(pc_address - 2 ^ 31, buf_height)
  else -- uart and eprom
    scroll_windows(win_height + math.ceil(win_height / 2) + 1, buf_height)
  end
end

function M.update()
  local registers
  local eprom
  local uart
  local sram

  -- test if named pipe exists
  if Job_Counter == 0 then
    print("No interpreter running")
    return
  end

  registers = util.read_from_pipe("registers")
  registers_rel = util.read_from_pipe("registers_rel")
  eprom = util.read_from_pipe("eprom")
  uart = util.read_from_pipe("uart")
  sram = util.read_from_pipe("sram")

  vim.api.nvim_buf_set_lines(windows.popups.registers.bufnr, 0, -1, true, util.split(registers))
  vim.api.nvim_buf_set_lines(windows.popups.registers_rel.bufnr, 0, -1, true, util.split(registers_rel))
  vim.api.nvim_buf_set_lines(windows.popups.eprom.bufnr, 0, -1, true, util.split(eprom))
  vim.api.nvim_buf_set_lines(windows.popups.uart.bufnr, 0, -1, true, util.split(uart))
  vim.api.nvim_buf_set_lines(windows.popups.sram1.bufnr, 0, -1, true, util.split(sram))
  vim.api.nvim_buf_set_lines(windows.popups.sram2.bufnr, 0, -1, true, util.split(sram))
  vim.api.nvim_buf_set_lines(windows.popups.sram3.bufnr, 0, -1, true, util.split(sram))

  local pc_address = tonumber(string.match(registers, "PC: *(%d+)"))
  autoscrolling(pc_address)
end

function M.next()
  -- send continue command to pipe
  util.write_to_pipe("next")
  M.update()
end

return M
