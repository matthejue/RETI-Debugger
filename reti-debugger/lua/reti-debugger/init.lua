local config = require("reti-debugger.config")
local windows = require("reti-debugger.windows")
local keymap = require("reti-debugger.keymap")
local actions = require("reti-debugger.actions")

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
-- [ ] make cursor invisible
-- [ ] special keybinding for buffer
-- [ ] on winexit stop RETI-Interpreter
-- [ ] sperre damit nicht mehre Jobs vom REIT-Inerpreter gestartet werden können

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
  vim.api.nvim_win_set_option(windows.popups.sram.winid, "scrolloff", 999)
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

function M.setup(opts)
  opts = vim.tbl_deep_extend("keep", opts, config)
  setup_pipes()
  start_interpreter()
  keymap.set_keybindings(opts.keys)
  windows.layout:mount()
  setup_options()
  actions.update()
end

return M
