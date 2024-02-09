local Menu = require("nui.menu")
local global_vars = require("reti-debugger.global_vars")
local utils = require("reti-debugger.utils")

local M = {}

local popup_options = {
  relative = "editor",
  position = "50%",
  border = {
    style = "single",
    text = {
      top = "[Choose Mode]",
      top_align = "center",
    },
  },
}

M.menu = Menu(popup_options, {
  lines = {
    Menu.item("Autoscrolling", {id = global_vars.scrolling_modes.autoscrolling}),
    Menu.item("Memory Focus", {id = global_vars.scrolling_modes.memory_focus})
  },
  max_width = 20,
  keymap = {
    focus_next = { "j", "<down>", "<tab>", "m" },
    focus_prev = { "k", "<up>", "<s-tab>", "<s-m>" },
    close = { "<esc>", "<c-c>" },
    submit = { "<cr>", "<space>" },
  },
  on_submit = function(item)
    if item.id == global_vars.scrolling_modes.autoscrolling then
      global_vars.scrolling_mode = global_vars.scrolling_modes.autoscrolling
      utils.window_titles_autoscrolling()
    else -- item.id == global_vars.scrolling_modes.memory_focus
      utils.set_no_scrollbind()
      global_vars.first_focus_over = false
      global_vars.scrolling_mode = global_vars.scrolling_modes.memory_focus
      utils.window_titles_memory_focus()
    end
  end,
  should_skip_item = function(item)
    if item.id == global_vars.scrolling_mode then
      return true
    else
      return false
    end
  end
})

return M
