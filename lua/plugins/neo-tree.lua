return {
  'nvim-neo-tree/neo-tree.nvim',
  enabled = false,
  cmd = 'Neotree',
  -- branch = 'v3.x',
  keys = {
    { '<leader>e', '<CMD>Neotree toggle float<CR>', desc = 'NeoTree' },
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
  },
  opts = {
    filesystem = {
      bind_to_cwd = false,
      follow_current_file = { enabled = false },
      use_libuv_file_watcher = true,
    },
  },
}
