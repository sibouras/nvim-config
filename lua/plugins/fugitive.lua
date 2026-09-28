return {
  'tpope/vim-fugitive',
  lazy = false,
  keys = {
    { '<leader>gd', '<Cmd>Gvdiffsplit!<CR>', desc = 'Fugitive: diff split' },
    { '<leader>gb', '<Cmd>G blame<CR>', desc = 'Fugitive: blame' },
  },
}
