return {
  'dhruvasagar/vim-buffer-history',
  event = { 'BufReadPre', 'BufNewFile' },
  keys = {
    { '<M-Right>', '<Cmd>BufferHistoryForward<CR>', mode = { 'i', 'n' }, desc = 'Buffer History Forward' },
    { '<M-Left>', '<Cmd>BufferHistoryBack<CR>', mode = { 'i', 'n' }, desc = 'Buffer History Back' },
    { '<M-Home>', '<Cmd>BufferHistoryList<CR>', mode = { 'i', 'n' }, desc = 'Buffer History List' },
  },
}
