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

function M.set_buffers_modifiable()
  vim.api.nvim_buf_set_option(windows.popups.registers.bufnr, "modifiable", true)
  vim.api.nvim_buf_set_option(windows.popups.eprom.bufnr, "modifiable", true)
  vim.api.nvim_buf_set_option(windows.popups.uart.bufnr, "modifiable", true)
  vim.api.nvim_buf_set_option(windows.popups.sram.bufnr, "modifiable", true)
  vim.api.nvim_buf_set_option(windows.popups.sram2.bufnr, "modifiable", true)
end

function M.set_buffers_not_modifiable()
  vim.api.nvim_buf_set_option(windows.popups.registers.bufnr, "modifiable", false)
  vim.api.nvim_buf_set_option(windows.popups.eprom.bufnr, "modifiable", false)
  vim.api.nvim_buf_set_option(windows.popups.uart.bufnr, "modifiable", false)
  vim.api.nvim_buf_set_option(windows.popups.sram.bufnr, "modifiable", false)
  vim.api.nvim_buf_set_option(windows.popups.sram2.bufnr, "modifiable", false)
end

function M.set_buffers_not_readonly()
  vim.api.nvim_buf_set_option(windows.popups.registers.bufnr, "readonly", false)
  vim.api.nvim_buf_set_option(windows.popups.eprom.bufnr, "readonly", false)
  vim.api.nvim_buf_set_option(windows.popups.uart.bufnr, "readonly", false)
  vim.api.nvim_buf_set_option(windows.popups.sram.bufnr, "readonly", false)
  vim.api.nvim_buf_set_option(windows.popups.sram2.bufnr, "readonly", false)
end

function M.set_buffers_readonly()
  vim.api.nvim_buf_set_option(windows.popups.registers.bufnr, "readonly", true)
  vim.api.nvim_buf_set_option(windows.popups.eprom.bufnr, "readonly", true)
  vim.api.nvim_buf_set_option(windows.popups.uart.bufnr, "readonly", true)
  vim.api.nvim_buf_set_option(windows.popups.sram.bufnr, "readonly", true)
  vim.api.nvim_buf_set_option(windows.popups.sram2.bufnr, "readonly", true)
end

return M
