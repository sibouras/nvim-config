return {
  'echasnovski/mini.pairs',
  event = 'VeryLazy',
  enabled = false,
  keys = {
    {
      '<M-e>',
      function()
        vim.g.minipairs_disable = not vim.g.minipairs_disable
      end,
      mode = 'i',
      desc = 'Toggle auto pairs',
    },
  },
  opts = {
    modes = { insert = true, command = true, terminal = false },
  },
}
