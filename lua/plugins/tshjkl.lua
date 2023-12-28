return {
  'gsuuon/tshjkl.nvim',
  enabled = false,
  keys = '<M-v>',
  opts = {
    select_current_node = false, -- false to highlight only
    marks = {
      parent = {
        hl_group = 'CursorLine',
      },
      child = {
        hl_group = 'IlluminatedWord',
      },
      prev = {
        hl_group = 'DiffDelete',
      },
      next = {
        hl_group = 'DiffAdd',
      },
      current = {
        hl_group = 'Visual',
      },
    },
  },
}
