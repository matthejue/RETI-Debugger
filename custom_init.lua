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
}

require("lazy").setup(plugins)
