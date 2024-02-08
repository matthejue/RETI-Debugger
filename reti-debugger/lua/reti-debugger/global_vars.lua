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
M.eprom = ""

M.scrolling_modes = {
  autoscrolling = 1,
  memory_visible = 2
}

-- M.scrolling_mode = M.scolling_modes.autoscrolling
M.scrolling_mode = M.scrolling_modes.memory_visible

return M
