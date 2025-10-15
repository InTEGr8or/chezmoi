-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.o.guifont = "JetBrainsMono NF:h10"
vim.keymap.set("i", "<M-s>", "<Esc>", { desc = "Escape insert mode" })
vim.keymap.set("t", "<M-s>", "<C-\\><C-n>", { desc = "Escape terminal mode" })
vim.keymap.set("v", "<M-s>", "<Esc>", { desc = "Escape visual mode" })
