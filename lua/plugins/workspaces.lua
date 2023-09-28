return {
  {
    'natecraddock/sessions.nvim',
    cmd = 'SessionsStop', -- needed for workspaces
    keys = {
      { '<leader>sl', ':SessionsLoad<CR>', silent = true },
      { '<leader>ss', ':SessionsSave<CR>', silent = true },
      { '<leader>sd', ':SessionsStop<CR>', silent = true },
    },
    opts = {
      session_filepath = vim.fn.stdpath('data') .. '/sessions',
      absolute = true,
    },
  },
  {
    'natecraddock/workspaces.nvim',
    opts = {
      hooks = {
        -- hooks run before change directory
        open_pre = {
          -- If recording, save current session state and stop recording
          'SessionsStop',
          -- delete all buffers (does not save changes)
          'silent %bdelete!',
          -- clear the jumplist
          'clearjumps',
        },

        -- hooks run after change directory
        -- open = "Telescope find_files",
        -- load any saved session from current directory
        open = function()
          require('sessions').load(nil, { silent = true })
        end,
      },
    },
  },
}
