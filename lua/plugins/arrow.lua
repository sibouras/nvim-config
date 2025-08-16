return {
  'otavioschwanck/arrow.nvim',
  keys = { '<leader>j', '<leader>n' },
  opts = {
    show_icons = true,
    leader_key = '<leader>j',
    buffer_leader_key = '<leader>n',
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
