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
-- [ ] sperre damit nicht mehre Jobs vom REIT-Inerpreter gestartet werden können
-- [ ] on winexit stop RETI-Interpreter und Command, der das Plugin stoppt
-- [ ] Einen Comand erstellen, der das Plugin startet
-- [ ] Command um zwischen den Fenstern zu switchen
-- [ ] Command oder einfach Funtion, um einen Register Wert zu ändern
-- [ ] Command odere einfache Funktion, um eine Speicherstelle dauerhaft zu färben
-- [ ] Command, um scrollbind für ein Fenster zu deaktivieren
-- [ ] Sobald der RETI-Interpreter fertig ist muss er das mitteilen, damit das Plugin sicher exiten kann
-- [ ] Clock Cycles
-- [ ] Nowrap einstellen
-- [ ] herausfinden, wieso Compiler aufhört zu funktionieren beim ausführeh
-- [ ] zu kompilierenden Code aus buffer nehmen

Job_Counter = 0

local function setup_pipes()
  vim.fn.system("mkdir /tmp/reti-debugger")
  vim.fn.system("mkfifo /tmp/reti-debugger/command")
  vim.fn.system("mkfifo /tmp/reti-debugger/registers")
  vim.fn.system("mkfifo /tmp/reti-debugger/registers_rel")
  vim.fn.system("mkfifo /tmp/reti-debugger/eprom")
  vim.fn.system("mkfifo /tmp/reti-debugger/uart")
  vim.fn.system("mkfifo /tmp/reti-debugger/sram")
end

local function start_interpreter()
  vim.fn.jobstart(
    "/home/areo/Documents/Studium/PicoC-Compiler/src/main.py /home/areo/Documents/Studium/PicoC-Compiler/tests/example_fib_it.reti -S -D 200",
    {
      on_exit = function()
        M.job_counter = M.job_counter - 1
        vim.fn.system("rm -r /tmp/reti-debugger")
        print("Interpreter terminated")
      end
    })

  Job_Counter = Job_Counter + 1
end

function M.setup(opts)
  opts = vim.tbl_deep_extend("keep", opts, config)
  setup_pipes()
  start_interpreter()
  keymap.set_keybindings(opts.keys)
  windows.layout:mount()
  -- setup_options()
  actions.update()
end

return M
