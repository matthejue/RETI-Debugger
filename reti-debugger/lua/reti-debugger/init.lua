local configs = require("reti-debugger.configs")
local windows = require("reti-debugger.windows")
local actions = require("reti-debugger.actions")
local global_vars = require("reti-debugger.global_vars")

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
-- [ ] Command um zwischen den Fenstern zu switchen / wechseln
-- [ ] Command oder einfach Funtion, um einen Register Wert zu ändern
-- [ ] Command odere einfache Funktion, um eine Speicherstelle dauerhaft zu färben
-- [ ] Command, um scrollbind für ein Fenster zu deaktivieren
-- [ ] Sobald der RETI-Interpreter fertig ist muss er das mitteilen, damit das Plugin sicher exiten kann
-- [ ] Clock Cycles
-- [ ] Nowrap einstellen
-- [ ] herausfinden, wieso Compiler aufhört zu funktionieren beim ausführeh
-- [ ] zu kompilierenden Code aus buffer nehmen
-- [ ] der Command, der das Plugin startet soll M.completed wieder auf false setzen
-- [ ] cursor, cursorline usw. unsichtbar machen
-- [ ] aus buffer nehmen
-- [ ] option to also take global keybindings
-- [ ] be also able to switch windows in backward direction
-- [ ] schauen was es mit dieser out Datei auf sich hat
-- [ ] ColorManager fixen für stdin

local function setup_pipes()
  vim.fn.system("mkdir /tmp/reti-debugger")
  vim.fn.system("mkfifo /tmp/reti-debugger/acknowledge")
  vim.fn.system("mkfifo /tmp/reti-debugger/registers")
  vim.fn.system("mkfifo /tmp/reti-debugger/registers_rel")
  vim.fn.system("mkfifo /tmp/reti-debugger/eprom")
  vim.fn.system("mkfifo /tmp/reti-debugger/uart")
  vim.fn.system("mkfifo /tmp/reti-debugger/sram")
  vim.fn.system("mkfifo /tmp/reti-debugger/command")
end

local function start_interpreter()
  local bfcontent = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")

  global_vars.interpreter_id = vim.fn.jobstart(
    "/home/areo/Documents/Studium/PicoC-Compiler/src/main.py -S -E reti -D 200",
    {
      on_exit = function()
        vim.fn.system("rm -r /tmp/reti-debugger")
        print("Interpreter terminated")
      end,
    })
  vim.api.nvim_chan_send(global_vars.interpreter_id, bfcontent)
  vim.fn.chanclose(global_vars.interpreter_id, "stdin")
end

local function set_options()
  vim.api.nvim_win_set_option(windows.popups.sram1.winid, "scrolloff", 999)
end

local function set_keybindings()
  for _, popup in pairs(windows.popups) do
    vim.keymap.set("n", global_vars.opts.keys.next, actions.next, { buffer = popup.bufnr, silent = true })
    vim.keymap.set("n", global_vars.opts.keys.switch_windows, actions.switch_windows,
      { buffer = popup.bufnr, silent = true })
    vim.keymap.set("n", global_vars.opts.keys.quit, actions.quit, { buffer = popup.bufnr, silent = true })
  end
  if global_vars.opts.keys.hide then
    vim.keymap.set("n", global_vars.opts.keys.hide, actions.hide_toggle,
      { silent = true, desc = "Hide RETI-Interpreter windows" })
  end
end

local function set_commands()
  vim.api.nvim_create_user_command("StartRETIDebugger", M.start, {desc = "Start RETI-Debugger"})
end

function M.setup(opts)
  global_vars.opts = vim.tbl_deep_extend("keep", opts, configs)

  set_commands()
end

function M.start()
  global_vars.completed = false
  setup_pipes()
  start_interpreter()
  windows.layout:mount()
  set_options()
  set_keybindings()
  actions.update()
end

return M
