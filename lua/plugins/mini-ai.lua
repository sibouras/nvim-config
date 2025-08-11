return {
  'echasnovski/mini.ai',
  event = 'VeryLazy',
  dependencies = {
    'echasnovski/mini.extra',
    'nvim-treesitter/nvim-treesitter-textobjects',
  },

  opts = function()
    local gen_spec = require('mini.ai').gen_spec
    local gen_spec_extra = require('mini.extra').gen_ai_spec

    return {
      -- Table with textobject id as fields, textobject specification as values.
      -- Also use this to disable builtin textobjects. See |MiniAi.config|.
      custom_textobjects = {
        j = gen_spec.treesitter({ -- code block
          a = { '@block.outer', '@conditional.outer', '@loop.outer' },
          i = { '@block.inner', '@conditional.inner', '@loop.inner' },
        }),
        m = gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }), -- method
        f = gen_spec.treesitter({ a = '@call.outer', i = '@call.inner' }), -- function call
        x = gen_spec.treesitter({ a = '@attribute.outer', i = '@attribute.inner' }),
        -- c = gen_spec.treesitter({ a = '@class.outer', i = '@class.inner' }),
        c = gen_spec.treesitter({ a = '@comment.outer', i = '@comment.inner' }),
        ['='] = gen_spec.treesitter({ a = '@assignment.outer', i = '@assignment.inner' }),
        o = { { "%b''", '%b""', '%b``' }, '^.().*().$' }, -- Quotes
        e = { -- Word with camel case
          { '%u[%l%d]+%f[^%l%d]', '%f[%S][%l%d]+%f[^%l%d]', '%f[%P][%l%d]+%f[^%l%d]', '^[%l%d]+%f[^%l%d]' },
          '^().*()$',
        },
        -- mini.extra
        i = gen_spec_extra.indent(),
        d = gen_spec_extra.diagnostic(),
        g = gen_spec_extra.buffer(),
        L = gen_spec_extra.line(),
        N = gen_spec_extra.number(),
      },

      -- Module mappings. Use `''` (empty string) to disable one.
      mappings = {
        -- Main textobject prefixes
        around = 'a',
        inside = 'i',

        -- Next/last variants
        around_next = 'an',
        inside_next = 'in',
        around_last = 'al',
        inside_last = 'il',

        -- Move cursor to corresponding edge of `a` textobject
        goto_left = 'g[',
        goto_right = 'g]',
      },

      -- Number of lines within which textobject is searched
      n_lines = 100,

      -- How to search for object (first inside current line, then inside
      -- neighborhood). One of 'cover', 'cover_or_next', 'cover_or_prev',
      -- 'cover_or_nearest', 'next', 'previous', 'nearest'.
      search_method = 'cover_or_next',

      -- Whether to disable showing non-error feedback
      silent = false,
    }
  end,
}
