return {
  'echasnovski/mini.files',
  enabled = true,
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  keys = {
    {
      '<leader>e',
      function()
        require('mini.files').open(vim.api.nvim_buf_get_name(0))
      end,
      desc = 'Open mini.files directory of current file (in a last used state) with focus on that file.',
    },
    {
      '<leader>E',
      function()
        require('mini.files').open()
      end,
      desc = 'Open mini.files current working directory in a last used state',
    },
  },
  opts = {
    mappings = {
      show_help = '?',
      go_in = ';',
      go_in_plus = 'l',
      go_out_plus = '<tab>',
    },
    content = {
      filter = function(entry)
        return entry.name ~= '.git'
      end,
    },
    windows = {
      -- Whether to show preview of file/directory under cursor
      preview = false,
      -- Width of focused window
      width_focus = 40,
      -- Width of non-focused window
      width_nofocus = 20,
      -- Width of preview window
      width_preview = 25,
    },
  },
  config = function(_, opts)
    local minifiles = require('mini.files')
    minifiles.setup(opts)

    -- Create mapping to show/hide dot-files(from :help mini.files)
    local show_dotfiles = true
    local filter_show = function(fs_entry)
      return true
    end
    local filter_hide = function(fs_entry)
      return not vim.startswith(fs_entry.name, '.')
    end

    local toggle_dotfiles = function()
      show_dotfiles = not show_dotfiles
      local new_filter = show_dotfiles and filter_show or filter_hide
      minifiles.refresh({ content = { filter = new_filter } })
    end

    vim.api.nvim_create_autocmd('User', {
      pattern = 'MiniFilesBufferCreate',
      callback = function(args)
        -- Tweak left-hand side of mapping to your liking
        vim.keymap.set('n', 'g.', toggle_dotfiles, { buffer = args.data.buf_id, desc = 'show/hide dot-files' })
      end,
    })

    -- Create mapping to set current working directory
    local files_set_cwd = function(path)
      -- Works only if cursor is on the valid file system entry
      local cur_entry_path = minifiles.get_fs_entry().path
      local cur_directory = vim.fs.dirname(cur_entry_path)
      print(cur_directory)
      vim.fn.chdir(cur_directory)
    end

    vim.api.nvim_create_autocmd('User', {
      pattern = 'MiniFilesBufferCreate',
      callback = function(args)
        vim.keymap.set('n', 'gd', files_set_cwd, { buffer = args.data.buf_id, desc = 'set cwd' })
      end,
    })

    -- Open a file or directory in your preferred application.
    vim.api.nvim_create_autocmd('User', {
      pattern = 'MiniFilesBufferCreate',
      callback = function(args)
        vim.keymap.set('n', 'go', function()
          local cur_entry_path = minifiles.get_fs_entry().path
          os.execute('start "" "' .. cur_entry_path .. '"')
        end, { buffer = args.data.buf_id, desc = 'open with system application' })
      end,
    })

    -- show/hide preview window
    vim.api.nvim_create_autocmd('User', {
      pattern = 'MiniFilesBufferCreate',
      callback = function(args)
        local is_preview = minifiles.config.windows.preview
        vim.keymap.set('n', 'gp', function()
          is_preview = not is_preview
          minifiles.refresh({ windows = { preview = is_preview } })
        end, { buffer = args.data.buf_id, desc = 'show/hide preview' })
      end,
    })

    -- Add minifiles split keymaps
    local function map_split(buf_id, lhs, direction)
      local function rhs()
        local window = minifiles.get_target_window()
        -- Noop if the explorer isn't open or the cursor is on a directory.
        if window == nil or minifiles.get_fs_entry().fs_type == 'directory' then
          return
        end

        -- Make a new window and set it as target.
        local new_target_window
        vim.api.nvim_win_call(window, function()
          vim.cmd(direction .. ' split')
          new_target_window = vim.api.nvim_get_current_win()
        end)

        minifiles.set_target_window(new_target_window)
        -- Go in and close the explorer.
        minifiles.go_in()
        minifiles.close()
      end

      vim.keymap.set('n', lhs, rhs, { buffer = buf_id, desc = 'Split ' .. string.sub(direction, 12) })
    end

    vim.api.nvim_create_autocmd('User', {
      desc = 'Add minifiles split keymaps',
      pattern = 'MiniFilesBufferCreate',
      callback = function(args)
        local buf_id = args.data.buf_id
        map_split(buf_id, '<C-h>', 'belowright horizontal')
        map_split(buf_id, '<C-v>', 'belowright vertical')
      end,
    })

    -- fix view jump when `o`
    vim.api.nvim_create_autocmd('User', {
      pattern = 'MiniFilesBufferCreate',
      callback = function()
        vim.schedule(function()
          vim.opt_local.scrolloff = 0
        end)
      end,
    })
  end,
}
