local config = require("reti-debugger.config")
local windows = require("reti-debugger.windows")
-- local test = require("reti-debugger.test")

local M = {}

-- TODO:
-- [ ] VimLeave autocommand remove pipe
-- [ ] autocommand that executes next update in certain time intervalls in asynchronous
-- [ ] actually register, eprom, uart etc. übergeben
-- [ ] setup funtion erstellen mit autocmmands und keybindings festlegen
-- [ ] while True entfernen um read_from_pipe
-- [ ] irgendwie dafür sorgen, dass nicht mehr als RETIInterpreter Job laufen kann
-- [ ] RETIInterpreter irgendwie starten am besten mit command
-- [ ] SigTerm an RETIInterpreter weiterleiten
-- [ ] .reti filetype erkennen, Treesitter parser, weitere Datentypen für ftplugin
-- [ ] callback functions nachsehen und die sache mit vim.loop

-- create empty table for running jobs
M.job_counter = 0

-- function that reads from named pipe and prints it
function read_from_pipe(pipe_name)
  local f = io.open("/tmp/" .. pipe_name, "r")
  if f == nil then
    print("Pipe /tmp/" .. pipe_name .. " not found")
    return
  end
  local line = f:read("*a")
  f:close()
  return line
end

function write_to_pipe(command)
  local f = io.open("/tmp/command", "w")
  f:write(command)
  f:close()
end

function update()
  local registers
  local eprom
  local uart
  local sram
  local test

  -- test if named pipe exists
  if M.job_counter == 0 then
    print("No interpreter running")
    return
  end

  registers = read_from_pipe("registers")
  -- eprom = read_from_pipe("eprom")
  -- uart = read_from_pipe("uart")
  -- sram = read_from_pipe("sram")
  -- local reg_buffer = vim.api.nvim_create_buf(true, true)
  -- vim.api.nvim_buf_set_lines(reg_buffer, 0, -1, true, vim.split(registers, "\n"))
  -- local reg_window = vim.api.nvim_open_win(reg_buffer, true, {
  --   relative = "editor",
  --   width = 30,
  --   height = 10,
  --   col = 80,
  --   row = 0,
  --   border = "minimal",
  -- })
  -- neovim get editor width and height
  -- local width = vim.api.nvim_get_option("columns")
  -- local height = vim.api.nvim_get_option("lines")
  print(registers)
  -- print(eprom)
  -- print(uart)
  -- print(sram)
end

-- functiont that starts a asynchronous python script in background
function start_interpreter()
  -- named pipe has to created by the plugin, because only the plugin writes to it
  vim.fn.system("mkfifo /tmp/command")

  vim.fn.jobstart(
    "/home/areo/Documents/Studium/PicoC-Compiler/src/main.py /home/areo/Documents/Studium/PicoC-Compiler/run/gcd.reti -S")
  -- {
  --   on_exit = function()
  --     M.job_counter = M.job_counter - 1
  --     print("Interpreter terminated")
  --   end
  -- })

  M.job_counter = M.job_counter + 1
end

function M.setup()
  start_interpreter()
  -- windows.create_windows()
  -- test.layout:mount()
  update()
end

function M.next()
  -- send continue command to pipe
  write_to_pipe("next")
  update()
  windows.update_buffers()
end

return M
