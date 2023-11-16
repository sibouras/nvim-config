return {
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'smartpde/telescope-recent-files',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = vim.fn.executable('make') == 1,
      },
    },
    config = function()
      local telescope = require('telescope')
      local actions = require('telescope.actions')

      local open_with_trouble = function(...)
        return require('trouble.providers.telescope').open_with_trouble(...)
      end

      local open_selected_with_trouble = function(...)
        return require('trouble.providers.telescope').open_selected_with_trouble(...)
      end

      local function yank_selected_entry(prompt_bufnr)
        local entry = require('telescope.actions.state').get_selected_entry().value
        actions.close(prompt_bufnr)
        local clipboardOpt = vim.opt.clipboard:get()
        local useSystemClipb = #clipboardOpt > 0 and clipboardOpt[1]:find('unnamed')
        local reg = useSystemClipb and '+' or '"'
        vim.fn.setreg(reg, entry)
      end

      telescope.setup({
        defaults = {
          prompt_prefix = ' ',
          selection_caret = ' ',
          path_display = { 'shorten' },
          file_ignore_patterns = { '.git\\', 'node_modules', '^.nvim' },
          sorting_strategy = 'ascending',
          layout_strategy = 'flex',
          layout_config = {
            height = 0.9,
            prompt_position = 'top',
            -- preview_cutoff = 100,
            horizontal = {
              preview_width = 0.5,
            },
            vertical = {
              mirror = true,
              preview_cutoff = 30,
              -- preview_height = 0.5,
            },
          },
          preview = {
            hide_on_startup = true, -- hide previewer when picker starts
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
              ['<C-h>'] = actions.select_horizontal,
              ['<C-v>'] = actions.select_vertical,
              ['<C-n>'] = actions.select_tab,
              ['<C-u>'] = actions.preview_scrolling_up,
              ['<C-d>'] = actions.preview_scrolling_down,
              ['<PageUp>'] = actions.results_scrolling_up,
              ['<PageDown>'] = actions.results_scrolling_down,
              ['<C-Left>'] = actions.preview_scrolling_left,
              ['<C-Right>'] = actions.preview_scrolling_right,
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
              ['<c-t>'] = open_with_trouble,
              ['<M-t>'] = open_selected_with_trouble,
              ['<C-y>'] = yank_selected_entry,
            },
            n = {
              ['`'] = actions.close,
              ['<esc>'] = actions.close,
              ['q'] = actions.close,
              ['<CR>'] = actions.select_default,
              ['l'] = actions.select_default,
              ['<C-h>'] = actions.select_horizontal,
              ['<C-v>'] = actions.select_vertical,
              ['<C-n>'] = actions.select_tab,
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
              ['<C-Left>'] = actions.preview_scrolling_left,
              ['<C-Right>'] = actions.preview_scrolling_right,
              ['<M-Left>'] = actions.results_scrolling_left,
              ['<M-Right>'] = actions.results_scrolling_right,
              ['?'] = actions.which_key,
              ['<C-p>'] = require('telescope.actions.layout').toggle_preview,
              ['<C-q>'] = actions.send_to_qflist + actions.open_qflist,
              ['<M-q>'] = actions.send_selected_to_qflist + actions.open_qflist,
              ['<C-t>'] = open_with_trouble,
              ['<M-t>'] = open_selected_with_trouble,
              ['<C-y>'] = yank_selected_entry,
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
            path_display = { 'smart' },
            find_command = { 'fd', '--type', 'f' },
            follow = true,
          },
          buffers = {
            mappings = {
              i = { ['<C-x>'] = actions.delete_buffer },
              n = { ['<C-x>'] = actions.delete_buffer },
            },
            path_display = { 'smart' },
            initial_mode = 'normal',
            -- ignore_current_buffer = true,
            sort_mru = true,
            -- sort_lastused = true,
            previewer = false,
            -- layout_config = {
            --   width = 0.5,
            --   height = 0.5,
            --   preview_cutoff = 120,
            -- },
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
            path_display = function(_, path)
              return vim.fn.fnamemodify(path, ':.')
            end,
          },
          tailiscope = {
            -- initial_mode = "normal",
            -- theme = "dropdown",
            -- layout_strategy = "vertical",
            -- layout_config = { height = 0.95 },
            layout_config = {
              vertical = {
                preview_height = 0.2,
              },
            },
            preview = {
              hide_on_startup = false,
            },
            register = '"',
            maps = {
              i = {
                back = '<C-h>',
                open_doc = '<C-o>',
              },
              n = {
                back = 'h',
                open_doc = 'o',
              },
            },
          },
        },
      })

      pcall(require('telescope').load_extension, 'fzf')
      telescope.load_extension('recent_files')
    end,
  },
}
