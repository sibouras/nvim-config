return {
  'ggandor/leap.nvim',
  enabled = false,
  keys = {
    { 's', mode = { 'n', 'x', 'o' }, desc = 'Leap forward to' },
    { 'S', mode = { 'n', 'x', 'o' }, desc = 'Leap backward to' },
    { 'gs', mode = { 'n', 'x', 'o' }, desc = 'Leap from windows' },
  },
  config = function()
    require('leap').add_default_mappings()

    -- Workaround for the duplicate cursor bug
    vim.api.nvim_create_autocmd('User', {
      callback = function()
        vim.cmd.hi('Cursor', 'blend=100')
        vim.opt.guicursor:append({ 'a:Cursor/lCursor' })
      end,
      pattern = 'LeapEnter',
    })
    vim.api.nvim_create_autocmd('User', {
      callback = function()
        vim.cmd.hi('Cursor', 'blend=0')
        vim.opt.guicursor:remove({ 'a:Cursor/lCursor' })
      end,
      pattern = 'LeapLeave',
    })
  end,
}
