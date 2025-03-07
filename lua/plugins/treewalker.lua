return {
  'aaronik/treewalker.nvim',
  keys = {
    -- movement
    { mode = { 'n', 'v' }, '<C-Up>', '<cmd>Treewalker Up<cr>' },
    { mode = { 'n', 'v' }, '<C-Down>', '<cmd>Treewalker Down<cr>' },
    { mode = { 'n', 'v' }, '<C-Left>', '<cmd>Treewalker Left<cr>' },
    { mode = { 'n', 'v' }, '<C-Right>', '<cmd>Treewalker Right<cr>' },

    -- swapping
    { mode = 'n', '<C-S-Up>', '<cmd>Treewalker SwapUp<cr>' },
    { mode = 'n', '<C-S-Down>', '<cmd>Treewalker SwapDown<cr>' },
    { mode = 'n', '<C-S-Left>', '<cmd>Treewalker SwapLeft<cr>' },
    { mode = 'n', '<C-S-Right>', '<cmd>Treewalker SwapRight<cr>' },
  },

  opts = {
    -- Whether to briefly highlight the node after jumping to it
    highlight = true,

    -- How long should above highlight last (in ms)
    highlight_duration = 250,

    -- The color of the above highlight. Must be a valid vim highlight group.
    -- (see :h highlight-group for options)
    highlight_group = 'CursorLine',
  },
}
