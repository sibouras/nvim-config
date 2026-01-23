return {
  'nvim-telescope/telescope.nvim',
  cmd = 'Telescope',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'smartpde/telescope-recent-files',
    {
      'nvim-telescope/telescope-ui-select.nvim',
      init = function()
        ---@diagnostic disable-next-line: duplicate-set-field
        vim.ui.select = function(...)
          require('telescope').load_extension('ui-select')
          return vim.ui.select(...)
        end
      end,
    },
    -- Fuzzy Finder Algorithm which requires local dependencies to be built.
    -- Only load if `make` is available.
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = vim.fn.executable('make') == 1,
    },
  },
  keys = {
    { '<leader>fs', '<cmd>Telescope find_files<CR>', desc = 'Telescope find_files' },
    { '<leader>fn', '<cmd>Telescope git_files<CR>', desc = 'Telescope git_files' },
    { '<leader>fi', '<cmd>Telescope git_status<CR>', desc = 'Telescope git_status' },
    { "<leader>'", '<cmd>Telescope resume<CR>', desc = 'Telescope resume' },
    { '<leader>fr', '<cmd>Telescope registers<CR>', desc = 'Telescope registers' },
    { '<leader>fq', '<cmd>Telescope quickfix<CR>', desc = 'Telescope quickfix' },
    { '<leader>fv', '<cmd>Telescope vim_options<CR>', desc = 'Telescope vim_options' },
    { '<leader>fg', '<cmd>Telescope live_grep<CR>', desc = 'Telescope live_grep' },
    { '<leader>fh', '<cmd>Telescope help_tags<CR>', desc = 'Telescope help_tags' },
    { '<leader>fH', '<cmd>Telescope highlights<CR>', desc = 'Telescope highlights' },
    { '<leader>fk', '<cmd>Telescope keymaps<CR>', desc = 'Telescope keymaps' },
    { '<leader>fa', '<cmd>Telescope autocommands<CR>', desc = 'Telescope autocommands' },
    { '<leader>fc', '<cmd>Telescope commands<CR>', desc = 'Telescope commands' },
    { '<leader>fC', '<cmd>Telescope colorscheme enable_preview=true<CR>', desc = 'Telescope colorscheme' },
    { '<leader>f;', '<cmd>Telescope command_history<CR>', desc = 'Telescope command_history' },
    { '<leader>f/', '<cmd>Telescope search_history<CR>', desc = 'Telescope search_history' },
    { '<leader>lr', '<cmd>Telescope lsp_references<CR>', desc = 'Telescope lsp_references' },
    { '<leader>lt', '<cmd>Telescope lsp_type_definitions<CR>', desc = 'Telescope lsp_type_definitions' },
    { '<leader>ld', '<cmd>Telescope diagnostics<CR>', desc = 'Telescope diagnostics' },
    { '<leader>ft', '<cmd>Telescope treesitter previewer=true<CR>', desc = 'Telescope treesitter' },
    { '<leader>fj', '<cmd>Telescope jumplist previewer=true initial_mode=normal<CR>', desc = 'Telescope jumplist' },
    { '<leader>fb', '<cmd>Telescope current_buffer_fuzzy_find<CR>', desc = 'Telescope current_buffer_fuzzy_find' },
    {
      '<leader>fm',
      '<cmd>Telescope marks mark_type=local previewer=true initial_mode=normal<CR>',
      desc = 'Telescope marks local',
    },
    {
      '<leader>fw',
      '<cmd>Telescope recent_files only_cwd=true initial_mode=normal<CR>',
      desc = 'Telescope recent files(only_cwd)',
    },
    {
      '<leader>fW',
      '<cmd>Telescope recent_files only_cwd=false initial_mode=normal<CR>',
      desc = 'Telescope recent files',
    },
    { '<leader>b', '<cmd>Telescope buffers<CR>', desc = 'Telescope buffers' },
    {
      '<leader>i',
      function()
        require('telescope.builtin').buffers(require('telescope.themes').get_dropdown({
          previewer = false,
          sort_mru = true,
          layout_config = { width = 70 },
        }))
      end,
      desc = 'Telescope buffers(dropdown)',
    },
    {
      '<leader>fd',
      function()
        require('telescope.builtin').find_files({ cwd = '~/.config/symlinks', prompt_title = 'Dotfiles' })
      end,
      desc = 'Telescope Find symlinks',
    },
    {
      '<leader>ff',
      function()
        require('telescope.builtin').find_files({ cwd = vim.fn.expand('%:p:h'), prompt_title = 'From Current Buffer' })
      end,
      desc = 'Telescope Find files from current buffer',
    },
    {
      -- improve oldfiles sorting
      -- https://github.com/nvim-telescope/telescope.nvim/issues/2539
      '<leader>fo',
      function()
        require('telescope.builtin').oldfiles({
          tiebreak = function(current_entry, existing_entry, _)
            return current_entry.index < existing_entry.index
          end,
        })
      end,
      desc = 'Telescope oldfiles',
    },
    {
      '<leader>lS',
      '<cmd>Telescope lsp_document_symbols previewer=true<CR>',
      desc = 'Telescope lsp_document_symbols all',
    },
    {
      '<leader>lwW',
      '<cmd>Telescope lsp_dynamic_workspace_symbols<CR>',
      desc = 'Telescope lsp_dynamic_workspace_symbols all',
    },
    '<leader>ls',
    '<leader>lww',
  },
  opts = function()
    local actions = require('telescope.actions')

    local function yank_selected_entry(prompt_bufnr)
      local entry = require('telescope.actions.state').get_selected_entry().value
      actions.close(prompt_bufnr)
      local clipboardOpt = vim.opt.clipboard:get()
      local useSystemClipb = #clipboardOpt > 0 and clipboardOpt[1]:find('unnamed')
      local reg = useSystemClipb and '+' or '"'
      vim.fn.setreg(reg, entry)
      print('Yanked: ' .. entry)
    end

    -- from:https://github.com/nvim-telescope/telescope.nvim/issues/2778#issuecomment-2202572413
    local focus_preview = function(prompt_bufnr)
      local action_state = require('telescope.actions.state')
      local picker = action_state.get_current_picker(prompt_bufnr)
      local prompt_win = picker.prompt_win
      local previewer = picker.previewer
      local winid = previewer.state.winid
      local bufnr = previewer.state.bufnr
      vim.keymap.set({ 'n', 'i' }, '<C-o>', function()
        vim.cmd(string.format('noautocmd lua vim.api.nvim_set_current_win(%s)', prompt_win))
      end, { buffer = bufnr })
      vim.keymap.set({ 'n', 'i' }, '<C-c>', function()
        vim.cmd(string.format('noautocmd lua vim.api.nvim_set_current_win(%s)', prompt_win))
      end, { buffer = bufnr })
      vim.cmd(string.format('noautocmd lua vim.api.nvim_set_current_win(%s)', winid))
      -- api.nvim_set_current_win(winid)
    end

    return {
      defaults = {
        prompt_prefix = ' ',
        selection_caret = ' ',
        -- path_display = { '' },
        path_display = {
          filename_first = {
            reverse_directories = false,
          },
        },
        file_ignore_patterns = { '.git[\\/]', 'node_modules', '^.nvim' },
        sorting_strategy = 'ascending',
        layout_strategy = 'flex',
        layout_config = {
          height = 0.9,
          prompt_position = 'top',
          horizontal = {
            preview_width = 0.5,
            preview_cutoff = 110,
          },
          vertical = {
            mirror = true,
            preview_cutoff = 30,
            -- preview_height = 0.5,
          },
        },
        preview = {
          hide_on_startup = false, -- hide previewer when picker starts
          filesize_limit = 25, -- The maximum file size in MB attempted to be previewed. Default: 25mb
          highlight_limit = 1, -- The maximum file size in MB attempted to be highlighted. Default: 1mb
        },
        mappings = {
          i = {
            ['`'] = actions.close,
            ['<C-c>'] = actions.close,
            ['<C-j>'] = actions.move_selection_next,
            ['<C-k>'] = actions.move_selection_previous,
            ['<Down>'] = actions.move_selection_next,
            ['<Up>'] = actions.move_selection_previous,
            ['<CR>'] = actions.select_default,
            ['<C-s>'] = actions.select_horizontal,
            ['<C-v>'] = actions.select_vertical,
            ['<C-t>'] = actions.select_tab,
            ['<C-u>'] = actions.preview_scrolling_up,
            ['<C-d>'] = actions.preview_scrolling_down,
            ['<PageUp>'] = actions.results_scrolling_up,
            ['<PageDown>'] = actions.results_scrolling_down,
            ['<S-Left>'] = actions.preview_scrolling_left,
            ['<S-Right>'] = actions.preview_scrolling_right,
            ['<M-Left>'] = actions.results_scrolling_left,
            ['<M-Right>'] = actions.results_scrolling_right,
            ['<Tab>'] = actions.toggle_selection + actions.move_selection_worse,
            ['<S-Tab>'] = actions.toggle_selection + actions.move_selection_better,
            ['<C-a>'] = actions.toggle_all,
            ['<C-l>'] = actions.complete_tag,
            ['<C-_>'] = actions.which_key, -- keys from pressing <C-/>
            ['<C-p>'] = require('telescope.actions.layout').toggle_preview,
            ['<C-BS>'] = { '<C-w>', type = 'command', opts = { noremap = false } },
            ['<C-f>'] = actions.to_fuzzy_refine,
            ['<C-q>'] = actions.send_to_qflist + actions.open_qflist,
            ['<M-q>'] = actions.send_selected_to_qflist + actions.open_qflist,
            ['<C-y>'] = yank_selected_entry,
            ['<C-o>'] = focus_preview,
          },
          n = {
            ['`'] = actions.close,
            ['<esc>'] = actions.close,
            ['q'] = actions.close,
            ['<C-c>'] = actions.close,
            ['<CR>'] = actions.select_default,
            ['l'] = actions.select_default,
            ['<C-s>'] = actions.select_horizontal,
            ['<C-v>'] = actions.select_vertical,
            ['<C-t>'] = actions.select_tab,
            ['<Tab>'] = actions.toggle_selection + actions.move_selection_worse,
            ['<S-Tab>'] = actions.toggle_selection + actions.move_selection_better,
            ['<C-a>'] = actions.toggle_all,
            ['j'] = actions.move_selection_next,
            ['k'] = actions.move_selection_previous,
            ['H'] = actions.move_to_top,
            ['M'] = actions.move_to_middle,
            ['L'] = actions.move_to_bottom,
            ['<Down>'] = actions.move_selection_next,
            ['<Up>'] = actions.move_selection_previous,
            ['gg'] = actions.move_to_top,
            ['G'] = actions.move_to_bottom,
            ['<C-u>'] = actions.preview_scrolling_up,
            ['<C-d>'] = actions.preview_scrolling_down,
            ['<PageUp>'] = actions.results_scrolling_up,
            ['<PageDown>'] = actions.results_scrolling_down,
            ['<S-Left>'] = actions.preview_scrolling_left,
            ['<S-Right>'] = actions.preview_scrolling_right,
            ['<M-Left>'] = actions.results_scrolling_left,
            ['<M-Right>'] = actions.results_scrolling_right,
            ['?'] = actions.which_key,
            ['<C-p>'] = require('telescope.actions.layout').toggle_preview,
            ['<C-q>'] = actions.send_to_qflist + actions.open_qflist,
            ['<M-q>'] = actions.send_selected_to_qflist + actions.open_qflist,
            ['<C-y>'] = yank_selected_entry,
            ['<C-o>'] = focus_preview,
          },
        },
      },
      pickers = {
        -- Default configuration for builtin pickers goes here:
        -- picker_name = {
        --   picker_config_key = value,
        --   ...
        -- }
        -- Now the picker_config_key will be applied every time you call this
        -- builtin picker
        find_files = {
          hidden = true, -- show hidden files
          -- find_command = { 'fd', '--type', 'f' },
          find_command = { 'rg', '--files', '--sortr=modified' }, -- rg is faster
          follow = true,
        },
        buffers = {
          mappings = {
            i = { ['<C-x>'] = actions.delete_buffer },
            n = { ['<C-x>'] = actions.delete_buffer },
          },
          initial_mode = 'normal',
        },
        git_status = {
          previewer = true,
        },
        marks = {
          mappings = {
            i = { ['<C-x>'] = actions.delete_mark },
            n = { ['<C-x>'] = actions.delete_mark },
          },
        },
        resume = {
          initial_mode = 'normal',
        },
        -- order result by line number
        current_buffer_fuzzy_find = {
          tiebreak = function(current_entry, existing_entry)
            -- returning true means preferring current entry
            return current_entry.lnum < existing_entry.lnum
          end,
        },
        lsp_references = {
          theme = 'dropdown',
          initial_mode = 'normal',
          layout_strategy = 'vertical',
          layout_config = { height = 0.95 },
          preview = {
            hide_on_startup = false,
          },
          path_display = { 'tail' },
          show_line = true,
        },
      },
      extensions = {
        -- Your extension configuration goes here:
        -- extension_name = {
        --   extension_config_key = value,
        -- }
        ['ui-select'] = {
          require('telescope.themes').get_dropdown({
            previewer = false,
          }),
        },
        -- workspaces = {
        --   -- keep insert mode after selection in the picker, default is false
        --   keep_insert = true,
        -- },
        fzf = {
          fuzzy = true, -- false will only do exact matching
          override_generic_sorter = true, -- override the generic sorter
          override_file_sorter = true, -- override the file sorter
          case_mode = 'smart_case', -- or "ignore_case" or "respect_case"
          -- the default case_mode is "smart_case"
        },
        recent_files = {
          only_cwd = true,
          show_current_file = true,
          -- path_display = function(_, path)
          --   return vim.fn.fnamemodify(path, ':.')
          -- end,
        },
      },
    }
  end,
  config = function(_, opts)
    local telescope = require('telescope')
    telescope.setup(opts)

    pcall(require('telescope').load_extension, 'fzf')
    telescope.load_extension('recent_files')

    local map = vim.keymap.set
    local symbols = {
      'Class',
      'Function',
      'Method',
      'Constructor',
      'Interface',
      'Module',
      'Struct',
      'Trait',
      'Field',
      'Property',
    }
    map('n', '<leader>ls', function()
      require('telescope.builtin').lsp_document_symbols({
        previewer = true,
        symbols = symbols,
      })
    end, { desc = 'Telescope lsp_document_symbols' })
    map('n', '<leader>lww', function()
      require('telescope.builtin').lsp_dynamic_workspace_symbols({
        previewer = true,
        symbols = symbols,
      })
    end, { desc = 'Telescope lsp_dynamic_workspace_symbols' })
  end,
}
