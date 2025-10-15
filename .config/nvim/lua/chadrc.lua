-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.ui = {
  theme = 'gatekeeper',
  font = "JetBrainsMono Nerd Font",
  font_size = 12,

  -- Enable Nerd Font icons
  nvdash = {
    load_on_startup = true,
  },

  statusline = {
    theme = "default", -- default/vscode/vscode_colored/minimal
    separator_style = "default",
  },
}

M.base46 = {
	theme = "gatekeeper",

	-- hl_override = {
	-- 	Comment = { italic = true },
	-- 	["@comment"] = { italic = true },
	-- },
}

return M
