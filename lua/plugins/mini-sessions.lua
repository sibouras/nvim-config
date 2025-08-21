return {
  'echasnovski/mini.sessions',
  opts = function()
    local dart_ok, dart = pcall(require, 'dart')

    return {
      hooks = {
        pre = {
          read = function(session)
            if dart_ok then
              dart.read_session(session['name'])
            end
          end,
          write = function(session)
            if dart_ok then
              dart.write_session(session['name'])
            end
          end,
        },
      },
    }
  end,
  config = function(_, opts)
    local sessions = require('mini.sessions')
    sessions.setup(opts)

    local function get_path()
      -- path looks like this: AppData.Local.nvim
      return vim.fn.fnamemodify(vim.fn.getcwd(), ':~'):gsub(jit.os:find('Windows') and '\\' or '/', '.'):sub(3)
    end

    vim.keymap.set('n', '<leader>sw', function()
      sessions.write(get_path())
    end, { desc = 'Sessions Write' })

    vim.keymap.set('n', '<leader>sr', function()
      sessions.read(get_path())
    end, { desc = 'Sessions Read' })

    vim.keymap.set('n', '<leader>ss', function()
      sessions.select()
    end, { desc = 'Sessions Select' })
  end,
}
