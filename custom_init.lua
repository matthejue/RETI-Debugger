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
          load_example = "<leader>pl",
          compile = "<leader>pc",
          start = "<leader>ps",
          hide = "<leader>ph"
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
