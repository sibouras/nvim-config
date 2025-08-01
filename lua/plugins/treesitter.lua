return {
  {
    'nvim-treesitter/nvim-treesitter',
    -- build = ":TSUpdate",
    event = { 'LazyFile', 'VeryLazy' },
    cmd = { 'TSUpdateSync', 'TSUpdate', 'TSInstall', 'TSInstallInfo' },
    init = function(plugin)
      -- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
      -- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
      -- no longer trigger the **nvim-treesitter** module to be loaded in time.
      -- Luckily, the only things that those plugins need are the custom queries, which we make available
      -- during startup.
      require('lazy.core.loader').add_to_rtp(plugin)
      require('nvim-treesitter.query_predicates')
    end,
    dependencies = 'nvim-treesitter/nvim-treesitter-textobjects',
    opts = {
      ensure_installed = {
        'html',
        'css',
        'javascript',
        'tsx',
        'typescript',
        'markdown',
        'markdown_inline',
      },
      sync_install = false,
      -- Automatically install missing parsers when entering buffer
      -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
      auto_install = false,
      -- ignore_install = { "tlaplus" }, -- List of parsers to ignore installing
      highlight = {
        enable = true, -- false will disable the whole extension
        -- disable = { "" }, -- list of language that will be disabled
        -- Or use a function for more flexibility
        disable = function(lang, buf)
          -- filetypes that will be disabled
          -- local filetype_exclude = { "help" }
          -- if vim.tbl_contains(filetype_exclude, vim.bo.filetype) then
          --   return true
          -- end

          -- disable for lines > 10000
          -- if vim.api.nvim_buf_line_count(buf) > 10000 then
          --   return true
          -- end

          -- disable slow treesitter highlight for large files
          local max_filesize = 500 * 1024 -- 500 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
        end,
        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
      },
      incremental_selection = {
        enable = false,
        keymaps = {
          -- set to `false` to disable one of the mappings
          init_selection = '<M-Up>',
          node_incremental = '<M-Up>',
          scope_incremental = '<M-Home>',
          node_decremental = '<M-Down>',
        },
      },
      indent = { enable = true, disable = { 'yaml' } },
      textobjects = {
        select = {
          -- NOTE: using mini.ai instead
          enable = false,
          -- Automatically jump forward to textobj, similar to targets.vim
          lookahead = true,
          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ['am'] = '@function.outer',
            ['im'] = '@function.inner',
            ['aj'] = '@block.outer',
            ['ij'] = '@block.inner',
            ['aa'] = '@parameter.outer',
            ['ia'] = '@parameter.inner',
            ['af'] = '@call.outer',
            ['if'] = '@call.inner',
            ['in'] = '@number.inner',

            ['a='] = '@assignment.outer',
            ['i='] = '@assignment.inner',
            ['<Left>'] = '@assignment.lhs',
            ['<Right>'] = '@assignment.rhs',
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ['<leader>rl'] = '@parameter.inner',
          },
          swap_previous = {
            ['<leader>rh'] = '@parameter.inner',
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            [']m'] = '@function.outer',
            -- [']]'] = '@class.outer', -- conflicts with jump to text sections in markdown
            [']a'] = '@parameter.inner',
            [']f'] = '@call.outer',
            [']j'] = '@block.outer',
            [']n'] = '@number.inner',

            -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
            -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
            -- [']s'] = { query = '@scope', query_group = 'locals', desc = 'Next scope' },
            [']z'] = { query = '@fold', query_group = 'folds', desc = 'Next fold' },
          },
          goto_next_end = {
            [']M'] = '@function.outer',
            -- [']['] = '@class.outer',
            [']A'] = '@parameter.inner',
            [']F'] = '@call.outer',
            [']J'] = '@block.outer',
          },
          goto_previous_start = {
            ['[m'] = '@function.outer',
            -- ['[['] = '@class.outer',
            ['[a'] = '@parameter.inner',
            ['[f'] = '@call.outer',
            ['[j'] = '@block.outer',
            ['[n'] = '@number.inner',

            -- ['[s'] = { query = '@scope', query_group = 'locals', desc = 'Previous scope' },
            ['[z'] = { query = '@fold', query_group = 'folds', desc = 'Previous fold' },
          },
          goto_previous_end = {
            ['[M'] = '@function.outer',
            -- ['[]'] = '@class.outer',
            ['[A'] = '@parameter.inner',
            ['[F'] = '@call.outer',
            ['[J'] = '@block.outer',
          },
          -- Below will go to either the start or the end, whichever is closer.
          -- Use if you want more granular movements
          -- Make it even more gradual by adding multiple queries and regex.
          goto_next = {
            [']v'] = '@conditional.outer',
          },
          goto_previous = {
            ['[v'] = '@conditional.outer',
          },
        },
        lsp_interop = {
          enable = true,
          peek_definition_code = {
            ['<leader>df'] = '@function.outer',
            ['<leader>dF'] = '@class.outer',
          },
        },
      },
    },
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)

      local ts_repeat_move = require('nvim-treesitter.textobjects.repeatable_move')
      local map = vim.keymap.set
      -- Repeat movement with ; and ,
      -- ensure ; goes forward and , goes backward regardless of the last direction
      map({ 'n', 'x', 'o' }, ';', ts_repeat_move.repeat_last_move_next)
      map({ 'n', 'x', 'o' }, ',', ts_repeat_move.repeat_last_move_previous)

      -- vim way: ; goes to the direction you were moving.
      -- map({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
      -- map({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)

      -- Optionally, make builtin f, F, t, T also repeatable with ; and ,
      map({ 'n', 'x', 'o' }, 'f', ts_repeat_move.builtin_f_expr, { expr = true })
      map({ 'n', 'x', 'o' }, 'F', ts_repeat_move.builtin_F_expr, { expr = true })
      map({ 'n', 'x', 'o' }, 't', ts_repeat_move.builtin_t_expr, { expr = true })
      map({ 'n', 'x', 'o' }, 'T', ts_repeat_move.builtin_T_expr, { expr = true })

      -- This repeats the last query with always previous direction and to the start of the range.
      map({ 'n', 'x', 'o' }, '<home>', function()
        ts_repeat_move.repeat_last_move({ forward = false, start = true })
      end)
      -- This repeats the last query with always next direction and to the end of the range.
      map({ 'n', 'x', 'o' }, '<end>', function()
        ts_repeat_move.repeat_last_move({ forward = true, start = false })
      end)

      -- LSP diagnostics
      local diagnostic_goto_next_repeat, diagnostic_goto_prev_repeat =
        ts_repeat_move.make_repeatable_move_pair(vim.diagnostic.goto_next, vim.diagnostic.goto_prev)
      map({ 'n', 'x', 'o' }, '[d', diagnostic_goto_prev_repeat, { desc = 'Diagnostic forward' })
      map({ 'n', 'x', 'o' }, ']d', diagnostic_goto_next_repeat, { desc = 'Diagnostic forward' })

      local gitsigns_ok, gitsigns = pcall(require, 'gitsigns')
      if gitsigns_ok then
        local next_hunk_repeat, prev_hunk_repeat = ts_repeat_move.make_repeatable_move_pair(function()
          -- use nav_hunk() when gitsigns is available to keep the preview open
          -- if vim.wo.diff and vim.b.gitsigns_head == nil then
          if vim.wo.diff then
            vim.cmd.normal({ ']c', bang = true })
          else
            gitsigns.nav_hunk('next', { target = 'all' })
          end
        end, function()
          if vim.wo.diff then
            vim.cmd.normal({ '[c', bang = true })
          else
            gitsigns.nav_hunk('prev', { target = 'all' })
          end
        end)
        -- Or, use `make_repeatable_move` or `set_last_move` functions for more control. See the code for instructions.

        map({ 'n', 'x', 'o' }, ']g', next_hunk_repeat, { desc = 'Git hunk forward' })
        map({ 'n', 'x', 'o' }, '[g', prev_hunk_repeat, { desc = 'Git hunk forward' })
      end

      -- override some mini.bracketed keys
      local bracketed_ok, bracketed = pcall(require, 'mini.bracketed')
      if bracketed_ok then
        -- Comment block
        local next_comment, prev_comment = ts_repeat_move.make_repeatable_move_pair(function()
          bracketed.comment('forward')
        end, function()
          bracketed.comment('backward')
        end)
        map({ 'n', 'x', 'o' }, ']c', next_comment, { desc = 'Comment forward' })
        map({ 'n', 'x', 'o' }, '[c', prev_comment, { desc = 'Comment backward' })

        -- Indent change
        local next_indent, prev_indent = ts_repeat_move.make_repeatable_move_pair(function()
          bracketed.indent('forward')
        end, function()
          bracketed.indent('backward')
        end)
        map({ 'n', 'x', 'o' }, ']i', next_indent, { desc = 'Indent forward' })
        map({ 'n', 'x', 'o' }, '[i', prev_indent, { desc = 'Indent forward' })

        -- Tree-sitter node and parents
        local next_treesitter, prev_treesitter = ts_repeat_move.make_repeatable_move_pair(function()
          bracketed.treesitter('forward')
        end, function()
          bracketed.treesitter('backward')
        end)
        map({ 'n', 'x', 'o' }, ']s', next_treesitter, { desc = 'Treesitter forward' })
        map({ 'n', 'x', 'o' }, '[s', prev_treesitter, { desc = 'Treesitter forward' })
      end

      vim.api.nvim_create_autocmd({ 'FileType' }, {
        desc = 'repeatable jump to next heading/section',
        pattern = { 'markdown', 'help', 'checkhealth' },
        group = vim.api.nvim_create_augroup('MyGroup_nvim-treesitter', { clear = true }),
        callback = function(event)
          -- return in lsp hover windows
          -- local ok, preview_bufnr = pcall(vim.api.nvim_win_get_var, vim.fn.win_getid(vim.fn.winnr()), 'lsp_floating_bufnr')
          -- if ok then
          --   return
          -- end
          if event.file == 'markdown' then
            return
          end
          local next_heading_repeat, prev_heading_repeat = ts_repeat_move.make_repeatable_move_pair(function()
            if event.match == 'checkhealth' then
              require('vim.treesitter._headings').jump({ count = 1, level = 1 })
            else
              require('vim.treesitter._headings').jump({ count = 1 })
            end
          end, function()
            if event.match == 'checkhealth' then
              require('vim.treesitter._headings').jump({ count = -1, level = 1 })
            else
              require('vim.treesitter._headings').jump({ count = -1 })
            end
          end)
          map('n', ']]', next_heading_repeat, { buffer = 0, silent = false, desc = 'Jump to next section' })
          map('n', '[[', prev_heading_repeat, { buffer = 0, silent = false, desc = 'Jump to previous section' })
        end,
      })
    end,
  },
  {
    'windwp/nvim-ts-autotag',
    event = 'LazyFile',
    opts = {},
  },
}
