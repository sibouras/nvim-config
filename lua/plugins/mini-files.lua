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
      go_in_plus = '<cr>',
      go_out_plus = '<tab>',
    },
    content = {
      filter = function(entry)
        return entry.name ~= '.git'
      end,
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
        vim.keymap.set('n', 'g.', toggle_dotfiles, { buffer = args.data.buf_id })
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
        vim.keymap.set('n', 'gd', files_set_cwd, { buffer = args.data.buf_id })
      end,
    })

    -- Open a file or directory in your preferred application.
    vim.api.nvim_create_autocmd('User', {
      pattern = 'MiniFilesBufferCreate',
      callback = function(args)
        vim.keymap.set('n', 'go', function()
          local cur_entry_path = minifiles.get_fs_entry().path
          os.execute('start "" "' .. cur_entry_path .. '"')
        end, { buffer = args.data.buf_id })
      end,
    })
  end,
}
