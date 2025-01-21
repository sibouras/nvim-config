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
      autopairs = {
        enable = true,
      },
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
          local max_filesize = 200 * 1024 -- 200 KB
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
        enable = true,
        keymaps = {
          init_selection = '<M-C-S-F5>', -- ctrl+space
          node_incremental = '<C-o>', -- set to `false` to disable one of the mappings
          node_decremental = '<M-C-S-F6>', -- <C-i>
          scope_incremental = '.',
        },
      },
      indent = { enable = true, disable = { 'yaml' } },
      rainbow = {
        enable = false,
        -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
        extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
        max_file_lines = nil, -- Do not enable for files with more than n lines, int
        -- colors = {}, -- table of hex strings
        -- termcolors = {} -- table of colour name strings
      },
      textobjects = {
        select = {
          enable = true,
          -- Automatically jump forward to textobj, similar to targets.vim
          lookahead = true,
          keymaps = {
            -- NOTE: using mini.ai instead
            -- You can use the capture groups defined in textobjects.scm
            -- ['am'] = '@function.outer',
            -- ['im'] = '@function.inner',
            -- ['ab'] = '@block.outer',
            -- ['ib'] = '@block.inner',
            -- ['aa'] = '@parameter.outer',
            -- ['ia'] = '@parameter.inner',
            -- ['af'] = '@call.outer',
            -- ['if'] = '@call.inner',
            -- ['in'] = '@number.inner',
            --
            -- ['a='] = '@assignment.outer',
            -- ['i='] = '@assignment.inner',
            -- ['<Left>'] = '@assignment.lhs',
            -- ['<Right>'] = '@assignment.rhs',
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
            [']]'] = '@class.outer',
            [']a'] = '@parameter.inner',
            [']f'] = '@call.outer',
            [']b'] = '@block.outer',
            [']n'] = '@number.inner',

            -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
            -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
            [']s'] = { query = '@scope', query_group = 'locals', desc = 'Next scope' },
            [']z'] = { query = '@fold', query_group = 'folds', desc = 'Next fold' },
          },
          goto_next_end = {
            [']M'] = '@function.outer',
            [']['] = '@class.outer',
            [']A'] = '@parameter.inner',
            [']F'] = '@call.outer',
            [']B'] = '@block.outer',
          },
          goto_previous_start = {
            ['[m'] = '@function.outer',
            ['[['] = '@class.outer',
            ['[a'] = '@parameter.inner',
            ['[f'] = '@call.outer',
            ['[b'] = '@block.inner',
            ['[n'] = '@number.inner',

            ['[s'] = { query = '@scope', query_group = 'locals', desc = 'Previous scope' },
            ['[z'] = { query = '@fold', query_group = 'folds', desc = 'Previous fold' },
          },
          goto_previous_end = {
            ['[M'] = '@function.outer',
            ['[]'] = '@class.outer',
            ['[A'] = '@parameter.inner',
            ['[F'] = '@call.outer',
            ['[B'] = '@block.outer',
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
          border = 'rounded',
          peek_definition_code = {
            ['<leader>df'] = '@function.outer',
            ['<leader>dF'] = '@class.outer',
          },
        },
      },
    },
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)

      local parser_config = require('nvim-treesitter.parsers').get_parser_configs()

      -- tree-sitter-nu with neovim v0.10.3 (stable): https://discord.com/channels/601130461678272522/1066353495638278194/1312066978919219231
      -- according to this: https://github.com/neovim/neovim/blob/v0.10.3/cmake.deps/deps.txt#L56, the latest stable release (v0.10.3) still uses treesitter v0.22.6.
      local TREE_SITTER_NU_DIR = vim.fs.normalize('~/code/treesitter/tree-sitter-nu')
      parser_config.nu = {
        install_info = {
          url = TREE_SITTER_NU_DIR, -- local path or git repo
          files = { 'src/parser.c', 'src/scanner.c' }, -- note that some parsers also require src/scanner.c or src/scanner.cc
          -- optional entries:
          branch = 'main', -- default branch in case of git repo if different from master
          generate_requires_npm = false, -- if stand-alone parser without npm dependencies
          requires_generate_from_grammar = false, -- if folder contains pre-generated src/parser.c
        },
        filetype = 'nu',
      }

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
        map({ 'n', 'x', 'o' }, ']t', next_treesitter, { desc = 'Treesitter forward' })
        map({ 'n', 'x', 'o' }, '[t', prev_treesitter, { desc = 'Treesitter forward' })
      end
    end,
  },
  {
    'windwp/nvim-ts-autotag',
    event = 'LazyFile',
    opts = {},
  },
}
