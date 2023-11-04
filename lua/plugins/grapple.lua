return {
  'cbochs/grapple.nvim',
  keys = {
    {
      '<leader>w',
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

    vim.api.nvim_create_autocmd('FileType', {
      desc = 'set cursorline and move the cursor to the current file',
      group = vim.api.nvim_create_augroup('MyGroup_grapple', { clear = true }),
      pattern = 'grapple',
      callback = function()
        local path = string.gsub(vim.fn.expand('#'), '/', '\\\\')
        -- add a hl group to current file
        vim.fn.clearmatches()
        vim.fn.matchadd('GrappleCurrentFile', '.*' .. path .. '.*')
        vim.schedule(function()
          -- move the cursor to the line containing the current filename
          -- doesn't work outside of vim.schedule
          vim.fn.search('.*' .. path)
        end)
        vim.opt_local.cursorline = true
        -- select a tag with l
        vim.keymap.set('n', 'l', function()
          local c = vim.api.nvim_get_current_line()
          local key = tonumber(c:match('[%d]'))
          require('grapple').select({ key = key })
        end, { buffer = true })
      end,
    })
  end,
}
