return {
  'echasnovski/mini.bufremove',
  keys = {
    {
      '<M-d>',
      function()
        require('mini.bufremove').delete(0, false)
      end,
      desc = 'Delete current buffer',
    },
    {
      '<M-c>',
      function()
        require('mini.bufremove').wipeout(0, false)
      end,
      desc = 'Wipeout current buffer',
    },
  },
}
