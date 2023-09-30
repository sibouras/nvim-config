return {
  {
    'rlane/pounce.nvim',
    keys = {
      { 's', '<cmd>Pounce<CR>', mode = { 'n', 'x' } },
      { 'S', '<cmd>PounceRepeat<CR>', mode = 'n' },
      { 'gs', '<cmd>Pounce<CR>', mode = 'o' },
    },
    opts = {
      accept_keys = 'JKLSDFAGHNUVRBYTMICEOXWPQZ',
      accept_best_key = '<enter>',
      multi_window = true,
      debug = false,
    },
  },
}
