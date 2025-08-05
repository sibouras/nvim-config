vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 0

local map = vim.keymap.set
local opts = { noremap = true, silent = true, buffer = 0 }

-- search markdown links
map('n', '<Tab>', "<Cmd>call search('\\[[^]]*\\]([^)]\\+)')<CR>", opts)
map('n', '<S-Tab>', "<Cmd>call search('\\[[^]]*\\]([^)]\\+)', 'b')<CR>", opts)

-- open url if markdown link is a url else `gf`
map('n', '<CR>', ":lua require('essentials').go_to_url('start')<CR>", opts)

-- close floating lsp hover window with Esc
if vim.api.nvim_win_get_config(0).relative == 'win' then
  vim.keymap.set('n', '<Esc>', '<Cmd>bdelete<CR>', { buffer = 0, silent = true })
end

-- from: https://github.com/antonk52/dot-files/blob/master/nvim/ftplugin/markdown.lua
vim.keymap.set('n', '<leader>t', function()
  -- save cursor position
  local cursor = vim.api.nvim_win_get_cursor(0)
  local content = vim.api.nvim_get_current_line()
  local res = vim.fn.match(content, '\\[ \\]')
  if res == -1 then
    vim.fn.execute('.s/\\[[x~]\\]/[ ]')
  else
    vim.fn.execute('.s/\\[ \\]/[x]')
  end
  -- restore cursor position
  vim.api.nvim_win_set_cursor(0, cursor)
end, { buffer = 0, silent = true, desc = 'Toggle checkbox' })
vim.keymap.set('n', 'j', 'gj', { buffer = 0 })
vim.keymap.set('n', 'k', 'gk', { buffer = 0 })
