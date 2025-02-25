return {
  'echasnovski/mini.surround',
  event = 'VeryLazy',
  opts = {
    mappings = {
      add = 'ms', -- Add surrounding in Normal and Visual modes
      delete = 'md', -- Delete surrounding
      find = 'mf', -- Find surrounding (to the right)
      find_left = 'mF', -- Find surrounding (to the left)
      highlight = 'mh', -- Highlight surrounding
      replace = 'mr', -- Replace surrounding
      update_n_lines = 'mn', -- Update `n_lines`

      suffix_last = 'N', -- Suffix to search with "prev" method
      suffix_next = 'n', -- Suffix to search with "next" method
    },
    -- Whether to respect selection type:
    -- - Place surroundings on separate lines in linewise mode.
    -- - Place surroundings on each line in blockwise mode.
    respect_selection_type = true,
  },
}
