return {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
  keys = {
    { '<leader>gf', '<Cmd>DiffviewFileHistory %<CR>', desc = 'Diffview: Current File history' },
    { '<leader>gF', ':DiffviewFileHistory<CR>', mode = { 'n', 'x' }, desc = 'Diffview: File history' },
    { '<leader>go', '<Cmd>DiffviewOpen<CR>', desc = 'Diffview: Open' },
    { '<leader>gc', '<Cmd>DiffviewClose<CR>', desc = 'Diffview: Close' },
  },
  opts = function()
    local ts_repeat_move = require('nvim-treesitter.textobjects.repeatable_move')
    local next_hunk_repeat, prev_hunk_repeat = ts_repeat_move.make_repeatable_move_pair(function()
      vim.cmd('norm! ]c')
    end, function()
      vim.cmd('norm! [c')
    end)
    return {
      keymaps = {
        view = {
          [']g'] = function()
            next_hunk_repeat()
          end,
          ['[g'] = function()
            prev_hunk_repeat()
          end,
        },
      },
    }
  end,
}
