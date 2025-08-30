return {
  {
    'folke/ts-comments.nvim',
    enabled = false,
    event = 'VeryLazy',
    opts = {},
  },
  {
    'JoosepAlviste/nvim-ts-context-commentstring',
    enabled = false,
    lazy = true,
    opts = {
      enable_autocmd = false,
    },
    config = function(_, opts)
      -- to skip backwards compatibility routines and speed up loading.
      vim.g.skip_ts_context_commentstring_module = true
      require('ts_context_commentstring').setup(opts)
    end,
  },
  {
    'nvim-mini/mini.comment',
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
    enabled = false,
    keys = {
      { 'gc', mode = { 'n', 'x' }, desc = 'Coment toggle linewise' },
      { 'gb', mode = { 'n', 'x' }, desc = 'Coment toggle blockwise' },
    },
    config = function()
      require('Comment').setup({
        pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
      })
    end,
  },
}
