local configs = require("reti-debugger.configs")
local windows = require("reti-debugger.windows")
local actions = require("reti-debugger.actions")
local state = require("reti-debugger.state")

local M = {}

-- TODO:
-- [x] autocommand that executes next update in certain time intervalls in asynchronous
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
-- RETI-Programm hochladen, wie input und output abgesichert sind. Wie
-- Ordnerstruktur von Neovim Plugins aufgebaut ist und worauf sie basiert.
-- Nicht dafür verantwortlich, dass der PicoC-Compiler perfekt funktioniert.
-- Wie Neovim Pluginmanager funktionieren die Sache mit Runtimepath. Nicht
-- möglich den RETI-Interreter erneut zu starten. Man kann Keybindings neu
-- definieren und es gibt buffer only keybindings und globale keybindings.
-- Statemachine ist aus effizienzgründen nicht genauso umgesetzt, newline mentionen. Videoserie erwähnen
-- [ ] mal wegen Updatespeed von Neovim schauen
-- [x] Registers und Registers Relative muss nicht 50:50 sein
-- [x] Eprom ist nicht mehr initial window beim starten
-- [T] Was wenn man Fenster schließt
-- [?] Wenn bei der Interpretierung ein call input acc gefunden wird, erscheint ein
-- Eingabefenster im Plugin
-- [?] Wenn bei der Interpretierung ein call print acc gefunden wird, erscheint ein
-- Fenster mit dem Output, dass man wegklicken kann
-- [ ] Das ganze mit Docker zum laufen bringen
--   [ ] Schauen, ob es immer noch läuft
-- [ ] Die Sache mit den Events da verwenden, wenn das Main Layout da geschlossen wird
-- [ ] Schauen, ob Errordateien nur erstellt werden wenn notwendig
-- [x] Schauen, call print acc nicht ein Problem sein könnte
-- [ ] Nicht so viel Abstand notwendig zwischen zwischen Registern und Werten
-- [ ] Schauen, ob es wirklich keine Probleme macht, dass start_read am Ende nicht gestoppt wird
-- [x] Wenn man keine Zahl als Input eingibt
-- [?] Option PicoC Programm kompilieren zu lassen und dann Buffer content zu
-- RETI Code ausgetauscht
-- [x] Wenn man aus dem Input Window rausgeht und next drückt...
-- [x] RunExample Command
-- [x] Restart command
-- [x] Schauen, warum call print nicht mit negaitven Zahlen funktioniert
-- [ ] diese nvim_feedback function auch bei autoscrolling nutzen
-- [ ] fn.gotoid durch entsprechend api funktion ersetzen
-- [ ] RestartRETIDebugger soll nicht möglich sein, wenn man das Plugin mit
-- Fenstern bereits komplett geschlossen hat
-- [ ] Problem bei ExamplePrograms nicht mehr selber Buffer
-- [ ] RETI-Interpreter schaut nicht mehr nach .out, .in und .datasegment
-- Dateien, sobald die -m Option gesetzt ist
-- [x] Compile Command
-- [ ] Mappings für neue Commands einführen
-- [ ] die ganzen Autocmmands on auch wieder removen
-- [ ] man muss Menü auch mit q und nicht nur mit esc schließen können
-- [ ] window layout hide nicht wenn das layout schon unmounted
-- [ ] restart nur, wenn layout sichtbar
-- [ ] bei LayoutToggle sollten auch output, error und input window getoggelt werden
-- [ ] Statemachine für switch mode
-- nach restart
-- [ ] wenn man aus menu mittels q rausgeht wurde die Statemenschine nicht zwischendurch aufgerufen
-- [ ] report verlinken nicht vergessen
-- [ ] tag für artifact erstellen
-- [ ] Github actions für das Autogenerieren des Reports erwähnen, das ist Docker Compose
-- [ ] fib_rec not working
-- [ ] dieser seltsame bug, dass output fenster manchmal direkt verschwindet
-- [ ] Artifact Tag erstellen

local function save_state()
	state.bufnr_on_leaving = vim.api.nvim_get_current_buf()
	state.winid_on_leaving = vim.api.nvim_get_current_win()
end

local function set_pipes()
	state.stdin = vim.loop.new_pipe(false)
	state.stdout = vim.loop.new_pipe(false)
	state.stderr = vim.loop.new_pipe(false)
end

