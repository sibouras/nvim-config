return {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
  keys = {
    { '<leader>gf', '<Cmd>DiffviewFileHistory %<CR>', desc = 'Diffview: Current File history' },
    { '<leader>gF', ':DiffviewFileHistory<CR>', mode = { 'n', 'x' }, desc = 'Diffview: File history' },
    { '<leader>go', '<Cmd>DiffviewOpen<CR>', desc = 'Diffview: Open' },
    { '<leader>gc', '<Cmd>DiffviewClose<CR>', desc = 'Diffview: Close' },
  },
}
