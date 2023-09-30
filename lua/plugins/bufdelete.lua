return {
  'famiu/bufdelete.nvim',
  keys = {
    { '<M-d>', '<Cmd>Bdelete<CR>' },
    { '<M-c>', '<Cmd>Bwipeout<CR>' },
    { '<M-S>', '<Cmd>BdeleteHidden<CR>' },
  },
  config = function()
    vim.api.nvim_create_user_command('BdeleteHidden', function()
      local hidden_bufs = vim.tbl_filter(function(bufnr)
        return vim.fn.getbufinfo(bufnr)[1].hidden == 1
      end, vim.api.nvim_list_bufs())

      for _, bufnr in ipairs(hidden_bufs) do
        require('bufdelete').bufdelete(bufnr)
      end
    end, { bang = true, desc = 'delete hidden buffers' })
  end,
}
