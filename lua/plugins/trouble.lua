return {
  'folke/trouble.nvim',
  cmd = { 'TroubleToggle', 'Trouble' },
  keys = {
    { '<leader>qq', '<cmd>TroubleToggle<cr>', desc = 'Toggle Trouble' },
    { '<leader>qd', '<cmd>TroubleToggle document_diagnostics<cr>', desc = 'Document Diagnostics (Trouble)' },
    { '<leader>qw', '<cmd>TroubleToggle workspace_diagnostics<cr>', desc = 'Workspace Diagnostics (Trouble)' },
    { '<leader>ql', '<cmd>TroubleToggle loclist<cr>', desc = 'Location List (Trouble)' },
    { '<leader>qx', '<cmd>TroubleToggle quickfix<cr>', desc = 'Quickfix List (Trouble)' },
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
          require('trouble').previous({ skip_groups = true, jump = false })
        else
          vim.cmd('-1')
        end
      end,
      desc = 'Previous trouble/quickfix item',
    },
    {
      ']q',
      function()
        if require('trouble').is_open() then
          require('trouble').next({ skip_groups = true, jump = true })
        else
          local ok, err = pcall(vim.cmd.cnext)
          if not ok then
            print(err, vim.log.levels.ERROR)
          end
        end
      end,
      desc = 'Next trouble/quickfix item and jump',
    },
    {
      '[q',
      function()
        if require('trouble').is_open() then
          require('trouble').previous({ skip_groups = true, jump = true })
        else
          local ok, err = pcall(vim.cmd.cprev)
          if not ok then
            print(err, vim.log.levels.ERROR)
          end
        end
      end,
      desc = 'Previous trouble/quickfix item and jump',
    },
  },
}
