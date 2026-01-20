return {
  'mistweaverco/bafa.nvim',
  enabled = false,
  config = function()
    vim.keymap.set(
      'n',
      '<leader>i',
      ':lua require("bafa.ui").toggle()<CR>',
      { desc = 'Toggle bafa', noremap = true, silent = true }
    )
  end,
}
