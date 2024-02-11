local configs = require("reti-debugger.configs")
local windows = require("reti-debugger.windows")
local actions = require("reti-debugger.actions")
local global_vars = require("reti-debugger.global_vars")

local M = {}

-- TODO:
-- [?] autocommand that executes next update in certain time intervalls in asynchronous
-- [x] actually register, eprom, uart etc. übergeben
-- [x] setup funtion erstellen mit commands und keybindings festlegen
-- [?] irgendwie dafür sorgen, dass nicht mehr als ein RETIInterpreter Job laufen kann
-- [x] RETIInterpreter irgendwie starten am besten mit command
-- [?] SigTerm an RETIInterpreter weiterleiten
-- [?] .reti filetype erkennen, Treesitter parser, weitere Datentypen für ftplugin
-- [x] callback functions nachsehen und die sache mit vim.loop
-- [x] scrollbind, scb
-- [T] make cursor, cursorline usw. invisible
-- [x] special keybinding for buffer
-- [ ] on winexit stop RETI-Interpreter und Command, der das Plugin stoppt.  VimLeave oder WinClose autocommands
-- [x] Einen Comand erstellen, der das Plugin startet
-- [x] Command um zwischen den Fenstern zu switchen / wechseln
-- [T] Command oder einfach Funtion, um einen Register Wert zu ändern, set
-- [T] Command odere einfache Funktion, um eine Speicherstelle dauerhaft zu färben
-- [?] Command, um scrollbind für ein Fenster zu deaktivieren
-- [x] Sobald der RETI-Interpreter fertig ist muss er das mitteilen, damit das Plugin sicher exiten kann
-- [?] Nowrap einstellen
-- [x] herausfinden, wieso Compiler aufhört zu funktionieren beim ausführen
-- [x] zu kompilierenden Code aus buffer nehmen
-- [x] der Command, der das Plugin startet soll M.completed wieder auf false setzen
-- [?] cursor, cursorline usw. unsichtbar machen
-- [?] option to also take global keybindings
-- [x] be also able to switch windows in backward direction
-- [x] schauen was es mit dieser out Datei auf sich hat
-- [x] ColorManager fixen für stdin
-- [?] Toml reader für config file
-- [?] Input, Expected Outputs, Datasegment Size, Clock Cycles, #Befehle
-- [x] Mode, in dem in Fenster 2 und 3 Globale Statische Daten und Stack angezeigt werden
-- [?] Command, um scrollbind für ein Fenster zu deaktivieren
-- [?] Commands für Shortcuts?
-- [x] Rückwarks Fenster durchgehen Keybind und command
-- [ ] Schönes Github Readme, Report anfangen
-- [?] Breakpoint and continue
-- [ ] alles korrekt beenden wegen libuv
-- [x] Stdin bei InPterter nicht direkt message_content option
-- [T] Wenn man keine RETI-Datei öffnet und andere Errors
-- [ ] Report: libuv und luv, wie man richtig beendet, die Sache mit
-- schedule_wrap, callback functions, nui verwenden, Fehlermeldungen (pcall und
-- wenn eine nicht RETI-Datei geöffnet wird), vielleicht noch verwendete
-- Funktionnen von Neovim, die Sache linewrap, language server usw.
-- Kommunikationosprotokol zeigen, Gründe für dieses Layout (2 andere SRAM
-- Globale Statische Daten und Stack), Scrolling Modes, Weitere Ideen?
-- Backwards? Grund für Neovim Plugin, wollte schon immer lernen, letzten
-- commit angeben vor Artifact Abgabe, speziel alle Änderungen am
-- Picoc-Compiler aus den Commits aufzählen, die verschiedenen Modes erklären,
-- wieso PicocCompiler, davor billiger Trick, kleine Details, wie das sich
-- Überschriften ändern, Scratchbuffer erwähnen, damit nicht nervig beim exiten
-- und bei Übergabe newlines entfernen für input() von Python, Übertragungsende
-- über newline, global und buffer only commands, wie Zeiger zustandekommen,
-- Datensegmentstart und Ende werden aus EPROM rausgelesen, PicoC-Compiler wird
-- über Stdin Code übergeben, PicocCompiler in der Lage direkt Inputs aus
-- Kommentaren rauszulesen, Ordnerstruktur des Projektes, Bitte nur Commits ab
-- Projekanfang betachten beim PicoC-Compiler. PicoC-Compiler seperates Repo.
-- Im Video erwähnen, dass man nach den Vorgaben auch Docker verwenden kann.
-- Chain erwähnen von callback functions aufrufen. Man kann in Fenste
-- reinschreiben und sie abspeichern, modifiable and not readonly es gibt
-- keinen Grund die Freiheit des Users einzuschränken, wird sowieso im nächsten
-- Schritt was neues generiert. Kommunikation über Stdin und Stdout und
-- asynchron. Bei Ordnerstruktur des PicoC-Compilers nur wichtige Dateien
-- nennen. Was passiert wenn man Layout schließt ohne q, sonder mit :q. Die
-- Sache mit table.unpack. Wenn man nicht nach Fehlern sucht, dann findet man
-- auch keine. Jeden möglichen Fehler zu vermeiden wäre zu aufwändig für ein
-- solches Projekt. Ist in dem Zustand auf jeden Fall einsetzbar für Studenten
-- und das war das Ziel, wenn man keine offenstlich dummen Eingaben macht,
-- nicht für den dumstmöglichen Nutzer entwickelt sondern für
-- Universitätsstudenten, wie input und output umgesetzt sind. Beispiel
-- RETI-Programm hochladen, wie input und output abgesichert sind
-- [ ] mal wegen Updatespeed von Neovim schauen
-- [x] Registers und Registers Relative muss nicht 50:50 sein
-- [x] Eprom ist nicht mehr initial window beim starten
-- [T] Was wenn man Fenster schließt
-- [?] Wenn bei der Interpretierung ein call input acc gefunden wird, erscheint ein
-- Eingabefenster im Plugin
-- [?] Wenn bei der Interpretierung ein call print acc gefunden wird, erscheint ein
-- Fenster mit dem Output, dass man wegklicken kann
-- [ ] Das ganze mit Docker zum laufen bringen
-- [ ] Die Sache mit den Events da verwenden, wenn das Main Layout da geschlossen wird
-- [ ] Schauen, ob Errordateien nur erstellt werden wenn notwendig
-- [ ] Schauen, call print acc nicht ein Problem sein könnte
-- [ ] Nicht so viel Abstand notwendig zwischen zwischen Registern und Werten
-- [ ] Schauen, ob es wirklich keine Probleme macht, dass start_read am Ende nicht gestoppt wird
-- [ ] Wenn man keine Zahl als Input eingibt
-- [?] Option PicoC Programm kompilieren zu lassen und dann Buffer content zu
-- RETI Code ausgetauscht
-- [ ] Wenn man aus dem Input Window rausgeht und next drückt...
-- [ ] RunExample Command
-- [ ] Restart command
-- [ ] Schauen, warum call print nicht mit negaitven Zahlen funktioniert

