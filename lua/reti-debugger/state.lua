local M = {}

M.interpreter_terminated = true
M.layout_visible = false
M.popup_visible = false

function M.delta_actions(input_sym)
	if
		M.interpreter_terminated
		and not M.layout_visible
		and input_sym == "start"
	then
		M.interpreter_terminated = false
		M.layout_visible = true
		return true
  elseif
		M.interpreter_terminated
		and not M.layout_visible
		and (input_sym == "load" or input_sym == "compile")
	then
		return true
	elseif
		input_sym == "complete"
	then
		M.interpreter_terminated = true
		return true
	elseif
		M.layout_visible
		and not M.popup_visible
		and input_sym == "hide"
	then
		M.layout_visible = false
		return true
	elseif
		input_sym == "popup appears"
	then
		M.popup_visible = true
		return true
	elseif
		not M.popup_visible
		and input_sym == "next"
	then
		return true
	elseif
		not M.popup_visible and input_sym == "restart"
	then
		return true
	elseif
		M.layout_visible and not M.popup_visible and input_sym == "layout"
	then
		return true
	elseif
		not M.popup_visible and input_sym == "quit"
	then
		M.layout_visible = false
		return true
	elseif
		not M.layout_visible
		and input_sym == "show"
	then
		M.layout_visible = true
		return true
	elseif
		input_sym == "popup closed"
	then
		M.popup_visible = false
		return true
	end
	return false
end

M.first_focus_over = false

function M.delta_focus(letter)
	if
		-- M.first_focus_over
		-- and
		letter == "start"
	then
		M.first_focus_over = false
		return true
	elseif not M.first_focus_over and letter == "first focus" then
		M.first_focus_over = true
		return true
	end
	return false
end

M.scrolling_modes = {
	autoscrolling = 1,
	memory_focus = 2,
}
M.scrolling_mode = M.scrolling_modes.memory_focus

function M.delta_mode(letter)
	if letter == M.scrolling_modes.autoscrolling then
    M.scrolling_mode = M.scrolling_modes.autoscrolling
    return true
	elseif letter == M.scrolling_modes.memory_focus then
    M.first_focus_over = false
    M.scrolling_mode = M.scrolling_modes.memory_focus
    return false
	end
end

M.opts = {}
M.handle = nil
M.interpreter_id = nil
M.stdin = nil
M.stdout = nil
M.stderr = nil

M.registers = ""
M.eprom = ""

M.winid_on_leaving = nil
M.bufnr_on_leaving = nil

M.first_focus_over = false

M.async_event = nil

M.timer = nil

M.width = 0
M.height = 0

return M
