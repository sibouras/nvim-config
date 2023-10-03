return {
  'cbochs/grapple.nvim',
  keys = {
    {
      '<M-e>',
      function()
        require('grapple').popup_tags()
      end,
      mode = 'n',
    },
    {
      '<leader>ha',
      function()
        require('grapple').toggle()
      end,
      mode = 'n',
    },
    {
      '<C-n>',
      function()
        require('grapple').cycle_forward()
      end,
      mode = 'n',
      desc = 'cycle forwards to marked file',
    },
    {
      '<C-p>',
      function()
        require('grapple').cycle_backward()
      end,
      mode = 'n',
      desc = 'cycle backwards to marked file',
    },
  },
  config = function()
    require('grapple').setup({
      scope = require('grapple.scope').resolver(function()
        return vim.fn.getcwd()
      end, { cache = 'DirChanged' }),
    })

    for i = 1, 9 do
      vim.keymap.set('n', i .. '<leader>', function()
        require('grapple').select({ key = i })
      end)
    end

    require('close-unused-buffers')
  end,
}
