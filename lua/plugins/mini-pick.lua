return {
  'nvim-mini/mini.pick',
  cmd = 'Pick',
  dependencies = {
    'nvim-mini/mini.extra',
  },
  opts = {},
  config = function(_, opts)
    require('mini.pick').setup(opts)
    require('mini.extra').setup()
  end,
}
