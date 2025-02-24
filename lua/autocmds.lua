local function augroup(name)
  return vim.api.nvim_create_augroup('MyGroup_' .. name, { clear = true })
end

vim.api.nvim_create_autocmd({ 'BufWinEnter' }, {
  desc = 'disable auto-comment on o and O and enter',
  group = augroup('formatoptions'),
  callback = function()
    vim.cmd('set formatoptions-=cro')
    vim.cmd([[set formatexpr=\"]]) -- empty formatexpr so gq uses formatoptions
  end,
})

-- Automatically equalize splits when Vim is resized
vim.cmd([[autocmd VimResized * wincmd =]])

-- automatically open quickfix window and don't jump to first match
vim.cmd([[command! -nargs=+ Grep execute 'silent grep! <args>' | copen]])

-- create new file with :e even if directory doesn't exist
vim.cmd([[
augroup Mkdir
  autocmd!
  autocmd BufWritePre * call mkdir(expand("<afile>:p:h"), "p")
augroup END
]])

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd('BufReadPost', {
  desc = 'go to last loc when opening a buffer',
  group = augroup('last_loc'),
  callback = function(event)
    local exclude = { 'gitcommit' }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].last_loc then
      return
    end
    vim.b[buf].last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- keep window position when switching buffers
-- https://stackoverflow.com/questions/4251533/vim-keep-window-position-when-switching-buffers
-- https://vim.fandom.com/wiki/Avoid_scrolling_when_switch_buffers
-- can be replaced with :set jumpoptions=view (added in 0.8) but `:b buffer` doesn't reset the view
vim.cmd([[
" Save current view settings on a per-window, per-buffer basis.
function! AutoSaveWinView()
  if !exists("w:SavedBufView")
    let w:SavedBufView = {}
  endif
  let w:SavedBufView[bufnr("%")] = winsaveview()
endfunction

" Restore current view settings.
function! AutoRestoreWinView()
  let buf = bufnr("%")
  if exists("w:SavedBufView") && has_key(w:SavedBufView, buf)
    let v = winsaveview()
    let atStartOfFile = v.lnum == 1 && v.col == 0
    if atStartOfFile && !&diff
      call winrestview(w:SavedBufView[buf])
    endif
    unlet w:SavedBufView[buf]
  endif
endfunction

" When switching buffers, preserve window view.
if v:version >= 700
  autocmd BufLeave * call AutoSaveWinView()
  autocmd BufEnter * call AutoRestoreWinView()
endif
]])

-- source: https://github.com/ecosse3/nvim/blob/master/lua/config/autocmds.lua
-- Disable diagnostics in node_modules (0 is current buffer only)
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  desc = 'Disable diagnostics in node_modules',
  group = augroup('disable_diagnostics'),
  pattern = '*/node_modules/*',
  callback = function()
    vim.diagnostic.enable(false, { bufnr = 0 })
  end,
})

-- Enable spell checking for certain file types
-- vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, { pattern = { "*.txt", "*.md", "*.tex" }, command = "setlocal spell" })

vim.api.nvim_create_autocmd({ 'FileType' }, {
  desc = 'close some filetypes with <q>',
  pattern = { 'qf', 'help', 'man', 'spectre_panel', 'startuptime', 'Redir' },
  group = augroup('close_with_q'),
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set('n', 'q', '<Cmd>close<CR>', { buffer = event.buf, silent = true })
  end,
})

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd('FileType', {
  group = augroup('wrap_spell'),
  pattern = { 'gitcommit' },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- vim.api.nvim_create_autocmd('WinEnter', {
--   desc = 'go to insert mode when switching to terminal',
--   group = augroup('terminal'),
--   pattern = 'term://*',
--   command = 'startinsert',
-- })

-- Set options for terminal buffer
-- Use `BufWinEnter term://*` instead of just `TermOpen`
-- just `TermOpen` isn't enough when terminal buffer is created in background
vim.api.nvim_create_autocmd({ 'TermOpen', 'BufWinEnter' }, {
  group = augroup('terminal_options'),
  pattern = 'term://*',
  callback = function()
    vim.cmd([[
      setlocal nonu
      setlocal nornu
      setlocal nolist
      setlocal signcolumn=no
      setlocal foldcolumn=0
      setlocal statuscolumn=
      setlocal nocursorline
      setlocal scrolloff=0
      setlocal sidescrolloff=0
    ]])
  end,
})

vim.api.nvim_create_autocmd('SessionLoadPost', {
  desc = 'change tab title to directory name when loading session',
  group = augroup('change_title'),
  callback = function()
    -- return the tail path of the current working directory
    local dirname = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
    vim.uv.set_process_title(dirname .. ' - nvim')
  end,
})

-- from: https://github.com/zdcthomas/yakko_wakko/blob/main/config/nvim/lua/autocmds.lua
-- delete entries from a quickfix list with `dd`
vim.api.nvim_create_autocmd({ 'FileType' }, {
  desc = 'Delete entry from Quickfix list',
  group = augroup('quickfix'),
  pattern = { 'qf' },
  callback = function()
    vim.keymap.set('n', 'dd', function()
      local current_quick_fix_index = vim.fn.line('.')
      local quickfix_list = vim.fn.getqflist()
      table.remove(quickfix_list, current_quick_fix_index)
      vim.fn.setqflist(quickfix_list, 'r')
      vim.fn.execute(current_quick_fix_index .. 'cfirst')
      vim.cmd('copen')
    end, { buffer = true })
  end,
})

-- save small deletions and yanks to numbered registers
-- from: https://old.reddit.com/r/neovim/comments/1ckyj9a/a_collection_of_registerrelated_hacks/
-- gist: https://gist.github.com/MyyPo/569de2bff5644d2c351d54a0d42ad09f
---@param reg Register
local function shift_reg(reg)
  ---@class Register
  ---@field val string
  ---@field typ string
  for i = 8, 1, -1 do
    vim.fn.setreg(i + 1, vim.fn.getreg(i), vim.fn.getregtype(i))
  end
  vim.fn.setreg('1', reg.val, reg.typ)
end

vim.g.lat_small_reg = vim.fn.getreg('-')
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight on yank, save small deletions and yanks to numbered registers',
  group = augroup('highlight_yank'),
  pattern = '*',
  callback = function()
    if vim.v.event.operator == 'y' then
      -- Highlight the yanked area
      vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 200 })
      -- save yanks in the numbered registers
      shift_reg({ val = vim.fn.getreg('0'), typ = vim.fn.getregtype('0') })
      return
    end
    -- Ignore regular deletes
    if vim.v.event.regtype ~= 'v' then
      return
    end
    -- Save small deletes in numbered registers
    local small = vim.fn.getreg('-')
    if small ~= vim.g.lat_small_reg then
      shift_reg({ val = small, typ = vim.fn.getregtype('-') })
      vim.g.lat_small_reg = small
    end
  end,
})
