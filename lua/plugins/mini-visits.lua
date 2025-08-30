return {
  'nvim-mini/mini.visits',
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

    local map = function(lhs, call, desc)
      local rhs = '<Cmd>lua MiniVisits.' .. call .. '<CR>'
      vim.keymap.set('n', lhs, rhs, { desc = desc })
    end

    map('<leader>vv', 'add_path()', 'MiniVisits Add path')
    map('<leader>vV', 'remove_path()', 'MiniVisits Remove path')

    -- Select approach keymaps
    local make_select_path = function(select_global, recency_weight)
      local visits = require('mini.visits')
      local sort = visits.gen_sort.default({ recency_weight = recency_weight })
      local select_opts = { sort = sort }
      return function()
        local cwd = select_global and '' or vim.fs.normalize(vim.fn.getcwd())
        visits.select_path(cwd, select_opts)
      end
    end

    local map_select = function(lhs, desc, ...)
      vim.keymap.set('n', lhs, make_select_path(...), { desc = desc })
    end

    map_select('<leader>vR', 'MiniVisits select recent (all)', true, 1)
    map_select('<leader>vr', 'MiniVisits select recent (cwd)', false, 1)
    map_select('<leader>vS', 'MiniVisits select frecent (all)', true, 0.5)
    map_select('<leader>vs', 'MiniVisits select frecent (cwd)', false, 0.5)
    map_select('<leader>vF', 'MiniVisits select frequent (all)', true, 0)
    map_select('<leader>vf', 'MiniVisits select frequent (cwd)', false, 0)
  end,
}
