local Layout = require("nui.layout")
local Popup = require("nui.popup")
local utils = require("reti-debugger.utils")
local Input = require("nui.input")
local state = require("reti-debugger.state")
local Menu = require("nui.menu")

local M = {}

-- ┌────────┐
-- │ Layout │
-- └────────┘
local popup_options_layout = {
	enter = false,
	focusable = true,
	zindex = 50,
	border = {
		style = "single",
		text = {
			top_align = "center",
		},
	},
	buf_options = {
		modifiable = true,
		readonly = false,
	},
}

M.popups = {}
M.popups_order = { "registers", "registers_rel", "eprom", "uart", "sram1", "sram2", "sram3" }
M.current_popup = utils.get_key(M.popups_order, "eprom")

M.popups.registers = Popup(vim.tbl_deep_extend("keep", popup_options_layout, {
	border = {
		text = {
			top = "Registers",
		},
	},
}))
M.popups.registers_rel = Popup(vim.tbl_deep_extend("keep", popup_options_layout, {
	border = {
		text = {
			top = "Registers Relative",
		},
	},
}))
M.popups.eprom = Popup(vim.tbl_deep_extend("force", popup_options_layout, {
	enter = true,
	border = {
		text = {
			top = "EPROM",
		},
	},
}))
M.popups.uart = Popup(vim.tbl_deep_extend("keep", popup_options_layout, {
	border = {
		text = {
			top = "UART",
		},
	},
}))
M.popups.sram1 = Popup(vim.tbl_deep_extend("keep", popup_options_layout, {
	border = {
		text = {
			top = "SRAM Section 1",
		},
	},
}))
M.popups.sram2 = Popup(vim.tbl_deep_extend("keep", popup_options_layout, {
	border = {
		-- text = {
		--   top = "SRAM Section 2"
		-- }
	},
}))
M.popups.sram3 = Popup(vim.tbl_deep_extend("keep", popup_options_layout, {
	border = {
		-- text = {
		--   top = "SRAM Section 3"
		-- }
	},
}))

local width = vim.api.nvim_get_option("columns")
local height = vim.api.nvim_get_option("lines")

M.layout = Layout(
	{
		relative = "editor",
		position = "50%",
		size = {
			width = width,
			height = height,
		},
	},
	Layout.Box({
		Layout.Box(
			{
				Layout.Box(
					{
						Layout.Box(M.popups.registers, { size = "50%" }),
						Layout.Box(M.popups.registers_rel, { size = "52%" }), -- +2
					},
					{ size = "35%", dir = "row" }
				),
				Layout.Box(M.popups.eprom, { size = "45%" }),
				Layout.Box(M.popups.uart, { size = "22%" }), -- +2
			},
			{ size = "31%", dir = "col" }
		),
		Layout.Box(M.popups.sram1, { size = "23%" }),
		Layout.Box(M.popups.sram2, { size = "23%" }),
		Layout.Box(M.popups.sram3, { size = "25%" }), -- +2
	}, { size = "100%", dir = "row" })
)

-- ┌───────┐
-- │ Error │
-- └───────┘
M.error_window = Popup({
	enter = true,
	focusable = true,
	zindex = 75,
	relative = "editor",
	border = {
		style = "single",
		text = {
			top = "Error",
			top_align = "center",
		},
	},
	buf_options = {
		modifiable = true,
		readonly = false,
	},
	position = "50%",
	size = {
		width = "80%",
		height = "60%",
	},
})

-- ┌────────┐
-- │ Output │
-- └────────┘
M.output_window = Popup({
	enter = true,
	focusable = true,
	zindex = 75,
	relative = "editor",
	position = "50%",
	size = {
		width = "40%",
		height = "30%",
	},
	border = {
		style = "single",
		text = {
			top = "Output",
			top_align = "center",
		},
	},
	buf_options = {
		modifiable = true,
		readonly = false,
	},
})

-- ┌───────┐
-- │ Input │
-- └───────┘
local popup_options_input = {
	relative = "editor",
	position = "50%",
	zindex = 75,
	size = {
		width = "40%",
		height = "30%",
	},
	border = {
		style = "single",
		text = {
			top = "Input",
			top_align = "center",
		},
	},
	buf_options = {
		modifiable = true,
		readonly = false,
	},
}

M.input_window = Input(popup_options_input, {
	prompt = "> ",
	on_submit = function(val)
		if val == "" then
			val = "0"
		end
		vim.loop.write(state.stdin, val .. "\n")
    state.delta_actions("popup closed")
	end,
	on_change = function(val)
		if val == "-" or val == "" then
			return
		end
		if not tonumber(val) then
			local keys = vim.api.nvim_replace_termcodes("<BS>", true, false, true)
			vim.api.nvim_feedkeys(keys, "i", false)
		end
	end,
})

