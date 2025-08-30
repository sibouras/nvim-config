return {
  'nvim-mini/mini.pairs',
  event = 'VeryLazy',
  keys = {
    {
      '<M-a>',
      function()
        vim.g.minipairs_disable = not vim.g.minipairs_disable
        if vim.g.minipairs_disable then
          vim.notify('Disabled auto pairs')
        else
          vim.notify('Enabled auto pairs')
        end
      end,
      mode = { 'n', 'i' },
      desc = 'Toggle auto pairs',
    },
  },
  opts = {
    modes = { insert = true, command = true, terminal = false },
    mappings = {
      -- Alternative default config: https://github.com/nvim-mini/mini.nvim/issues/835

      -- insert whole pair if left character is not `\` and if right character is whitespace.
      -- So it will not insert whole pair if directly before any non-whitespace character.
      ['('] = { action = 'open', pair = '()', neigh_pattern = '[^\\][%s%)%]%}]' },
      ['['] = { action = 'open', pair = '[]', neigh_pattern = '[^\\][%s%)%]%}]' },
      ['{'] = { action = 'open', pair = '{}', neigh_pattern = '[^\\][%s%)%]%}]' },
      -- This is default (prevents the action if the cursor is after `\`).
      [')'] = { action = 'close', pair = '()', neigh_pattern = '[^\\].' },
      [']'] = { action = 'close', pair = '[]', neigh_pattern = '[^\\].' },
      ['}'] = { action = 'close', pair = '{}', neigh_pattern = '[^\\].' },
      -- do not insert whole pair after an alphanumeric character or `\`, and before an alphanumeric character
      ['"'] = { action = 'closeopen', pair = '""', neigh_pattern = '[^%w\\][^%w]', register = { cr = false } },
      ["'"] = { action = 'closeopen', pair = "''", neigh_pattern = '[^%w\\][^%w]', register = { cr = false } },
      ['`'] = { action = 'closeopen', pair = '``', neigh_pattern = '[^%w\\][^%w]', register = { cr = false } },
    },
  },
}
