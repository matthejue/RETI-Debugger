local configs = require("reti-debugger.configs")
local windows = require("reti-debugger.windows")
local actions = require("reti-debugger.actions")
local global_vars = require("reti-debugger.global_vars")
local menu = require("reti-debugger.menu")

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
-- [ ] make cursor, cursorline usw. invisible
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
-- [ ] Toml reader für config file
-- [ ] Input, Expected Outputs, Datasegment Size, Clock Cycles, #Befehle
-- [ ] Mode, in dem in Fenster 2 und 3 Globale Statische Daten und Stack angezeigt werden
-- [ ] Command, um scrollbind für ein Fenster zu deaktivieren
-- [ ] Commands für Shortcuts?
-- [ ] Rückwarks Fenster durchgehen Keybind und command
-- [ ] Schönes Github Readme, Report anfangen
-- [ ] Breakpoint and continue
-- [ ] alles korrekt beenden wegen libuv
-- [ ] Stdin bei InPterter nicht direkt message_content option
-- [ ] Wenn man keine RETI-Datei öffnet und andere Errors
-- [ ] Report: libuv und luv, wie man richtig beendet, die Sache mit
-- schedule_wrap, callback functions, nui verwenden, Fehlermeldungen (pcall und
-- wenn eine nicht RETI-Datei geöffnet wird), vielleicht noch verwendete
-- Funktionnen von Neovim, die Sache linewrap, language server usw.
-- Kommunikationosprotokol zeigen, Gründe für dieses Layout (2 andere SRAM
-- Globale Statische Daten und Stack), Scrolling Modes, Weitere Ideen? Backwards?
-- Grund für Neovim Plugin, wollte schon immer lernen, letzten commit angeben
-- vor Artifact Abgabe, speziel alle Änderungen am Picoc-Compiler aus den
-- Commits aufzählen
-- [ ] Libuv properly ausschalten
-- [ ] mal wegen Updatespeed von Neovim schauen
-- [ ] Registers und Registers Relative muss nicht 50:50 sein
-- [ ] Eprom ist nicht mehr initial window beim starten
-- [ ] Was wenn man Fenster schließt

local function set_pipes()
  global_vars.stdin = vim.loop.new_pipe(false)
  global_vars.stdout = vim.loop.new_pipe(false)
  global_vars.stderr = vim.loop.new_pipe(false)
end

local function start_interpreter()
  global_vars.handle, global_vars.interpreter_id = vim.loop.spawn(
    "/home/areo/Documents/Studium/PicoC-Compiler/src/main.py",
    {
      args = { "-E", "reti", "-P" },
      stdio = { global_vars.stdin, global_vars.stdout, global_vars.stderr }
    },
    function(code, signal)
      global_vars.completed = true
      vim.loop.shutdown(global_vars.stdin, function(err)
        vim.loop.close(global_vars.handle, function()
        end)
      end)
      print("Interpreter terminated with exit code " .. code .. " and signal " .. signal)
    end
  )
end

local function set_options()
  vim.api.nvim_win_set_option(windows.popups.sram1.winid, "scrolloff", 999)
end

local function set_keybindings()
  for _, popup in pairs(windows.popups) do
    vim.keymap.set("n", global_vars.opts.keys.next, actions.next, { buffer = popup.bufnr, silent = true })
    vim.keymap.set("n", global_vars.opts.keys.switch_window, actions.switch_windows,
      { buffer = popup.bufnr, silent = true })
    vim.keymap.set("n", global_vars.opts.keys.switch_window_backwards, function()
      actions.switch_windows(true)
    end, { buffer = popup.bufnr, silent = true })
    vim.keymap.set("n", global_vars.opts.keys.quit, actions.quit, { buffer = popup.bufnr, silent = true })
    vim.keymap.set("n", global_vars.opts.keys.switch_mode, function()
      menu.menu:mount()
    end, { buffer = popup.bufnr, silent = true })
    vim.keymap.set("n", global_vars.opts.keys.refocus_memory,
      function()
        global_vars.first_focus_over = false
        actions.memory_visible()
      end, { buffer = popup.bufnr, silent = true })
  end
  if global_vars.opts.keys.hide then
    vim.keymap.set("n", global_vars.opts.keys.hide, actions.hide_toggle,
      { silent = true, desc = "Hide RETI-Interpreter windows" })
  end
end

local function set_commands()
  vim.api.nvim_create_user_command("StartRETIDebugger", M.start, { desc = "Start RETI-Debugger" })
end

function M.setup(opts)
  global_vars.opts = vim.tbl_deep_extend("keep", opts, configs)

  set_commands()
end

function M.start()
  global_vars.completed = false
  global_vars.first_focus_over = false
  set_pipes()
  start_interpreter()
  actions.init_buffer()
  windows.layout:mount()
  set_options()
  set_keybindings()
end

return M
