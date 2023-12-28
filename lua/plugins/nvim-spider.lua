return {
  'chrisgrieser/nvim-spider',
  enabled = true,
  keys = {
    { 'W', "<cmd>lua require('spider').motion('w')<CR>", mode = { 'n', 'o', 'x' } },
    { 'E', "<cmd>lua require('spider').motion('e')<CR>", mode = { 'n', 'o', 'x' } },
    { 'B', "<cmd>lua require('spider').motion('b')<CR>", mode = { 'n', 'o', 'x' } },
  },
  opts = {
    skipInsignificantPunctuation = true,
    subwordMovement = false,
  },
}
