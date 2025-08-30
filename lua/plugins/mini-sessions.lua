return {
  'nvim-mini/mini.sessions',
  opts = {},
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
