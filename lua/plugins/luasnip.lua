return {
  'L3MON4D3/LuaSnip',
  -- event = 'LazyFile',
  keys = {
    -- stylua: ignore start
    { '<C-j>', function()
      -- local blink = require "blink.cmp"
      if require('luasnip').expand_or_locally_jumpable() then
        -- if blink.is_menu_visible() then
        --   blink.hide()
        -- end
        require('luasnip').expand_or_jump()
      end
    end, silent = true, mode = { "i", "s" } },

    { "<C-k>", function()
      if require('luasnip').locally_jumpable(-1) then
        require('luasnip').jump(-1)
      end
    end, silent = true, mode = { "i", "s" } },

    { "<C-l>", function()
      if require('luasnip').choice_active() then
        require('luasnip').change_choice(1)
      end
    end, mode = { "i", "s" } },

    { "<C-h>", function()
      if require('luasnip').choice_active() then
        require('luasnip').change_choice(-1)
      end
    end, mode = { "i", "s"} },
    -- stylua: ignore end
  },
  config = function()
    local ls = require('luasnip')
    local types = require('luasnip.util.types')

    ls.config.set_config({
      keep_roots = false,
      link_roots = false,
      exit_roots = false,
      link_children = false,
      update_events = 'TextChanged,TextChangedI', -- slow in macros
      -- enable_autosnippets = true, -- very slow in macros
      -- mapping for cutting selected text so it's usable as SELECT_DEDENT,
      -- SELECT_RAW or TM_SELECTED_TEXT (mapped via xmap).
      cut_selection_keys = '<Tab>',
      ext_opts = {
        [types.insertNode] = {
          unvisited = {
            virt_text = { { '|', 'Conceal' } },
            virt_text_pos = 'inline',
          },
        },
        [types.exitNode] = {
          unvisited = {
            virt_text = { { '|', 'Conceal' } },
            virt_text_pos = 'inline',
          },
        },
        [types.choiceNode] = {
          active = {
            virt_text = { { '«', 'DiagnosticInfo' } },
            -- virt_text = { { '(snippet) choice node', 'LspInlayHint' } },
          },
        },
      },
    })

    require('luasnip.loaders.from_vscode').lazy_load({ paths = './snippets' })

    -- require('luasnip.loaders.from_lua').lazy_load({ paths = './luasnippets' })
    -- ls.filetype_extend('typescript', { 'javascript' })
    -- ls.filetype_extend('javascriptreact', { 'javascript' })
    -- ls.filetype_extend('typescriptreact', { 'javascript' })

    local s = ls.snippet
    local f = ls.function_node
    -- new way: https://github.com/L3MON4D3/LuaSnip/issues/81
    ls.add_snippets(nil, {
      all = {
        s(
          'curtime',
          f(function()
            return os.date('%D - %H:%M')
          end)
        ),
        -- s(
        --   'date',
        --   f(function()
        --     return string.format(string.gsub(vim.bo.commentstring, '%%s', ' %%s'), os.date())
        --   end)
        -- ),
      },
    })
  end,
}
