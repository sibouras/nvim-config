return {
  'lewis6991/satellite.nvim',
  event = { 'BufReadPost' },
  enabled = true,
  opts = {
    handlers = {
      gitsigns = {
        enable = false,
      },
    },
  },
}
