vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

-- Additional settings from .vimrc
vim.opt.number = true            -- Enable line numbers
vim.opt.syntax = 'on'            -- Enable syntax highlighting
vim.opt.tabstop = 2              -- Set tab width to 2 spaces
vim.opt.autoindent = true        -- Enable auto indent
vim.opt.expandtab = true         -- Convert tabs to spaces
vim.opt.softtabstop = 2          -- Number of spaces per tab when editing

-- Remap escape key in insert mode
vim.keymap.set('i', 'kj', '<Esc>', { noremap = true, silent = true })

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "nvchad.autocmds"

vim.schedule(function()
  require "mappings"
end)
