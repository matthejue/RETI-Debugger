local utils = require("reti-debugger.utils")
local windows = require("reti-debugger.windows")

local M = {}

M.completed = false
M.opts = {}
M.visible = true
M.handle = nil
M.interpreter_id = nil
M.stdin = nil 
M.stdout = nil 
M.stderr = nil 
M.current_popup = utils.get_key(windows.popups_order, "eprom")
M.registeres = ""

return M
