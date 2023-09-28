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
    config = function()
      vim.cmd([[
        highlight PounceAccept gui=bold guifg=#ffffff guibg=#3F00FF
        highlight PounceAcceptBest gui=bold guifg=#ffffff guibg=#FF2400
      ]])
    end,
  },
}
