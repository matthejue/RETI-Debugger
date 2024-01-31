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

-- function that reads from named pipe and prints it
function read_from_pipe(pipe_name)
    local f = io.open("/tmp/" .. pipe_name, "r")
    local line = f:read("*a")
    f:close()
    return line
end

function write_to_pipe(command)
    local f = io.open("/tmp/command", "w")
    local line = f:write(command)
    f:close()
end

-- functiont that starts a asynchronous python script in background
function M.start_interpreter()
    -- named pipe has to created by the plugin, because only the plugin writes to it
    vim.fn.system("mkfifo /tmp/command")

    vim.fn.jobstart("/home/areo/Documents/Studium/PicoC-Compiler/src/main.py /home/areo/Documents/Studium/PicoC-Compiler/run/gcd.reti -S")
end

function M.next()
  -- send continue command to pipe
  write_to_pipe("next")
end

function M.update()
  local registers
  local eprom
  local uart
  local sram

  registers = read_from_pipe("registers")
  eprom = read_from_pipe("eprom")
  uart = read_from_pipe("uart")
  sram = read_from_pipe("sram")
  print(registers)
  print(eprom)
  print(uart)
  print(sram)
end

return M
