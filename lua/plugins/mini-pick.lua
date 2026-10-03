return {
  'nvim-mini/mini.pick',
  cmd = 'Pick',
  -- enabled = false,
  dependencies = {
    'nvim-mini/mini.extra',
  },
  keys = {
    { "<leader>'", '<Cmd>Pick resume<CR>', desc = 'MiniPick: resume' },
    { '<leader>b', '<Cmd>Pick buffers<CR>', desc = 'MiniPick: buffers' },
    { '<leader>fs', '<Cmd>Pick files_rg<CR>', desc = 'MiniPick: files' },
    { '<leader>fh', '<Cmd>Pick help<CR>', desc = 'MiniPick: help' },
    { '<leader>fg', '<Cmd>Pick grep_live<CR>', desc = 'MiniPick: grep live' },
    { '<leader>fw', '<Cmd>Pick grep pattern="<cword>"<CR>', desc = 'MiniPick: grep current word' },
    -- mini.extra pickers
    { '<leader>fl', '<Cmd>Pick buf_lines scope="all"<CR>', desc = 'MiniPick: buf_lines (all)' },
    { '<leader>fb', '<Cmd>Pick buf_lines scope="current"<CR>', desc = 'MiniPick: buf_lines (buf)' },
    { '<leader>fC', '<Cmd>Pick colorschemes<CR>', desc = 'MiniPick: colorschemes' },
    { '<leader>fc', '<Cmd>Pick commands<CR>', desc = 'MiniPick: commands' },
    { '<leader>fB', '<Cmd>Pick git_branches<CR>', desc = 'MiniPick: git_branches' },
    { '<leader>fn', '<Cmd>Pick git_files<CR>', desc = 'MiniPick: git_files' },
    { '<leader>i', '<Cmd>Pick git_status<CR>', desc = 'MiniPick: git modified/untracked files' },
    { '<leader>fi', '<Cmd>Pick git_modified_untracked<CR>', desc = 'MiniPick: git modified/untracked files' },
    { '<leader>fa', '<Cmd>Pick git_hunks scope="staged"<CR>', desc = 'MiniPick: added hunks (all)' },
    { '<leader>fA', '<Cmd>Pick git_hunks path="%" scope="staged"<CR>', desc = 'MiniPick: added hunks (buf)' },
    { '<leader>fm', '<Cmd>Pick git_hunks<CR>', desc = 'MiniPick: modified hunks (all)' },
    { '<leader>fM', '<Cmd>Pick git_hunks path="%"<CR>', desc = 'MiniPick: modified hunks (buf)' },
    { '<leader>f;', '<Cmd>Pick history scope=":"<CR>', desc = 'MiniPick: command history' },
    { '<leader>f/', '<Cmd>Pick history scope="/"<CR>', desc = 'MiniPick: search history' },
    { '<leader>fH', '<Cmd>Pick hl_groups<CR>', desc = 'MiniPick: hl_groups' },
    { '<leader>fk', '<Cmd>Pick keymaps<CR>', desc = 'MiniPick: keymaps' },
    { '<leader>fk', '<Cmd>Pick keymaps<CR>', desc = 'MiniPick: keymaps' },
    { '<leader>fq', '<Cmd>Pick list scope="quickfix"<CR>', desc = 'MiniPick: quickfix' },
    { '<leader>ld', '<Cmd>Pick diagnostic<CR>', desc = 'MiniPick: diagnostics workspace' },
    { '<leader>lD', '<Cmd>Pick diagnostic scope="current"<CR>', desc = 'MiniPick: diagnostics buffer' },
    { '<leader>ls', '<Cmd>Pick lsp scope="document_symbol"<CR>', desc = 'MiniPick: document_symbol' },
    { '<leader>lS', '<Cmd>Pick lsp scope="workspace_symbol_live"<CR>', desc = 'MiniPick: workspace_symbol_live' },
    { '<leader>lr', '<Cmd>Pick lsp scope="references"<CR>', desc = 'MiniPick: references' },
    { '<leader>lt', '<Cmd>Pick lsp scope="type_definition"<CR>', desc = 'MiniPick: type_definition' },
    { '<leader>fI', '<Cmd>Pick marks scope="buf"<CR>', desc = 'MiniPick: local marks' },
    { '<leader>fo', '<Cmd>Pick oldfiles current_dir=true<CR>', desc = 'MiniPick: oldfiles(cwd)' },
    { '<leader>fv', '<Cmd>Pick options<CR>', desc = 'MiniPick: options' },
    { '<leader>fr', '<Cmd>Pick registers<CR>', desc = 'MiniPick: registers' },
    { '<leader>vs', '<Cmd>Pick visit_paths<CR>', desc = 'MiniPick: visit paths' },
    { '<leader>fe', '<Cmd>Pick explorer<CR>', desc = 'MiniPick: explorer' },
    {
      '<leader>ff',
      function()
        MiniExtra.pickers.explorer({ cwd = vim.fn.expand('%:p:h') })
      end,
      desc = 'MiniPick: explorer(cwd)',
    },
  },
  opts = {
    mappings = {
      choose_marked = '<C-q>',
      refine = '<C-j>',
      refine_marked = '<C-k>',
    },
  },
  config = function(_, opts)
    require('mini.pick').setup(opts)
    require('mini.extra').setup()

    MiniPick.registry.files_rg = function()
      local command =
        { 'rg', '--files', '--color=never', '--hidden', '--sortr=modified', '--glob=!{.git,node_modules}' }
      local show_with_icons = function(buf_id, items, query)
        return MiniPick.default_show(buf_id, items, query, { show_icons = true })
      end
      local source = { name = 'Files rg', show = show_with_icons }
      return MiniPick.builtin.cli({ command = command }, { source = source })
    end

    MiniPick.registry.git_modified_untracked = function()
      local command = { 'git', 'ls-files', '--modified', '--others', '--exclude-standard' }
      local show_with_icons = function(buf_id, items, query)
        return MiniPick.default_show(buf_id, items, query, { show_icons = true })
      end
      local source = { name = 'Git files(modified/untracked)', show = show_with_icons }
      return MiniPick.builtin.cli({ command = command }, { source = source })
    end

    -- simple Git status picker from: https://github.com/nvim-mini/mini.nvim/discussions/2065
    MiniPick.registry.git_status = function()
      local show_fn = function(buf_id, items, query)
        -- Convert items to a table and extract path to get file icons
        for i, item in ipairs(items) do
          local _, filepath = string.match(item, '^%s*(%S+)%s+(%S+)$')
          items[i] = { text = item, path = filepath }
        end
        return MiniPick.default_show(buf_id, items, query, { show_icons = true })
      end
      local choose_fn = function(item)
        local _, path = string.match(item, '^%s*(%S+)%s+(%S+)$')
        return MiniPick.default_choose(path)
      end
      local preview_fn = function(buf_id, item)
        local _, path = string.match(item, '^%s*(%S+)%s+(%S+)$')
        return MiniPick.default_preview(buf_id, path, { show_icons = true })
      end
      local local_opts = { command = { 'git', 'status', '-s', '-u' } }
      local source = { name = 'Git status', show = show_fn, choose = choose_fn, preview = preview_fn }
      return MiniPick.builtin.cli(local_opts, { source = source })
    end
  end,
}