-- ┌────────────┐
-- │ Menu modes │
-- └────────────┘
function M.window_titles_autoscrolling()
	M.popups.sram2.border:set_text("top", "SRAM Section 2", "center")
	M.popups.sram3.border:set_text("top", "SRAM Section 3", "center")
end

function M.window_titles_memory_focus()
	M.popups.sram2.border:set_text("top", "SRAM Start Datasegment", "center")
	M.popups.sram3.border:set_text("top", "SRAM End Datasegment", "center")
end

local popup_options_menu = {
	relative = "editor",
	position = "50%",
	border = {
		style = "single",
		text = {
			top = "Choose Mode",
			top_align = "center",
		},
	},
}

local function set_no_scrollbind()
	vim.api.nvim_win_set_option(M.popups.sram1.winid, "scrollbind", false)
	vim.api.nvim_win_set_option(M.popups.sram2.winid, "scrollbind", false)
	vim.api.nvim_win_set_option(M.popups.sram3.winid, "scrollbind", false)
end

local keymap = {
	focus_next = { "j", "<down>", "<tab>", "m" },
	focus_prev = { "k", "<up>", "<s-tab>", "<s-m>" },
	close = { "<esc>", "q" },
	submit = { "<cr>", "<space>" },
}

M.menu_modes = Menu(popup_options_menu, {
	lines = {
		Menu.item("Autoscrolling", { id = state.scrolling_modes.autoscrolling }),
		Menu.item("Memory Focus", { id = state.scrolling_modes.memory_focus }),
	},
	max_width = 20,
	keymap = keymap,
	on_submit = function(item)
		if state.delta_mode(item.id) then
			M.window_titles_autoscrolling()
		else -- item.id == state.scrolling_modes.memory_focus
			set_no_scrollbind()
			M.window_titles_memory_focus()
		end
    state.delta_actions("popup closed")
	end,
	should_skip_item = function(item)
		if item.id == state.scrolling_mode then
			return true
		else
			return false
		end
	end,
  on_close = function()
    state.delta_actions("popup closed")
  end
})


-- ┌───────────────┐
-- │ Menu examples │
-- └───────────────┘
M.keys = {
	"bsearch_it",
	"bsearch_rec",
	"bubble_sort",
	"exercise_from_sheets1",
	"exercise_from_sheets2",
	"exercise_from_sheets3",
	"exercise_from_sheets4",
	"exercise_from_sheets5",
	"exercise_from_sheets6",
	"faculty_it",
	"faculty_rec",
	"fib_it",
	"fib_rec",
	"fib_rec_efficient",
	"gcd",
	"log2",
	"min_sort",
	"pair_sort",
	"pair_sort2",
	"power_it",
	"power_it_efficient",
	"power_rec",
	"power_rec_efficient",
	"prime_numbers",
	"simple_input_output",
}
M.examples = {
	["bsearch_it"] = 1,
	["bsearch_rec"] = 2,
	["bubble_sort"] = 3,
	["exercise_from_sheets1"] = 4,
	["exercise_from_sheets2"] = 5,
	["exercise_from_sheets3"] = 6,
	["exercise_from_sheets4"] = 7,
	["exercise_from_sheets5"] = 8,
	["exercise_from_sheets6"] = 9,
	["faculty_it"] = 10,
	["faculty_rec"] = 11,
	["fib_it"] = 12,
	["fib_rec"] = 13,
	["fib_rec_efficient"] = 14,
	["gcd"] = 15,
	["log2"] = 16,
	["min_sort"] = 17,
	["pair_sort"] = 18,
	["pair_sort2"] = 19,
	["power_it"] = 20,
	["power_it_efficient"] = 21,
	["power_rec"] = 22,
	["power_rec_efficient"] = 23,
	["prime_numbers"] = 24,
	["simple_input_output"] = 25,
}
M.example = nil

local lines = {}
for _, key in pairs(M.keys) do
	table.insert(lines, Menu.item(key, { id = M.examples[key] }))
end

popup_options_menu.border.text.top = "Choose Example"

M.menu_examples = Menu(popup_options_menu, {
	lines = lines,
	max_width = 30,
	keymap = keymap,
	on_submit = function(item)
		M.example = item.id
    vim.loop.async_send(state.async_event)
    state.delta_actions("popup closed")
	end,
	should_skip_item = function(item)
		if item.id == M.example then
			return true
		else
			return false
		end
	end,
  on_close = function()
    state.delta_actions("popup closed")
  end
})

return M
