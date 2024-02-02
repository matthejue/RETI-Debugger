local config = require("reti-debugger.config")
local windows = require("reti-debugger.windows")
local util = require("reti-debugger.util")

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
-- [ ] scrollbind, scb

-- create empty table for running jobs
M.job_counter = 0

function setup_pipes()
  vim.fn.system("mkdir /tmp/reti-debugger")
  vim.fn.system("mkfifo /tmp/reti-debugger/command")
  vim.fn.system("mkfifo /tmp/reti-debugger/registers")
  vim.fn.system("mkfifo /tmp/reti-debugger/eprom")
  vim.fn.system("mkfifo /tmp/reti-debugger/uart")
  vim.fn.system("mkfifo /tmp/reti-debugger/sram")
end

function setup_options()
    vim.api.nvim_win_set_option(windows.popup_sram.winid, "scrolloff", 999)
end

-- functiont that starts a asynchronous python script in background
function start_interpreter()
  vim.fn.jobstart(
    "/home/areo/Documents/Studium/PicoC-Compiler/src/main.py /home/areo/Documents/Studium/PicoC-Compiler/run/gcd.reti -S",
    {
      on_exit = function()
        M.job_counter = M.job_counter - 1
        vim.fn.system("rm -r /tmp/reti-debugger")
        print("Interpreter terminated")
      end
    })

  M.job_counter = M.job_counter + 1
end

function update()
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

  vim.api.nvim_buf_set_lines(windows.popup_registers.bufnr, 0, -1, true, util.split(registers))
  vim.api.nvim_buf_set_lines(windows.popup_eprom.bufnr, 0, -1, true, util.split(eprom))
  vim.api.nvim_buf_set_lines(windows.popup_uart.bufnr, 0, -1, true, util.split(uart))
  vim.api.nvim_buf_set_lines(windows.popup_sram.bufnr, 0, -1, true, util.split(sram))
  vim.api.nvim_buf_set_lines(windows.popup_sram2.bufnr, 0, -1, true, util.split(sram))

  local pc_address = tonumber(string.match(registers, "PC: *(%d+)"))
  local pc_column

  if pc_address > 2^31 then -- sram 
    vim.api.nvim_win_set_cursor(windows.popup_sram.winid, {pc_address - 2^31 + 1, 0})
    local win_heigh = vim.api.nvim_win_get_height(windows.popup_sram.winid)
    vim.fn.win_gotoid(windows.popup_sram.winid)
    local virtual_linenr = vim.fn.winline()
    vim.api.nvim_win_set_cursor(windows.popup_sram2.winid, {pc_address - 2^31 + 1 + (win_heigh - virtual_linenr + 1), 0})
    vim.fn.win_gotoid(windows.popup_sram2.winid)
    vim.api.nvim_input("zt")
  elseif pc_address > 2^30 then -- uart
    pc_column = pc_address - 2^30
  else -- eprom
    pc_column = pc_address
  end

  -- vim.api.nvim_win_set_option(windows.popup_sram.winid, scroll, value)
end

function M.setup()
  setup_pipes()
  start_interpreter()
  windows.layout:mount()
  setup_options()
  update()
end

function M.next()
  -- send continue command to pipe
  util.write_to_pipe("next")
  update()
  -- windows.update_buffers()
end

return M
