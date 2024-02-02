local Layout = require("nui.layout")
local Popup = require("nui.popup")

local M = {}

local popup_options = {
  enter = false,
  focusable = true,
  zindex = 50,
  border = {
    style = "single",
    text = {
      top_align = "center",
    }
  },
  buf_options = {
    modifiable = true,
    readonly = false,
  },
}

M.popups = {}

M.popups.registers = Popup(vim.tbl_deep_extend("force", popup_options,
  {
    enter = true,
    border = {
      text = {
        top = "Registers"
      }
    }
  }))
M.popups.eprom = Popup(vim.tbl_deep_extend("keep", popup_options,
  {
    border = {
      text = {
        top = "EPROM"
      }
    }
  }))
M.popups.uart = Popup(vim.tbl_deep_extend("keep", popup_options,
  {
    border = {
      text = {
        top = "UART"
      }
    }
  }))
M.popups.sram = Popup(vim.tbl_deep_extend("keep", popup_options,
  {
    border = {
      text = {
        top = "SRAM"
      }
    }
  }))
M.popups.sram2 = Popup(vim.tbl_deep_extend("keep", popup_options,
  {
    border = {
      text = {
        top = "SRAM"
      }
    }
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
    Layout.Box(M.popups.registers, { size = "20%" }), -- +1
    Layout.Box({
        Layout.Box(M.popups.eprom, { size = "50%" }),
        Layout.Box(M.popups.uart, { size = "52%" }), -- +2
      },
      { size = "27%", dir = "col" }
    ),
    Layout.Box(M.popups.sram, { size = "27%" }),
    Layout.Box(M.popups.sram2, { size = "27%" }),
  }, { size = "100%", dir = "row" })
)

return M
