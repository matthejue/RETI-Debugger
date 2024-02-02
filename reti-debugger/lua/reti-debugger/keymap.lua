local windows = require("reti-debugger.windows")
local actions = require("reti-debugger.actions")

M = {}

function M.set_keybindings(keys)
  for _, popup in pairs(windows.popups) do
    vim.keymap.set("n", keys.next, actions.next, { buffer=popup.bufnr, silent = true })
  end
end

return M
