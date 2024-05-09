return {
  'L3MON4D3/LuaSnip',
  event = 'LazyFile',
  keys = {
    -- stylua: ignore start
    { '<C-j>', function()
        if require('luasnip').expand_or_locally_jumpable() then
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

    -- require("luasnip.loaders.from_vscode").lazy_load({
    --   paths = vim.fn.stdpath("config") .. "/snippets",
    -- })
    -- require("luasnip.loaders.from_vscode").load({ paths = ".\\snippets" })

    require('luasnip.loaders.from_lua').lazy_load({ paths = '.\\luasnippets' })

    local s = ls.snippet
    local f = ls.function_node

    ls.filetype_extend('typescript', { 'javascript' })
    ls.filetype_extend('javascriptreact', { 'javascript' })
    ls.filetype_extend('typescriptreact', { 'javascript' })

    ls.config.set_config({
      keep_roots = true,
      link_roots = true,
      exit_roots = false,
      link_children = false,
      update_events = 'TextChanged,TextChangedI',
      -- region_check_events = "CursorMoved,CursorHold,InsertEnter",
      -- delete_check_events = "InsertLeave",
      -- This can be especially useful when `history` is enabled.
      delete_check_events = 'TextChanged',
      enable_autosnippets = true,
      -- mapping for cutting selected text so it's usable as SELECT_DEDENT,
      -- SELECT_RAW or TM_SELECTED_TEXT (mapped via xmap).
      store_selection_keys = '<Tab>',
      ext_opts = {
        [types.choiceNode] = {
          active = {
            virt_text = { { '«', 'DiagnosticInfo' } },
          },
        },
      },
    })

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

    -- TODO(2023-10-05): test and see if its fixed by https://github.com/L3MON4D3/LuaSnip/pull/941
    -- forget the current snippet when leaving the insert mode
    -- https://github.com/L3MON4D3/LuaSnip/issues/747#issuecomment-1406946217
    -- vim.api.nvim_create_autocmd('CursorMovedI', {
    --   pattern = '*',
    --   callback = function(ev)
    --     if not ls.session or not ls.session.current_nodes[ev.buf] or ls.session.jump_active then
    --       return
    --     end
    --
    --     local current_node = ls.session.current_nodes[ev.buf]
    --     local current_start, current_end = current_node:get_buf_position()
    --     current_start[1] = current_start[1] + 1 -- (1, 0) indexed
    --     current_end[1] = current_end[1] + 1 -- (1, 0) indexed
    --     local cursor = vim.api.nvim_win_get_cursor(0)
    --
    --     if
    --       cursor[1] < current_start[1]
    --       or cursor[1] > current_end[1]
    --       or cursor[2] < current_start[2]
    --       or cursor[2] > current_end[2]
    --     then
    --       ls.unlink_current()
    --     end
    --   end,
    -- })
  end,
}
