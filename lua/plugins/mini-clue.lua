return {
  'echasnovski/mini.clue',
  event = 'VeryLazy',
  enabled = true,
  opts = function()
    local miniclue = require('mini.clue')

    -- for _, lhs in ipairs({ '[%', ']%', 'g%' }) do
    --   vim.keymap.del('n', lhs)
    -- end

    return {
      triggers = {
        -- Leader triggers
        { mode = 'n', keys = '<Leader>' },
        { mode = 'x', keys = '<Leader>' },

        { mode = 'n', keys = '[' },
        { mode = 'n', keys = ']' },
        { mode = 'x', keys = '[' },
        { mode = 'x', keys = ']' },

        -- Built-in completion
        { mode = 'i', keys = '<C-x>' },

        -- `g` key
        { mode = 'n', keys = 'g' },
        { mode = 'x', keys = 'g' },

        -- Marks
        { mode = 'n', keys = "'" },
        { mode = 'n', keys = '`' },
        { mode = 'x', keys = "'" },
        { mode = 'x', keys = '`' },

        -- Registers
        { mode = 'n', keys = '"' },
        { mode = 'x', keys = '"' },
        -- { mode = 'i', keys = '<C-r>' }, -- bug with macros
        { mode = 'c', keys = '<C-r>' },

        -- Window commands
        { mode = 'n', keys = '<C-w>' },

        -- `z` key
        { mode = 'n', keys = 'z' },
        { mode = 'x', keys = 'z' },
      },
      clues = {
        -- Enhance this by adding descriptions for <Leader> mapping groups
        { mode = 'n', keys = '<leader>f', desc = '+telescope' },
        { mode = 'n', keys = '<leader>g', desc = '+git' },
        { mode = 'x', keys = '<leader>g', desc = '+git' },
        { mode = 'n', keys = '<leader>l', desc = '+lsp' },
        { mode = 'n', keys = '<leader>q', desc = '+trouble' },
        { mode = 'n', keys = '<leader>u', desc = '+ui' },
        { mode = 'n', keys = 'zl', postkeys = 'z' },
        { mode = 'n', keys = 'zh', postkeys = 'z' },
        miniclue.gen_clues.z(),
        miniclue.gen_clues.builtin_completion(),
        miniclue.gen_clues.g(),
        miniclue.gen_clues.marks(),
        miniclue.gen_clues.registers(),
        miniclue.gen_clues.windows({
          submode_move = true,
          submode_navigate = true,
          submode_resize = true,
        }),
      },

      window = {
        -- Floating window config
        config = {
          width = 40,
        },
        -- Delay before showing clue window
        delay = 400,
        -- Keys to scroll inside the clue window
        scroll_down = '<C-d>',
        scroll_up = '<C-u>',
      },
    }
  end,
}
