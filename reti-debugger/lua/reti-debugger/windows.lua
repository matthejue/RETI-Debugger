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
M.popups_order = { "registers", "registers_rel", "eprom", "uart", "sram1", "sram2", "sram3" }

M.popups.registers = Popup(vim.tbl_deep_extend("force", popup_options,
  {
    border = {
      text = {
        top = "Registers"
      }
    }
  }))
M.popups.registers_rel = Popup(vim.tbl_deep_extend("force", popup_options,
  {
    border = {
      text = {
        top = "Registers Relative"
      }
    }
  }))
M.popups.eprom = Popup(vim.tbl_deep_extend("force", popup_options,
  {
    -- enter = true,
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
M.popups.sram1 = Popup(vim.tbl_deep_extend("keep", popup_options,
  {
    border = {
      text = {
        top = "SRAM Section 1"
      }
    }
  }))
M.popups.sram2 = Popup(vim.tbl_deep_extend("keep", popup_options,
  {
    border = {
      text = {
        top = "SRAM Section 2"
      }
    }
  }))
M.popups.sram3 = Popup(vim.tbl_deep_extend("keep", popup_options,
  {
    border = {
      text = {
        top = "SRAM Section 3"
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
    Layout.Box(
      {
        Layout.Box(
          {
            Layout.Box(M.popups.registers, { size = "52%" }),
            Layout.Box(M.popups.registers_rel, { size = "50%" })
          },
          { size = "37%", dir = "row" } -- +2
        ),
        Layout.Box(M.popups.eprom, { size = "45%" }),
        Layout.Box(M.popups.uart, { size = "20%" }),
      },
      { size = "33%", dir = "col" } -- +2
    ),
    Layout.Box(M.popups.sram1, { size = "23%" }),
    Layout.Box(M.popups.sram2, { size = "23%" }),
    Layout.Box(M.popups.sram3, { size = "23%" }),
  }, { size = "100%", dir = "row" })
)

return M
