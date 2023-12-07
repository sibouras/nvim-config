return {
  {
    'JoosepAlviste/nvim-ts-context-commentstring',
    lazy = true,
    opts = {
      enable_autocmd = false,
    },
  },
  {
    'echasnovski/mini.comment',
    event = 'VeryLazy',
    enabled = false,
    opts = {
      options = {
        custom_commentstring = function()
          return require('ts_context_commentstring.internal').calculate_commentstring() or vim.bo.commentstring
        end,
      },
    },
  },
  {
    'numToStr/Comment.nvim',
    enabled = true,
    keys = {
      { 'gc', mode = { 'n', 'v' }, desc = 'Coment toggle linewise' },
      { 'gb', mode = { 'n', 'v' }, desc = 'Coment toggle blockwise' },
    },
    config = function()
      require('Comment').setup({
        pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
      })
    end,
  },
}
