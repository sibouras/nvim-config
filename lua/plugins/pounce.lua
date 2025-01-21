return {
  {
    'rlane/pounce.nvim',
    enabled = true,
    keys = {
      { 's', '<Cmd>Pounce<CR>', mode = { 'n', 'x', 'o' } },
      { 'S', '<Cmd>PounceRepeat<CR>', mode = 'n' },
      { 'gw', '<Cmd>PounceExpand <cword><CR>', mode = 'n', desc = 'Pounce with the current word' },
      { 'gw', 'y<Cmd>PounceReg "<CR>', mode = 'x', desc = 'Pounce using the selection as the input' },
    },
    opts = {
      accept_keys = 'JKLSDFAGHNUVRBYTMICEOXWPQZ',
      accept_best_key = '<enter>',
      multi_window = true,
      debug = false,
    },
  },
}
