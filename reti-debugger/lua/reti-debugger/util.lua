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

return M
