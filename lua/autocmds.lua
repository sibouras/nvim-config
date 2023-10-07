local function augroup(name)
  return vim.api.nvim_create_augroup('MyGroup_' .. name, { clear = true })
end

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight on yank',
  group = augroup('highlight_yank'),
  callback = function()
    vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 200 })
  end,
})

vim.api.nvim_create_autocmd({ 'BufWinEnter' }, {
  desc = 'disable auto-comment on o and O and enter',
  group = augroup('formatoptions'),
  callback = function()
    vim.cmd('set formatoptions-=cro')
    vim.cmd([[set formatexpr=\"]]) -- empty formatexpr so gq uses formatoptions
  end,
})

-- Only show the cursor line in the active buffer.
-- vim.cmd([[
--   augroup CursorLine
--       au!
--       au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
--       au WinLeave * setlocal nocursorline
--   augroup END
-- ]])

-- hide cursor line when nvim loses focus
vim.cmd([[
  augroup CursorLine
      au!
      au FocusGained * setlocal cursorline
      au FocusLost * setlocal nocursorline
      " au FocusGained * highlight Cursor guifg=black guibg=#7aa2f7
      " au FocusLost * highlight Cursor guifg=black guibg=#546faa
  augroup END
]])

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
  command = 'lua vim.diagnostic.disable(0)',
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

vim.api.nvim_create_autocmd({ 'User' }, {
  desc = 'Remove statusline and tabline when in Alpha',
  pattern = { 'AlphaReady' },
  group = augroup('alpha'),
  callback = function()
    vim.cmd([[
      " set showtabline=0 | autocmd BufUnload <buffer> set showtabline=2
      set laststatus=0 | autocmd BufUnload <buffer> set laststatus=3
    ]])
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

vim.api.nvim_create_autocmd('WinEnter', {
  desc = 'go to insert mode when switching to terminal',
  group = augroup('terminal'),
  pattern = 'term://*',
  command = 'startinsert',
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
