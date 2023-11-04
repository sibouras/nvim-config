return {
  'https://git.sr.ht/~marcc/BufferBrowser',
  event = { 'BufReadPre', 'BufNewFile' },
  enabled = false,
  keys = {
    {
      '<M-Right>',
      function()
        require('buffer_browser').next()
      end,
      mode = { 'i', 'n' },
      desc = 'Next Buffer',
    },
    {
      '<M-Left>',
      function()
        require('buffer_browser').prev()
      end,
      mode = { 'i', 'n' },
      desc = 'Previous Buffer',
    },
  },
  opts = {},
}
