return {
  {
    'natecraddock/sessions.nvim',
    enabled = false,
    cmd = { 'SessionsStop', 'SessionsLoad' },
    keys = {
      { '<leader>sl', ':SessionsLoad<CR>', desc = 'Sessions Load', silent = true },
      { '<leader>ss', ':SessionsSave<CR>', desc = 'Sessions Save', silent = true },
      { '<leader>sd', ':SessionsStop<CR>', desc = 'Sessions Stop', silent = true },
    },
    opts = {
      session_filepath = vim.fn.stdpath('data') .. '/sessions',
      absolute = true,
    },
  },
  {
    'natecraddock/workspaces.nvim',
    enabled = false,
    cmd = { 'WorkspacesAdd', 'WorkspacesOpen' },
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
