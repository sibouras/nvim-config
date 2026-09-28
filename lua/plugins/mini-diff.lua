return {
  'nvim-mini/mini.diff',
  event = 'LazyFile',
  keys = {
    { '<leader>gp', '<Cmd>lua MiniDiff.toggle_overlay()<CR>', desc = 'MiniDiff: toggle overlay' },
  },
  opts = {
    view = {
      -- Visualization style. Possible values are 'sign' and 'number'.
      style = 'sign',

      -- Signs used for hunks with 'sign' view
      signs = { add = '▎', change = '▎', delete = '▎' },
    },

    -- Delays (in ms) defining asynchronous processes
    delay = {
      -- How much to wait before update following every text change
      text_change = 200,
    },

    -- Module mappings. Use `''` (empty string) to disable one.
    mappings = {
      -- Apply hunks inside a visual/operator region
      apply = 'gp',

      -- Reset hunks inside a visual/operator region
      reset = 'gP',

      -- Hunk range textobject to be used inside operator
      -- Works also in Visual mode if mapping differs from apply and reset
      textobject = 'gp',

      -- Go to hunk range in corresponding direction
      goto_first = '[G',
      goto_prev = '',
      goto_next = '',
      goto_last = ']G',
    },
  },
}
