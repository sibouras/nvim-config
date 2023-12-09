return {
  {
    'rlane/pounce.nvim',
    enabled = true,
    keys = {
      { 's', '<cmd>Pounce<CR>', mode = { 'n', 'x', 'o' } },
      { 'S', '<cmd>PounceRepeat<CR>', mode = 'n' },
    },
    opts = {
      accept_keys = 'JKLSDFAGHNUVRBYTMICEOXWPQZ',
      accept_best_key = '<enter>',
      multi_window = true,
      debug = false,
    },
  },
}
