local windows = require("reti-debugger.windows")
local util = require("reti-debugger.util")

local M = {}

function autoscrolling(pc_address)
  local win_heigh = vim.api.nvim_win_get_height(windows.popups.sram.winid)
  if pc_address > 2 ^ 31 then -- sram
    -- vim.api.nvim_win_set_option(windows.popups.sram.winid, "scrollbind", false)
    vim.api.nvim_win_set_cursor(windows.popups.sram.winid, { pc_address - 2 ^ 31 + 1, 0 })
    -- vim.api.nvim_win_set_option(windows.popups.sram.winid, "scrollbind", true)

    vim.fn.win_gotoid(windows.popups.sram.winid)
    local virtual_linenr = vim.fn.winline()
    -- vim.api.nvim_win_set_option(windows.popups.sram2.winid, "scrollbind", false)
    vim.api.nvim_win_set_cursor(windows.popups.sram2.winid,
      { pc_address - 2 ^ 31 + 1 + (win_heigh - virtual_linenr + 1), 0 })
    vim.fn.win_gotoid(windows.popups.sram2.winid)
    vim.api.nvim_input("zt")
    -- vim.api.nvim_win_set_option(windows.popups.sram2.winid, "scrollbind", true)
  elseif pc_address > 2 ^ 30 then -- uart
    pc_column = pc_address - 2 ^ 30
  else                            -- eprom
    vim.api.nvim_win_set_cursor(windows.popups.sram2.winid, { win_heigh + 1, 0 })
    vim.fn.win_gotoid(windows.popups.sram2.winid)
    vim.api.nvim_input("zt")
    pc_column = pc_address
  end
end

function M.update()
  local registers
  local eprom
  local uart
  local sram

  -- test if named pipe exists
  if M.job_counter == 0 then
    print("No interpreter running")
    return
  end

  registers = util.read_from_pipe("registers")
  eprom = util.read_from_pipe("eprom")
  uart = util.read_from_pipe("uart")
  sram = util.read_from_pipe("sram")

  vim.api.nvim_buf_set_lines(windows.popups.registers.bufnr, 0, -1, true, util.split(registers))
  vim.api.nvim_buf_set_lines(windows.popups.eprom.bufnr, 0, -1, true, util.split(eprom))
  vim.api.nvim_buf_set_lines(windows.popups.uart.bufnr, 0, -1, true, util.split(uart))
  vim.api.nvim_buf_set_lines(windows.popups.sram.bufnr, 0, -1, true, util.split(sram))
  vim.api.nvim_buf_set_lines(windows.popups.sram2.bufnr, 0, -1, true, util.split(sram))

  local pc_address = tonumber(string.match(registers, "PC: *(%d+)"))
  autoscrolling(pc_address)
end

function M.next()
  -- send continue command to pipe
  util.write_to_pipe("next")
  M.update()
end

return M
