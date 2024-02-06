local windows = require("reti-debugger.windows")

local M = {}

function M.read_from_pipe(pipe_name)
  local f = io.open("/tmp/reti-debugger/" .. pipe_name, "r")
  if f == nil then
    print("Pipe /tmp/reti-debugger/" .. pipe_name .. " not found")
    return
  end
  local content = f:read("*a")
  f:close()
  return content
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

function M.get_key(tab, val)
  for key, value in pairs(tab) do
    if value == val then
      return key
    end
  end
end

-- ┌──────────┐
-- │ Not used │
-- └──────────┘

-- local virtual_linenr = vim.fn.winline()

-- function M.next_key(tab, val)
--   local next_key = next(tab, get_key(tab, val))
--   if next_key then
--     return next_key
--   else
--     return next(tab, nil)
--   end
-- end

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

-- local function scroll_middle_window(bfline, buf_height)
--   vim.api.nvim_win_set_option(windows.popups.sram1.winid, "scrolloff", 0)
--   vim.api.nvim_win_set_option(windows.popups.sram2.winid, "scrolloff", 999)
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
--   vim.cmd("normal! zb")
--
--   vim.api.nvim_win_set_cursor(windows.popups.sram3.winid,
--     { win2_end + 1 <= buf_height and win2_end + 1 or buf_height, 0 })
--   vim.fn.win_gotoid(windows.popups.sram3.winid)
--   vim.cmd("normal! zt")
--
--   util.set_scrollbind(win2_start - 1 >= 1, win2_end + 1 <= buf_height)
-- end

-- local function autoscrolling(pc_address)
--   local win_height = vim.api.nvim_win_get_height(windows.popups.sram1.winid)
--   local buf_height = vim.api.nvim_buf_line_count(windows.popups.sram1.bufnr)
--   if pc_address >= 2 ^ 31 then -- sram
--     local bfline = pc_address - 2 ^ 31
--     if bfline >= win_height + math.floor(win_height / 2) then
--       scroll_middle_window(bfline, buf_height)
--     else
--       scroll_left_window(bfline, buf_height)
--     end
--   else -- uart and eprom
--     -- scroll_middle_window(win_height + math.floor(win_height / 2), buf_height)
--     scroll_left_window(math.floor(win_height / 2), buf_height)
--   end
-- end

-- M.data = "nothing"
-- function M.alternative_read_pipe(pipe_name)
--   vim.loop.fs_open("/tmp/reti-debugger/" .. pipe_name, "r", 438, function(err, fd)
--     M.data = "asdf"
--     assert(not err, err)
--     vim.loop.fs_fstat(fd, function(err, stat)
--       assert(not err, err)
--       M.data = "asdf"
--       vim.loop.fs_read(fd, stat.size, 0, function(err, data)
--         assert(not err, err)
--         M.data = "asdf"
--         vim.loop.fs_close(fd, function(err)
--           assert(not err, err)
--           M.data = data
--         end)
--       end)
--     end)
--   end)
-- end

return M
