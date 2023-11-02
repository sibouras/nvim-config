return {
  'samjwill/nvim-unception',
  enabled = true,
  init = function()
    vim.api.nvim_create_autocmd('User', {
      pattern = 'UnceptionEditRequestReceived',
      callback = function()
        -- Toggle the terminal off.
        vim.cmd('close')
      end,
    })
  end,
}
