return {
  'cbochs/grapple.nvim',
  enabled = false,
  keys = {
    {
      '<leader>i',
      function()
        if vim.g.is_win then
          vim.g.grapple_current_file = string.gsub(vim.fn.expand('%'), '[/\\]', '\\\\')
        else
          vim.g.grapple_current_file = vim.fn.expand('%')
        end
        require('grapple').toggle_tags()
      end,
    },
    {
      '<leader>va',
      function()
        require('grapple').toggle()
        -- vim.cmd.redrawstatus()
      end,
      desc = 'Grapple toggle',
    },
    {
      '<C-n>',
      function()
        require('grapple').cycle_tags('next')
      end,
      desc = 'Cycle forwards to marked file',
    },
    {
      '<C-p>',
      function()
        require('grapple').cycle_tags('previous')
      end,
      desc = 'Cycle backwards to marked file',
    },
  },
  opts = {
    quick_select = '123456789',
    win_opts = {
      width = 60,
      border = 'rounded',
      footer = '', -- disable footer
    },
  },
  config = function(_, opts)
    require('grapple').setup(opts)

    vim.api.nvim_create_autocmd('FileType', {
      desc = 'set cursorline and move the cursor to the current file',
      group = vim.api.nvim_create_augroup('MyGroup_grapple', { clear = true }),
      pattern = 'grapple',
      callback = function()
        local path = vim.g.grapple_current_file
        vim.schedule(function()
          -- move the cursor to the line containing the current filename
          -- doesn't work outside of vim.schedule
          -- vim.fn.search('.*' .. path)
          -- add a hl group to current file
          vim.fn.clearmatches()
          vim.fn.matchadd('GrappleCurrent', path)
          vim.opt_local.cursorline = true
        end)

        -- select a tag with l
        vim.keymap.set('n', 'l', '<CR>', { remap = true, buffer = true, desc = 'Select' })
      end,
    })
  end,
}
