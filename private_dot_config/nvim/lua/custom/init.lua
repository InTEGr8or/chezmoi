vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.notify("Custom config loaded!", vim.log.levels.INFO)
  end,
})
