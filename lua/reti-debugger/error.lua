local Popup = require("nui.popup")

local M = {}

M.errorwindow = Popup({
  enter = true,
  focusable = true,
  zindex = 75,
  border = {
    style = "single",
    text = {
      top = "Error",
      top_align = "center",
    }
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

return M
