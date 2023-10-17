return {
  'mbbill/undotree',
  keys = {
    { '<F3>', ':UndotreeToggle<CR>', desc = 'Toggle UndoTree' },
  },
  config = function()
    vim.g.undotree_WindowLayout = 4
    vim.g.undotree_ShortIndicators = 1
    vim.g.undotree_SetFocusWhenToggle = 1
  end,
}
