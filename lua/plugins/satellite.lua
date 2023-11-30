return {
  'lewis6991/satellite.nvim',
  event = { 'BufReadPost' },
  enabled = false, -- overrides folding keymaps
  opts = {
    handlers = {
      gitsigns = {
        enable = false,
      },
    },
  },
}
