local M = {}

M.completed = true
M.next_blocked = true
M.opts = {}
M.visible = false
M.handle = nil
M.interpreter_id = nil
M.stdin = nil
M.stdout = nil
M.stderr = nil

M.registers = ""
M.eprom = ""

M.scrolling_modes = {
	autoscrolling = 1,
	memory_focus = 2,
}
M.scrolling_mode = M.scrolling_modes.memory_focus

M.winid_on_leaving = nil
M.bufnr_on_leaving = nil

M.first_focus_over = false

M.async_event = nil

return M
