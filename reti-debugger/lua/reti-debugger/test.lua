local Layout = require("nui.layout")

local layout = Layout(
  {
    position = "50%",
    size = {
      width = 80,
      height = 40,
    },
  },
  Layout.Box({
    Layout.Box(top_popup, { size = "40%" }),
    Layout.Box({
      Layout.Box(bottom_left_popup, { size = "50%" }),
      Layout.Box(bottom_right_popup, { size = "50%" }),
    }, { dir = "row", size = "60%" }),
  }, { dir = "col" })
)

return { layout = layout }
