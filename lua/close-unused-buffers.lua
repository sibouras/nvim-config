-- from: https://old.reddit.com/r/neovim/comments/12c4ad8/closing_unused_buffers/
local id = vim.api.nvim_create_augroup('startup', {
  clear = false,
})

local persistbuffer = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  vim.fn.setbufvar(bufnr, 'bufpersist', 1)
end

vim.api.nvim_create_autocmd({ 'BufRead' }, {
  group = id,
  pattern = { '*' },
  callback = function()
    vim.api.nvim_create_autocmd({ 'InsertEnter', 'BufModifiedSet' }, {
      buffer = 0,
      once = true,
      callback = function()
        persistbuffer()
      end,
    })
  end,
})

local function close_unused_buffers()
  local curbufnr = vim.api.nvim_get_current_buf()
  local buflist = vim.api.nvim_list_bufs()
  -- local is_on_arrow_file = require('arrow.statusline').is_on_arrow_file

  for _, bufnr in ipairs(buflist) do
    if
      vim.bo[bufnr].buflisted
      and bufnr ~= curbufnr
      and (vim.fn.getbufvar(bufnr, 'bufpersist') ~= 1)
      -- and not is_on_arrow_file(bufnr)
    then
      vim.cmd('bd ' .. tostring(bufnr))
    end
  end
end

vim.keymap.set('n', '<Leader>db', close_unused_buffers, { silent = true, desc = 'Close unused buffers' })

-- close unused buffers before exiting nvim
-- vim.api.nvim_create_autocmd({ 'VimLeavePre' }, {
--   group = vim.api.nvim_create_augroup('close unused buffers', { clear = true }),
--   pattern = '*',
--   callback = close_unused_buffers,
-- })
