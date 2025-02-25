return {
  'aaronik/treewalker.nvim',
  keys = {
    -- movement
    { mode = { 'n', 'v' }, '<M-Up>', '<cmd>Treewalker Up<cr>' },
    { mode = { 'n', 'v' }, '<M-Down>', '<cmd>Treewalker Down<cr>' },
    { mode = { 'n', 'v' }, '<M-Left>', '<cmd>Treewalker Left<cr>' },
    { mode = { 'n', 'v' }, '<M-Right>', '<cmd>Treewalker Right<cr>' },

    -- swapping
    { mode = 'n', '<M-S-Up>', '<cmd>Treewalker SwapUp<cr>' },
    { mode = 'n', '<M-S-Down>', '<cmd>Treewalker SwapDown<cr>' },
    { mode = 'n', '<M-S-Left>', '<cmd>Treewalker SwapLeft<cr>' },
    { mode = 'n', '<M-S-Right>', '<cmd>Treewalker SwapRight<cr>' },
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
