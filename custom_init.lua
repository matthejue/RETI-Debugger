local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "

local plugins = {
  {
    "matthejue/RETI-Debugger",
    dependencies = { "MunifTanjim/nui.nvim" },
    config = function()
      require("reti-debugger").setup({
        keys = {
          hide = "<leader>ph",
          start = "<leader>ps",
          restart = "<leader>pr",
          compile = "<leader>pc"
        },
      })
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    }
  },
  {
    "rebelot/kanagawa.nvim",
    config = function()
      vim.cmd.colorscheme("kanagawa-wave")
    end
  }
}

require("lazy").setup(plugins)

vim.opt.termguicolors = true
