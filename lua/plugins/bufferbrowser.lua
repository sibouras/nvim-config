return {
  'https://git.sr.ht/~marcc/BufferBrowser',
  event = { 'BufReadPre', 'BufNewFile' },
  keys = {
    {
      '<M-Right>',
      function()
        require('buffer_browser').next()
      end,
      mode = { 'i', 'n' },
      desc = 'Next [B]uffer [[]',
    },
    {
      '<M-Left>',
      function()
        require('buffer_browser').prev()
      end,
      mode = { 'i', 'n' },
      desc = 'Previous [B]uffer []]',
    },
  },
  opts = {},
}
