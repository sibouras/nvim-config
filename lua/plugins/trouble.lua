return {
  'folke/trouble.nvim',
  cmd = 'Trouble',
  opts = {},
  keys = {
    { '<leader>qq', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Diagnostics (Trouble)' },
    { '<leader>qd', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Buffer Diagnostics (Trouble)' },
    { '<leader>qs', '<cmd>Trouble symbols toggle<cr>', desc = 'Symbols (Trouble)' },
    { '<leader>qr', '<cmd>Trouble lsp toggle focus=true<cr>', desc = 'Lsp References (Trouble)' },
    { '<leader>ql', '<cmd>Trouble loclist toggle<cr>', desc = 'Location List (Trouble)' },
    { '<leader>qx', '<cmd>Trouble quickfix toggle<cr>', desc = 'Quickfix List (Trouble)' },
    {
      '<Down>',
      function()
        if require('trouble').is_open() then
          require('trouble').next({ skip_groups = true, jump = false })
        else
          vim.cmd('+1')
        end
      end,
      desc = 'Next trouble/quickfix item',
    },
    {
      '<Up>',
      function()
        if require('trouble').is_open() then
          require('trouble').prev({ skip_groups = true, jump = false })
        else
          vim.cmd('-1')
        end
      end,
      desc = 'Previous trouble/quickfix item',
    },
    {
      ']x',
      function()
        if require('trouble').is_open() then
          require('trouble').next({ skip_groups = true, jump = true })
        else
          local ok, err = pcall(vim.cmd.cnext)
          if not ok then
            vim.notify(err, vim.log.levels.ERROR)
          end
        end
      end,
      desc = 'Next trouble/quickfix item and jump',
    },
    {
      '[x',
      function()
        if require('trouble').is_open() then
          require('trouble').previous({ skip_groups = true, jump = true })
        else
          local ok, err = pcall(vim.cmd.cprev)
          if not ok then
            vim.notify(err, vim.log.levels.ERROR)
          end
        end
      end,
      desc = 'Previous trouble/quickfix item and jump',
    },
  },
}
