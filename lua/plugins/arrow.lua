return {
  'otavioschwanck/arrow.nvim',
  keys = { '<leader>i', '<leader>o' },
  opts = {
    show_icons = true,
    leader_key = '<leader>i',
    buffer_leader_key = '<leader>o',
    hide_handbook = true,
    mappings = {
      toggle = 'i', -- used as save if separate_save_and_remove is true
      open_vertical = 'v',
      open_horizontal = 's',
      next_item = 'j',
      prev_item = 'k',
    },
    window = {
      border = 'rounded',
    },
  },
}
