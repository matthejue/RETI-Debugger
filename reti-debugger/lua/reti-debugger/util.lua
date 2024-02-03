local windows = require("reti-debugger.windows")

local M = {}

function M.read_from_pipe(pipe_name)
  local f = io.open("/tmp/reti-debugger/" .. pipe_name, "r")
  if f == nil then
    print("Pipe /tmp/reti-debugger/" .. pipe_name .. " not found")
    return
  end
  local line = f:read("*a")
  f:close()
  return line
end

function M.write_to_pipe(command)
  local f = io.open("/tmp/reti-debugger/command", "w")
  f:write(command)
  f:close()
end

function M.split(str)
  local t = {}
  for line in str:gmatch("[^\n]+") do
    table.insert(t, line)
  end
  return t
end

function M.set_no_scrollbind()
  vim.api.nvim_win_set_option(windows.popups.sram1.winid, "scrollbind", false)
  vim.api.nvim_win_set_option(windows.popups.sram2.winid, "scrollbind", false)
  vim.api.nvim_win_set_option(windows.popups.sram3.winid, "scrollbind", false)
end

function M.set_scrollbind(one_and_two, two_and_three)
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

-- local virtual_linenr = vim.fn.winline()

-- ┌──────────┐
-- │ Not used │
-- └──────────┘

-- local function set_buffers_modifiable()
--   vim.api.nvim_buf_set_option(windows.popups.registers.bufnr, "modifiable", true)
--   vim.api.nvim_buf_set_option(windows.popups.eprom.bufnr, "modifiable", true)
--   vim.api.nvim_buf_set_option(windows.popups.uart.bufnr, "modifiable", true)
--   vim.api.nvim_buf_set_option(windows.popups.sram.bufnr, "modifiable", true)
--   vim.api.nvim_buf_set_option(windows.popups.sram2.bufnr, "modifiable", true)
-- end
--
-- local function set_buffers_not_modifiable()
--   vim.api.nvim_buf_set_option(windows.popups.registers.bufnr, "modifiable", false)
--   vim.api.nvim_buf_set_option(windows.popups.eprom.bufnr, "modifiable", false)
--   vim.api.nvim_buf_set_option(windows.popups.uart.bufnr, "modifiable", false)
--   vim.api.nvim_buf_set_option(windows.popups.sram.bufnr, "modifiable", false)
--   vim.api.nvim_buf_set_option(windows.popups.sram2.bufnr, "modifiable", false)
-- end
--
-- local function set_buffers_not_readonly()
--   vim.api.nvim_buf_set_option(windows.popups.registers.bufnr, "readonly", false)
--   vim.api.nvim_buf_set_option(windows.popups.eprom.bufnr, "readonly", false)
--   vim.api.nvim_buf_set_option(windows.popups.uart.bufnr, "readonly", false)
--   vim.api.nvim_buf_set_option(windows.popups.sram.bufnr, "readonly", false)
--   vim.api.nvim_buf_set_option(windows.popups.sram2.bufnr, "readonly", false)
-- end
--
-- local function set_buffers_readonly()
--   vim.api.nvim_buf_set_option(windows.popups.registers.bufnr, "readonly", true)
--   vim.api.nvim_buf_set_option(windows.popups.eprom.bufnr, "readonly", true)
--   vim.api.nvim_buf_set_option(windows.popups.uart.bufnr, "readonly", true)
--   vim.api.nvim_buf_set_option(windows.popups.sram.bufnr, "readonly", true)
--   vim.api.nvim_buf_set_option(windows.popups.sram2.bufnr, "readonly", true)
-- end
--
-- local function scroll_windows(pc_address, win_heigh)
--     vim.api.nvim_win_set_option(windows.popups.sram.winid, "scrollbind", false)
--     vim.api.nvim_win_set_cursor(windows.popups.sram.winid, { pc_address - 2 ^ 31 + 1, 0 })
--     vim.fn.win_gotoid(windows.popups.sram.winid)
--     vim.api.nvim_win_set_option(windows.popups.sram.winid, "scrollbind", true)
--
--     local virtual_linenr = vim.fn.winline()
--     vim.api.nvim_win_set_option(windows.popups.sram2.winid, "scrollbind", false)
--     vim.api.nvim_win_set_cursor(windows.popups.sram2.winid,
--       { pc_address - 2 ^ 31 + 1 + (win_heigh - virtual_linenr + 1), 0 })
--     vim.fn.win_gotoid(windows.popups.sram2.winid)
--     vim.api.nvim_input("zt")
--     vim.api.nvim_win_set_option(windows.popups.sram2.winid, "scrollbind", true)
-- end
--
-- local function scrollbind_windows(current_column, win_heigh)
--     vim.api.nvim_win_set_cursor(windows.popups.sram2.winid, { win_heigh + 1, 0 })
--     vim.fn.win_gotoid(windows.popups.sram2.winid)
--     vim.api.nvim_input("zt")
-- end

-- local function scroll_middle_window(bfline, buf_height)
--   util.set_no_scrollbind()
--
--   vim.api.nvim_win_set_cursor(windows.popups.sram2.winid, { bfline + 1, 0 })
--   vim.fn.win_gotoid(windows.popups.sram2.winid)
--   local win2_start = vim.fn.line("w0", windows.popups.sram2.winid)
--   local win2_end = vim.fn.line("w$", windows.popups.sram2.winid)
--
--   vim.api.nvim_win_set_cursor(windows.popups.sram1.winid,
--     { win2_start - 1 >= 1 and win2_start - 1 or 1, 0 })
--   vim.fn.win_gotoid(windows.popups.sram1.winid)
--   -- vim.api.nvim_input("zb") -- not always working
--   vim.cmd("normal! zb")
--
--   vim.api.nvim_win_set_cursor(windows.popups.sram3.winid,
--     { win2_end + 1 <= buf_height and win2_end + 1 or buf_height, 0 })
--   vim.fn.win_gotoid(windows.popups.sram3.winid)
--   -- vim.api.nvim_input("zt") -- not always working
--   vim.cmd("normal! zt")
--
--   -- local win1_end = vim.fn.line("w$", windows.popups.sram1.winid)
--   -- local win3_start = vim.fn.line("w0", windows.popups.sram3.winid)
--   util.set_scrollbind(win2_start - 1 >= 1, win2_end + 1 <= buf_height)
-- end


return M
