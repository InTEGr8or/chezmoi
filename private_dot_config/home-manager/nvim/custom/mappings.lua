local M = {}

M.general = {
  i = {
    -- Insert mode mapping
    ["<A-s>"] = { "<ESC>", "escape using alt-s" },
  },
  n = {
    -- Normal mode mapping
    ["<A-s>"] = { "<ESC>", "escape using alt-s" },
  },
  v = {
    -- Visual mode mapping
    ["<A-s>"] = { "<ESC>", "escape using alt-s" },
  },
}

return M
