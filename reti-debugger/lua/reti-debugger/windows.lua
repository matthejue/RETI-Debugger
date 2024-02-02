local Layout = require("nui.layout")

local M = {}

local Popup = require("nui.popup")

local popup_options = {
  enter = false,
  focusable = true,
  zindex = 50,
  buf_options = {
    modifiable = true,
    readonly = false,
  },
}

M.popup_registers = Popup(vim.tbl_extend("force", popup_options,
  {
    enter = true,
    border = {
      style = "single",
      text = {
        top_align = "center",
        top = "Registers"
      }
    }
  }))
M.popup_eprom = Popup(vim.tbl_extend("keep", popup_options,
  {
    border = {
      style = "single",
      text = {
        top_align = "center",
        top = "EPROM"
      }
    }
  }))
M.popup_uart = Popup(vim.tbl_extend("keep", popup_options,
  {
    border = {
      style = "single",
      text = {
        top_align = "center",
        top = "UART"
      }
    }
  }))
M.popup_sram = Popup(vim.tbl_extend("keep", popup_options,
  {
    border = {
      style = "single",
      text = {
        top_align = "center",
        top = "SRAM"
      }
    }
  }))
M.popup_sram2 = Popup(vim.tbl_extend("keep", popup_options,
  {
    border = {
      style = "single",
      text = {
        top_align = "center",
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
    Layout.Box(M.popup_registers, { size = "20%" }), -- +1
    Layout.Box({
        Layout.Box(M.popup_eprom, { size = "50%" }),
        Layout.Box(M.popup_uart, { size = "52%" }), -- +2
      },
      { size = "27%", dir = "col" }
    ),
    Layout.Box(M.popup_sram, { size = "27%" }),
    Layout.Box(M.popup_sram2, { size = "27%" }),
  }, { size = "100%", dir = "row" })
)

return M