local function set_state()
  global_vars.completed = false
  global_vars.first_focus_over = false
end

local function set_pipes()
  global_vars.stdin = vim.loop.new_pipe(false)
  global_vars.stdout = vim.loop.new_pipe(false)
  global_vars.stderr = vim.loop.new_pipe(false)
end

local function start_interpreter()
  global_vars.handle, global_vars.interpreter_id = vim.loop.spawn(
    "picoc_compiler",
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

local function set_window_options()
  vim.api.nvim_win_set_option(windows.popups.sram1.winid, "scrolloff", 999)

  if global_vars.scrolling_mode == global_vars.scrolling_modes.autoscrolling then
    windows.window_titles_autoscrolling()
  else
    windows.window_titles_memory_focus()
  end
end

local function set_keybindings()
  for _, popup in pairs(windows.popups) do
    vim.keymap.set("n", global_vars.opts.keys.next, actions.next,
      { buffer = popup.bufnr, silent = true })
    vim.keymap.set("n", global_vars.opts.keys.switch_window, actions.switch_windows,
      { buffer = popup.bufnr, silent = true })
    vim.keymap.set("n", global_vars.opts.keys.switch_window_backwards, function()
      actions.switch_windows(true)
    end, { buffer = popup.bufnr, silent = true })
    vim.keymap.set("n", global_vars.opts.keys.quit, actions.quit,
      { buffer = popup.bufnr, silent = true })
    vim.keymap.set("n", global_vars.opts.keys.switch_mode, function()
      windows.windows:mount()
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
  vim.api.nvim_create_user_command("StartRETIDebugger", M.start,
    { desc = "Start RETI-Debugger" })
end

function M.setup(opts)
  global_vars.opts = vim.tbl_deep_extend("keep", opts, configs)

  set_commands()
end

function M.start()
  set_state()
  set_pipes()
  start_interpreter()
  actions.init_buffer()
  windows.layout:mount()
  set_window_options()
  set_keybindings()
end

return M