local function start_interpreter()
	state.handle, state.interpreter_id = vim.loop.spawn("picoc_compiler", {
		args = { "-E", "reti", "-P" },
		stdio = { state.stdin, state.stdout, state.stderr },
	}, function(code, signal)
		state.delta_windows("complete")
		vim.loop.shutdown(state.stdin, function(err)
			assert(not err, err)
			vim.loop.close(state.handle, function() end)
		end)
		print("Interpreter terminated with exit code " .. code .. " and signal " .. signal)
	end)
end

local function set_window_options()
	vim.api.nvim_win_set_option(windows.popups.sram1.winid, "scrolloff", 999)

	if state.scrolling_mode == state.scrolling_modes.autoscrolling then
		windows.window_titles_autoscrolling()
	else
		windows.window_titles_memory_focus()
	end
end

local function set_keybindings()
	-- ┌────────┐
	-- │ Layout │
	-- └────────┘
	for _, popup in pairs(windows.popups) do
		vim.keymap.set(
			"n",
			state.opts.keys.next,
			actions.next,
			{ buffer = popup.bufnr, silent = true, desc = "Next instruction" }
		)
		vim.keymap.set(
			"n",
			state.opts.keys.switch_window,
			actions.switch_windows,
			{ buffer = popup.bufnr, silent = true, desc = "Switch windows" }
		)
		vim.keymap.set("n", state.opts.keys.switch_window_backwards, function()
			actions.switch_windows(true)
		end, { buffer = popup.bufnr, silent = true, desc = "Switch windows backward" })
		vim.keymap.set("n", state.opts.keys.switch_mode, function()
      state.delta_windows("popup appears")
			windows.menu_modes:mount()
		end, { buffer = popup.bufnr, silent = true, desc = "Menu to switch mode" })
		vim.keymap.set("n", state.opts.keys.focus_memory, function()
			state.first_focus_over = false
			actions.memory_visible()
		end, { buffer = popup.bufnr, silent = true, desc = "Focus memory" })
		vim.keymap.set("n", ":", "", { buffer = popup.bufnr, silent = true })
		vim.keymap.set(
			"n",
			state.opts.keys.restart,
			M.restart,
			{ buffer = popup.bufnr, silent = true, desc = "Restart RETI-Debugger" }
		)
		vim.keymap.set(
			"n",
			state.opts.keys.quit,
			actions.quit,
			{ buffer = popup.bufnr, silent = true, desc = "Quit RETI-Debugger" }
		)
	end
	if state.opts.keys.hide then
		vim.keymap.set(
			"n",
			state.opts.keys.hide,
			actions.hide_toggle,
			{ silent = true, desc = "Hide RETI-Debugger layout" }
		)
	end
end

local function set_global_keybindings()
	if state.opts.keys.load_example then
		vim.keymap.set(
			"n",
			state.opts.keys.load_example,
			":LoadRETIExample<cr>",
			{ silent = true, desc = "Load an example" }
		)
	end
	if state.opts.keys.compile then
		vim.keymap.set(
			"n",
			state.opts.keys.compile,
			actions.compile,
			{ silent = true, desc = "Compile from PicoC to RETI" }
		)
	end
	if state.opts.keys.start then
		vim.keymap.set("n", state.opts.keys.start, M.start, { silent = true, desc = "Start RETI-Debugger" })
	end
end

local function set_commands()
	vim.api.nvim_create_user_command(
		"LoadRETIExample",
		actions.load_example,
		{ desc = "Load an example program", nargs = "?" }
	)
	vim.api.nvim_create_user_command("CompilePicoCBuffer", actions.compile, { desc = "Compile from PicoC to RETI" })
	vim.api.nvim_create_user_command("StartRETIBuffer", M.start, { desc = "Start RETI-Debugger" })
end

function M.setup(opts)
	state.opts = vim.tbl_deep_extend("keep", opts, configs)

	set_commands()
	set_global_keybindings()
end

function M.start()
	if not state.delta_windows("start") then
		return
	end
	state.delta_focus("start")
	save_state()
	set_pipes()
	start_interpreter()
	actions.init_buffer()
	windows.layout:mount()
	set_window_options()
	set_keybindings()
end

function M.restart()
	if not state.delta_windows("restart") then
		return
	end
	actions.quit()
	vim.api.nvim_set_current_win(state.winid_on_leaving)
	if not (state.bufnr_on_leaving == vim.api.nvim_get_current_buf()) then
		print("Can't restart, window from which code was taken doesn't have the same buffer anymore.")
		return
	end
	if not vim.wait(5000, function()
		return state.interpreter_completed
	end) then
		return
	end
	M.start()
end

return M
