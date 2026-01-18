return {
  {
    'nvim-treesitter/nvim-treesitter',
    -- build = ':TSUpdate'
    config = function()
      local parsers = {
        'bash',
        'c',
        'css',
        'diff',
        'html',
        'java',
        'javascript',
        'jsdoc',
        'json',
        'jsonc',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'nu',
        'powershell',
        'python',
        'query',
        'regex',
        'rust',
        'toml',
        'toml',
        'tsx',
        'typescript',
        'vim',
        'vimdoc',
        'vue',
        'xml',
        'yaml',
      }
      -- require('nvim-treesitter').install(parsers)

      vim.api.nvim_create_autocmd('FileType', {
        pattern = parsers,
        callback = function()
          -- syntax highlighting, provided by Neovim
          vim.treesitter.start()
          -- folds, provided by Neovim
          -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
          -- vim.wo.foldmethod = 'expr'
          -- indentation, provided by nvim-treesitter
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    event = { 'LazyFile', 'VeryLazy' },
    init = function()
      -- Disable entire built-in ftplugin mappings to avoid conflicts.
      -- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
      -- vim.g.no_plugin_maps = true
    end,
    opts = {
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        -- LazyVim extention to create buffer-local keymaps
        -- from: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/treesitter.lua#L147
        keys = {
          goto_next_start = {
            [']m'] = '@function.outer',
            -- [']['] = '@class.outer',
            [']a'] = '@parameter.inner',
            [']f'] = '@call.outer',
            [']j'] = '@block.outer',
            [']n'] = '@number.inner',
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
          },
          goto_previous_end = {
            ['[M'] = '@function.outer',
            -- ['[]'] = '@class.outer',
            ['[A'] = '@parameter.inner',
            ['[F'] = '@call.outer',
            ['[J'] = '@block.outer',
          },
          goto_next = { [']v'] = '@conditional.outer' },
          goto_previous = { ['[v'] = '@conditional.outer' },
        },
      },
    },
    config = function(_, opts)
      require('nvim-treesitter-textobjects').setup(opts)

      local function attach(buf)
        if not (vim.tbl_get(opts, 'move', 'enable')) then
          return
        end
        ---@type table<string, table<string, string>>
        local moves = vim.tbl_get(opts, 'move', 'keys') or {}

        for method, keymaps in pairs(moves) do
          for key, query in pairs(keymaps) do
            local queries = type(query) == 'table' and query or { query }
            local parts = {}
            for _, q in ipairs(queries) do
              local part = q:gsub('@', ''):gsub('%..*', '')
              part = part:sub(1, 1):upper() .. part:sub(2)
              table.insert(parts, part)
            end
            local desc = table.concat(parts, ' or ')
            desc = (key:sub(1, 1) == '[' and 'Prev ' or 'Next ') .. desc
            desc = desc .. (key:sub(2, 2) == key:sub(2, 2):upper() and ' End' or ' Start')
            if not (vim.wo.diff and key:find('[cC]')) then
              vim.keymap.set({ 'n', 'x', 'o' }, key, function()
                require('nvim-treesitter-textobjects.move')[method](query, 'textobjects')
              end, {
                buffer = buf,
                desc = desc,
                silent = true,
              })
            end
          end
        end
      end

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('lazyvim_treesitter_textobjects', { clear = true }),
        callback = function(ev)
          attach(ev.buf)
        end,
      })
      vim.tbl_map(attach, vim.api.nvim_list_bufs())

      --> repeat move
      local ts_repeat_move = require('nvim-treesitter-textobjects.repeatable_move')
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

      local ts_textobjects_extended = require('ts_textobjects_extended')

      --> repeat diagnostics
      local next_diagnostic = function()
        vim.diagnostic.jump({ count = 1, float = true })
      end
      local prev_diagnostic = function()
        vim.diagnostic.jump({ count = -1, float = true })
      end
      local next_warn = function()
        vim.diagnostic.jump({ count = 1, float = true, severity = { min = vim.diagnostic.severity.WARN } })
      end
      local prev_warn = function()
        vim.diagnostic.jump({ count = -1, float = true, severity = { min = vim.diagnostic.severity.WARN } })
      end
      next_warn, prev_warn = ts_textobjects_extended.make_repeatable_move_pair(next_warn, prev_warn)
      next_diagnostic, prev_diagnostic =
        ts_textobjects_extended.make_repeatable_move_pair(next_diagnostic, prev_diagnostic)

      map({ 'n', 'x', 'o' }, '[e', prev_warn, { desc = 'Previous Warning' })
      map({ 'n', 'x', 'o' }, ']e', next_warn, { desc = 'Next Warning' })
      map({ 'n', 'x', 'o' }, '[d', prev_diagnostic, { desc = 'Previous Diagnostic' })
      map({ 'n', 'x', 'o' }, ']d', next_diagnostic, { desc = 'Next Diagnostic' })

      --> repeat gitsigns
      local gitsigns_ok, gitsigns = pcall(require, 'gitsigns')
      if gitsigns_ok then
        local next_hunk, prev_hunk = ts_textobjects_extended.make_repeatable_move_pair(function()
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
        map({ 'n', 'x' }, ']g', next_hunk, { desc = 'Git hunk forward' })
        map({ 'n', 'x' }, '[g', prev_hunk, { desc = 'Git hunk backward' })
      end

      --> repeat some mini.bracketed keys
      local bracketed_ok, bracketed = pcall(require, 'mini.bracketed')
      if bracketed_ok then
        -- Comment block
        local next_comment, prev_comment = ts_textobjects_extended.make_repeatable_move_pair(function()
          bracketed.comment('forward')
        end, function()
          bracketed.comment('backward')
        end)
        map({ 'n', 'x', 'o' }, ']c', next_comment, { desc = 'Comment forward' })
        map({ 'n', 'x', 'o' }, '[c', prev_comment, { desc = 'Comment backward' })

        -- Indent change
        local next_indent, prev_indent = ts_textobjects_extended.make_repeatable_move_pair(function()
          bracketed.indent('forward')
        end, function()
          bracketed.indent('backward')
        end)
        map({ 'n', 'x', 'o' }, ']i', next_indent, { desc = 'Indent forward' })
        map({ 'n', 'x', 'o' }, '[i', prev_indent, { desc = 'Indent backward' })

        -- Tree-sitter node and parents
        local next_treesitter, prev_treesitter = ts_textobjects_extended.make_repeatable_move_pair(function()
          bracketed.treesitter('forward')
        end, function()
          bracketed.treesitter('backward')
        end)
        map({ 'n', 'x', 'o' }, ']t', next_treesitter, { desc = 'Treesitter forward' })
        map({ 'n', 'x', 'o' }, '[t', prev_treesitter, { desc = 'Treesitter backward' })
      end

      --> repeat markdown headings
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
          local next_heading_repeat, prev_heading_repeat = ts_textobjects_extended.make_repeatable_move_pair(function()
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
    enabled = false,
    event = 'LazyFile',
    opts = {},
  },
}
