return {
  'nvim-neo-tree/neo-tree.nvim',
  enabled = false,
  cmd = 'Neotree',
  branch = 'v2.x',
  keys = {
    { '<leader>e', '<CMD>NeoTreeFloatToggle<CR>', desc = 'NeoTree' },
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
  },
  opts = {
    filesystem = {
      follow_current_file = false,
    },
  },
}
