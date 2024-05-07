return {
  'echasnovski/mini.visits',
  opts = {
    -- How visit index is converted to list of paths
    list = {
      -- Predicate for which paths to include (all by default)
      filter = nil,
      -- Sort paths based on the visit data (robust frecency by default)
      sort = nil,
    },

    -- Whether to disable showing non-error feedback
    silent = false,

    -- How visit index is stored
    store = {
      -- Whether to write all visits before Neovim is closed
      autowrite = true,
      -- Function to ensure that written index is relevant
      normalize = nil,
      -- Path to store visit index
      path = vim.fn.stdpath('data') .. '/mini-visits-index',
    },

    -- How visit tracking is done
    track = {
      -- Start visit register timer at this event
      -- Supply empty string (`''`) to not do this automatically
      event = 'BufEnter',
      -- Debounce delay after event to register a visit
      delay = 1000,
    },
  },
  config = function(opts)
    local minivisits = require('mini.visits')
    minivisits.setup(opts)

    -- Create and select
    local map_vis = function(keys, call, desc)
      local rhs = '<Cmd>lua MiniVisits.' .. call .. '<CR>'
      vim.keymap.set('n', '<Leader>' .. keys, rhs, { desc = desc })
    end

    map_vis('vs', 'select_path()', 'MiniVisits Select path')
    map_vis('vv', 'add_path()', 'MiniVisits Add path')
    map_vis('vV', 'remove_path()', 'MiniVisits Remove path')
  end,
}
