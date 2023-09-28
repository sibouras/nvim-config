-- Any files inside the lua/plugins directory will also
-- automatically be sourced. These plugins are those that
-- do not require any configuration.

return {
  -- the colorscheme should be available when starting Neovim
  'folke/which-key.nvim',
  { 'dstein64/vim-startuptime', cmd = 'StartupTime', enabled = true },
  'famiu/bufdelete.nvim',
  'svban/YankAssassin.vim',
  'Sangdol/mintabline.vim',
  {
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
  },
  {
    'echasnovski/mini.pairs',
    event = 'VeryLazy',
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
  },
}
