return {
  'cbochs/grapple.nvim',
  commit = '7ba87862ab42f0819127eee50875b794596ddb8c',
  keys = {
    {
      '<leader>w',
      function()
        require('grapple').toggle_tags()
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
    for i = 1, 9 do
      vim.keymap.set('n', i .. '<leader>', function()
        require('grapple').select({ index = i })
      end)
    end

    vim.api.nvim_create_autocmd('FileType', {
      desc = 'set cursorline and move the cursor to the current file',
      group = vim.api.nvim_create_augroup('MyGroup_grapple', { clear = true }),
      pattern = 'grapple',
      callback = function()
        local buflist = vim.tbl_filter(function(buf)
          return vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted
        end, vim.api.nvim_list_bufs())

        local bufnumber
        local bufnr_lastused = -1
        for _, bufnr in pairs(buflist) do
          local bufinfo = vim.fn.getbufinfo(bufnr)[1]
          if bufinfo.lastused > bufnr_lastused then
            bufnumber = bufnr
            bufnr_lastused = bufinfo.lastused
          end
        end

        if bufnumber then
          local buf = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnumber), ':.')
          local path = string.gsub(buf, '[/\\]', '\\\\')
          vim.schedule(function()
            -- move the cursor to the line containing the current filename
            -- doesn't work outside of vim.schedule
            vim.fn.search('.*' .. path)
            -- add a hl group to current file
            vim.fn.clearmatches()
            vim.fn.matchadd('GrappleCurrentFile', path)
            vim.opt_local.cursorline = true
          end)
        end

        -- select a tag with l
        vim.keymap.set('n', 'l', '<CR>', { remap = true, buffer = true })
      end,
    })
  end,
}
