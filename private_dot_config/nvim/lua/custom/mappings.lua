local M = {}

M.general = {
  i = {
    ["<A-s>"] = { "<ESC>", "Exit insert mode with Alt-s" },
  },
  
  n = {
    ["<C-h>"] = { "<C-w>h", "Window left" },
    ["<C-l>"] = { "<C-w>l", "Window right" },
    ["<C-j>"] = { "<C-w>j", "Window down" },
    ["<C-k>"] = { "<C-w>k", "Window up" },
  },
}

return M
