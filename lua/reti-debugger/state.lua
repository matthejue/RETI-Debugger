local M = {}

M.interpreter_completed = true
M.next_blocked = true
M.layout_visible = false
M.popup_visible = false

function M.delta_windows(letter)
	if
		M.interpreter_completed
		-- and M.next_blocked
		and not M.layout_visible
		-- and not M.popup_visible
		and letter == "start"
	then -- 1
		M.interpreter_completed = false
		M.next_blocked = false
		M.layout_visible = true
		-- M.popup_visible = false
		return true
  elseif
		M.interpreter_completed
		-- and M.next_blocked
		and not M.layout_visible
		-- and not M.popup_visible
		and (letter == "load example" or letter == "compile")
	then -- 1
		-- M.interpreter_completed = false
		-- M.next_blocked = false
		-- M.layout_visible = true
		-- M.popup_visible = false
		return true
	elseif
		-- not M.interpreter_completed
		-- and not M.next_blocked
		-- and M.layout_visble
		-- and not M.popup_visible
		-- and
		letter == "complete"
	then -- 2
		M.interpreter_completed = true
		M.next_blocked = true
		-- M.layout_visble = true
		-- M.popup_visible = false
		return true
	elseif
		-- not M.interpreter_completed
		-- and
		-- not M.next_blocked
		-- and
		M.layout_visible
		and not M.popup_visible
		and letter == "hide"
	then -- 3
		-- M.interpreter_completed = false
		-- M.next_blocked = true
		M.layout_visible = false
		-- M.popup_visible = false
		return true
	elseif
		-- not M.interpreter_completed
		-- and
		-- not M.next_blocked
		-- and
		-- M.layout_visible
		-- and not M.popup_visible
		-- and
		letter == "popup appears"
	then -- 4
		-- M.interpreter_completed = false
		M.next_blocked = true
		-- M.layout_visible = true
		M.popup_visible = true
		return true
	elseif
		-- not M.interpreter_completed
		-- and
		not M.next_blocked
		-- and M.layout_visible
		and not M.popup_visible
		and letter == "next"
	then
		-- M.interpreter_completed = false
		-- M.next_blocked = false
		-- M.layout_visible = true
		-- M.popup_visible = false
		return true
	-- elseif
	-- 	not M.interpreter_completed
	-- 	-- and not M.next_blocked
	-- 	-- and M.layout_visible
	--    and not M.popup_visible
	-- 	and letter == "restart"
	-- then
	-- 	-- M.interpreter_completed = false
	-- 	-- M.next_blocked = false
	-- 	-- M.layout_visible = true
	-- 	-- M.popup_visible = false
	-- 	return true
	elseif
		-- not M.interpreter_completed
		-- and not M.next_blocked
		-- and M.layout_visible
		-- and
		not M.popup_visible and letter == "quit"
	then -- 5
		-- M.interpreter_completed = true
		M.next_blocked = true
		M.layout_visible = false
		-- M.popup_visible = false
		return true
		-- elseif
		-- 	M.interpreter_completed
		-- 	and M.next_blocked
		-- 	and M.layout_visible
		-- 	and not M.popup_visible
		-- 	and letter == "hide"
		-- then -- 6
		-- 	M.interpreter_completed = false
		-- 	M.next_blocked = false
		-- 	M.layout_visible = true
		-- 	M.popup_visible = true
	elseif
		-- M.interpreter_completed
		-- and M.next_blocked
		-- and M.layout_visible
		-- and
		not M.popup_visible and letter == "restart"
	then -- 6
		-- done by start function called within restart
		-- 	M.interpreter_completed = false
		-- 	M.next_blocked = false
		-- 	M.layout_visible = true
		-- M.popup_visible = false
		return true
		-- elseif
		-- 	M.interpreter_completed
		-- 	and M.next_blocked
		-- 	and M.layout_visible
		-- 	and not M.popup_visible
		-- 	and letter == "quit"
		-- then -- 8
		-- 	M.interpreter_completed = true
		-- 	M.next_blocked = true
		-- 	M.layout_visible = false
		-- 	M.popup_visible = false
	elseif
		-- not M.interpreter_completed
		-- and M.next_blocked
		-- and
		not M.layout_visible
		-- and not M.popup_visible
		and letter == "show"
	then -- 7
		-- M.interpreter_completed = false
		-- M.next_blocked = false
		M.layout_visible = true
		-- M.popup_visible = false
		return true
	elseif
		-- not M.interpreter_completed
		-- and M.next_blocked
		-- and M.layout_visible
		-- and M.popup_visible
		-- and
		letter == "popup closed"
	then -- 8
		-- M.interpreter_completed = false
		M.next_blocked = false
		-- M.layout_visible = true
		M.popup_visible = false
		return true
		-- elseif
		-- 	M.interpreter_completed
		-- 	and M.next_blocked
		-- 	and not M.layout_visible
		-- 	and not M.popup_visible
		-- 	and letter == "show"
		-- then -- 9
		-- 	M.interpreter_completed = true
		-- 	M.next_blocked = true
		-- 	M.layout_visible = true
		-- 	M.popup_visible = false
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

return M
