local M = {}

M.interpreter_completed = true
M.next_blocked = true
M.layout_visble = false
M.popup_visible = false

function M.delta(letter)
	if
		M.interpreter_completed
		and M.next_blocked
		and not M.layout_visble
		and not M.popup_visible
		and letter == "start"
	then -- 1
		M.interpreter_completed = false
		M.next_blocked = false
		M.layout_visble = true
		M.popup_visible = false
	elseif
		not M.interpreter_completed
		and not M.next_blocked
		and M.layout_visble
		and not M.popup_visible
		and letter == "terminate"
	then -- 2
		M.interpreter_completed = true
		M.next_blocked = true
		M.layout_visble = true
		M.popup_visible = false
	elseif
		not M.interpreter_completed
		and not M.next_blocked
		and M.layout_visble
		and not M.popup_visible
		and letter == "hide"
	then -- 3
		M.interpreter_completed = false
		M.next_blocked = true
		M.layout_visble = false
		M.popup_visible = false
	elseif
		not M.interpreter_completed
		and not M.next_blocked
		and M.layout_visble
		and not M.popup_visible
		and letter == "popup appears"
	then -- 4
		M.interpreter_completed = false
		M.next_blocked = true
		M.layout_visble = true
		M.popup_visible = true
	elseif
		M.interpreter_completed
		and M.next_blocked
		and M.layout_visble
		and not M.popup_visible
		and letter == "hide"
	then -- 5
		M.interpreter_completed = false
		M.next_blocked = false
		M.layout_visble = true
		M.popup_visible = true
	elseif
		M.interpreter_completed
		and M.next_blocked
		and M.layout_visble
		and not M.popup_visible
		and letter == "restart"
	then -- 6
		M.interpreter_completed = false
		M.next_blocked = false
		M.layout_visble = true
		M.popup_visible = false
	elseif
		not M.interpreter_completed
		and M.next_blocked
		and not M.layout_visble
		and not M.popup_visible
		and letter == "show"
	then -- 7
		M.interpreter_completed = false
		M.next_blocked = false
		M.layout_visble = true
		M.popup_visible = false
	elseif
		not M.interpreter_completed
		and M.next_blocked
		and M.layout_visble
		and M.popup_visible
		and letter == "popup closed"
	then -- 8
		M.interpreter_completed = false
		M.next_blocked = false
		M.layout_visble = true
		M.popup_visible = false
	elseif
		M.interpreter_completed
		and M.next_blocked
		and not M.layout_visble
		and not M.popup_visible
		and letter == "show"
	then -- 9
		M.interpreter_completed = true
		M.next_blocked = true
		M.layout_visble = true
		M.popup_visible = false
	end
end

return M
