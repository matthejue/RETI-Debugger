local Menu = require("nui.menu")
local global_vars = require("reti-debugger.global_vars")
local utils = require("reti-debugger.utils")

-- local width = vim.api.nvim_get_option("columns")
-- local height = vim.api.nvim_get_option("lines")

local M = {}

local popup_options = {
  relative = "editor",
  position = "50%",
  -- size = {
  --   width = width / 5,
  --   height = height / 5,
  -- },
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
    Menu.item("Autoscrolling"),
    Menu.item("Memory Focus")
  },
  max_width = 20,
  keymap = {
    focus_next = { "j", "<Down>", "<Tab>" },
    focus_prev = { "k", "<Up>", "<S-Tab>" },
    close = { "<Esc>", "<C-c>" },
    submit = { "<CR>", "<Space>" },
  },
  -- on_close = function()
  --   print("CLOSED")
  -- end,
  on_submit = function(item)
    if item.text == "Autoscrolling" then
      global_vars.scrolling_mode = global_vars.scrolling_modes.autoscrolling
    else -- Memory Focus
      utils.set_no_scrollbind()
      global_vars.first_focus_over = false
      global_vars.scrolling_mode = global_vars.scrolling_modes.memory_focus
    end
  end,
})

return M
