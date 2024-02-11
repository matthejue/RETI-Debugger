local M = {}

M.completed = false
M.next_blocked = false
M.opts = {}
M.visible = true
M.handle = nil
M.interpreter_id = nil
M.stdin = nil
M.stdout = nil
M.stderr = nil

M.registers = ""
M.eprom = ""

M.scrolling_modes = {
  autoscrolling = 1,
  memory_focus = 2
}
M.scrolling_mode = M.scrolling_modes.memory_focus

M.winid_on_leaving = nil
M.bufnr_on_leaving = nil

M.first_focus_over = false

return M
