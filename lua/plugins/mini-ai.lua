return {
  'echasnovski/mini.ai',
  event = 'VeryLazy',
  dependencies = 'nvim-treesitter/nvim-treesitter-textobjects',

  opts = function()
    local miniai = require('mini.ai')

    -- Mini.ai indent text object
    -- For "a", it will include the non-whitespace line surrounding the indent block.
    -- "a" is line-wise, "i" is character-wise.
    ---@alias Mini.ai.loc {line:number, col:number}
    ---@alias Mini.ai.region {from:Mini.ai.loc, to:Mini.ai.loc}
    local function ai_indent(ai_type)
      local spaces = (' '):rep(vim.o.tabstop)
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      local indents = {} ---@type {line: number, indent: number, text: string}[]

      for l, line in ipairs(lines) do
        if not line:find('^%s*$') then
          indents[#indents + 1] = { line = l, indent = #line:gsub('\t', spaces):match('^%s*'), text = line }
        end
      end

      local ret = {} ---@type (Mini.ai.region | {indent: number})[]

      for i = 1, #indents do
        if i == 1 or indents[i - 1].indent < indents[i].indent then
          local from, to = i, i
          for j = i + 1, #indents do
            if indents[j].indent < indents[i].indent then
              break
            end
            to = j
          end
          from = ai_type == 'a' and from > 1 and from - 1 or from
          to = ai_type == 'a' and to < #indents and to + 1 or to
          ret[#ret + 1] = {
            indent = indents[i].indent,
            from = { line = indents[from].line, col = ai_type == 'a' and 1 or indents[from].indent + 1 },
            to = { line = indents[to].line, col = #indents[to].text },
          }
        end
      end

      return ret
    end

    return {
      -- Table with textobject id as fields, textobject specification as values.
      -- Also use this to disable builtin textobjects. See |MiniAi.config|.
      custom_textobjects = {
        j = miniai.gen_spec.treesitter({ -- code block
          a = { '@block.outer', '@conditional.outer', '@loop.outer' },
          i = { '@block.inner', '@conditional.inner', '@loop.inner' },
        }),
        m = miniai.gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }), -- method
        f = miniai.gen_spec.treesitter({ a = '@call.outer', i = '@call.inner' }), -- function call
        c = miniai.gen_spec.treesitter({ a = '@class.outer', i = '@class.inner' }), -- class
        ['='] = miniai.gen_spec.treesitter({ a = '@assignment.outer', i = '@assignment.inner' }), -- assignment
        -- b = { { '%b()', '%b[]', '%b{}' }, '^.().*().$' }, -- Pair of balanced brackets from set (used for builtin `b` identifier)
        d = { '%f[%d]%d+' }, -- digits
        e = { -- Word with case
          { '%u[%l%d]+%f[^%l%d]', '%f[%S][%l%d]+%f[^%l%d]', '%f[%P][%l%d]+%f[^%l%d]', '^[%l%d]+%f[^%l%d]' },
          '^().*()$',
        },
        i = ai_indent,
      },

      -- Module mappings. Use `''` (empty string) to disable one.
      mappings = {
        -- Main textobject prefixes
        around = 'a',
        inside = 'i',

        -- Next/last variants
        around_next = 'an',
        inside_next = 'in',
        around_last = 'aN',
        inside_last = 'iN',

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
