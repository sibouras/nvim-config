local function map(mode, lhs, rhs, opts)
  local options = { silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

-- Horizontal scroll
map({ 'n', 'i', 'v' }, '<S-ScrollWheelUp>', '<ScrollWheelLeft>')
map({ 'n', 'i', 'v' }, '<S-ScrollWheelDown>', '<ScrollWheelRight>')

-- distinguish between <Tab> and <C-i> (ctrl+i is mapped to <M-C-S-F6> in ahk,terminal)
map('n', '<M-C-S-F6>', '<C-i>')

-- change mapping for digraphs
map('i', '<C-f>', '<C-k>')

-- helix muscle memory
map('n', 'U', ':redo<CR>')

-- Quit vim
map('n', '<M-F4>', ':qa!<CR>')
map('n', '<C-q>', ':qa!<CR>')
map('n', '<C-c>', ':q<CR>')
vim.cmd('command! -bang Q quit<bang>')

-- new line
map('i', '<C-CR>', '<C-o>o')

-- clear highlight/messages
map('n', '<Esc>', function()
  vim.cmd.nohlsearch()
  vim.cmd.stopinsert()
  return '<Esc>'
end, { desc = 'Escape and clear hlsearch/messages', expr = true })

-- vim.keymap.set({ 'i', 's', 'n' }, '<esc>', function()
--   if require('luasnip').expand_or_jumpable() then
--     require('luasnip').unlink_current()
--   end
--   vim.cmd('noh')
--   return '<esc>'
-- end, { desc = 'Escape, clear hlsearch, and stop snippet session', expr = true })

-- Clear search, diff update and redraw
-- taken from runtime/lua/_editor.lua
-- map(
--   'n',
--   '<C-l>',
--   '<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>',
--   { desc = 'Redraw / clear hlsearch / diff update' }
-- )

-- Stay in indent mode
map('v', '<', '<gv')
map('v', '>', '>gv')

-- search for word under cursor without moving
-- map('n', 'gw', '*N')
-- map('n', 'gw', [[:%s/<C-r>=expand('<cword>')<CR>//n<CR>]])
-- map('n', 'gW', '<Cmd>norm! gd<CR>')
-- map('x', 'gW', [[y/\V<C-R>"<CR>N]])

map('n', '[/', '[<c-i>') -- `:h [_ctrl-i`

--> Navigate buffers
-- NOTE: b# doesn't work with jumpoption=view
-- from: https://sharats.me/posts/automating-the-vim-workplace/#switching-to-alternate-buffer
-- My remapping of <C-^>. If there is no alternate file, and there's no count
-- given, then switch to next file. We use `bufloaded` to check for alternate
-- buffer presence. This will ignore deleted buffers, as intended. To get
-- default behaviour, use `bufexists` in it's place.
-- map('n', '<M-w>', ":<C-u>exe v:count ? v:count . 'b' : 'keepjumps b' . (bufloaded(0) ? '#' : 'n')<CR>")
-- map('i', '<M-w>', "<C-o>:exe v:count ? v:count . 'b' : 'keepjumps b' . (bufloaded(0) ? '#' : 'n')<CR>")
-- this switches to the last used buffer even if its deleted
-- map({ 'n', 'i' }, '<M-w>', '<Cmd>keepjumps normal <CR>')

-- switch to the most recently used buffer that's not deleted
local function switch_mru_buffer(n)
  return function()
    local curbufnr = vim.api.nvim_get_current_buf()
    local buflist = vim.tbl_filter(function(buf)
      return vim.api.nvim_buf_is_loaded(buf)
        and (vim.bo[buf].buflisted or vim.bo[buf].buftype == 'help')
        and buf ~= curbufnr
    end, vim.api.nvim_list_bufs())

    -- table is empty if buffers are not loaded
    if #buflist == 0 and #vim.fn.expand('#') > 0 then
      vim.cmd('keepjumps e#') -- with b# the file doesn't show in :buffers
    elseif buflist[n] == nil then
      vim.notify('No previous buffer found', vim.log.levels.ERROR)
    else
      table.sort(buflist, function(a, b)
        return vim.fn.getbufinfo(a)[1].lastused > vim.fn.getbufinfo(b)[1].lastused
      end)
      vim.cmd('keepjumps b' .. buflist[n])
    end
  end
end

map({ 'n', 'i' }, '<M-w>', switch_mru_buffer(1), { desc = 'Switch to most recently used buffer' })
map('n', '<leader>w', switch_mru_buffer(2), { desc = 'Switch to second most recently used buffer' })

-- Navigate tabs
-- Number + , to select a tab, i.e. type 1, to select the first tab.
-- for i = 1, 9 do
--   map('n', i .. ',', i .. 'gt')
-- end

-- -- Switch to last active tab
-- vim.cmd([[
--   if !exists('g:Lasttab')
--     let g:Lasttab = 1
--     let g:Lasttab_backup = 1
--   endif
--   autocmd! TabLeave * let g:Lasttab_backup = g:Lasttab | let g:Lasttab = tabpagenr()
--   autocmd! TabClosed * let g:Lasttab = g:Lasttab_backup
--   nmap <silent> <C-h> :exe "tabn " . g:Lasttab<cr>
-- ]])

-- toggle current buffer with the full-screen using :tabedit %
-- from: https://old.reddit.com/r/neovim/comments/1msuasw/a_simple_shortcut_to_toggle_focus_on_a_splited/n971zqy/
map('n', '<C-w>m', function()
  local current_buf = vim.api.nvim_get_current_buf()
  local tabs = vim.api.nvim_list_tabpages()
  local pos = vim.api.nvim_win_get_cursor(0)

  if #tabs > 1 then
    for _, tab in ipairs(tabs) do
      local win = vim.api.nvim_tabpage_get_win(tab)
      local buf = vim.api.nvim_win_get_buf(win)

      if buf == current_buf and tab ~= vim.api.nvim_get_current_tabpage() then
        vim.api.nvim_win_set_cursor(win, pos)
        vim.cmd('tabclose')
        return
      end
    end
  end

  vim.cmd('tabedit %')

  local win = vim.api.nvim_get_current_win()
  local line_count = vim.api.nvim_buf_line_count(0)
  local line = math.min(pos[1], line_count)
  vim.api.nvim_win_set_cursor(win, { line, pos[2] })
end, { desc = 'toggle current buffer with the full-screen using :tabedit %' })

-- Move text up and down(using nvim-gomove instead)
-- map("n", "<A-j>", "<Esc>:m .+1<CR>==gi")
-- map("n", "<A-k>", "<Esc>:m .-2<CR>==gi")

-- df to escape
-- map("i", "df", "<ESC>")

-- quick save
map({ 'n', 'x' }, '<M-s>', '<Cmd>silent update<CR>')
map('i', '<M-s>', '<Esc>:silent update<CR>')

-- Ctrl-Backspace to delete the previous word
map('i', '<C-BS>', '<C-w>', { noremap = false })
map('c', '<C-BS>', '<C-w>', { silent = false })

map('i', '<C-Del>', '<C-o>dw')

-- ctrl-z to undo
map('i', '<C-z>', '<C-o>:u<CR>')

-- -- undo break points
-- local undo_ch = { ',', '!', '?', ';' }
-- for _, ch in ipairs(undo_ch) do
--   map('i', ch, ch .. '<C-g>u')
-- end

-- Store relative line number jumps in the jumplist if they exceed a threshold.
map('n', 'k', '(v:count > 5 ? "m\'" . v:count : "") . "gk"', { expr = true })
map('n', 'j', '(v:count > 5 ? "m\'" . v:count : "") . "gj"', { expr = true })

-- When the :keepjumps command modifier is used, jumps are not stored in the jumplist.
-- map('n', '{', ":execute 'keepjumps norm! ' . v:count1 . '{'<CR>")
-- map('n', '}', ":execute 'keepjumps norm! ' . v:count1 . '}'<CR>")
-- map('n', '(', ":execute 'keepjumps norm! ' . v:count1 . '('<CR>")
-- map('n', ')', ":execute 'keepjumps norm! ' . v:count1 . ')'<CR>")

-- search for regex pattern
-- map({ 'n', 'x', 'o' }, '(', "<Cmd>call search('[({]')<CR>")
-- map({ 'n', 'x', 'o' }, ')', "<Cmd>call search('[)}]')<CR>")

-- scroll with <C-j> <C-k>
-- from: https://vi.stackexchange.com/questions/10031/scroll-a-quarter-25-of-the-screen-up-or-down
vim.cmd([[
function! ScrollGolden(move)
  let height=winheight(0)
  if a:move == 'up'
    let prep='H'
    " let key="^Y"
    let key='gk'
    let post='zt'
  elseif a:move == 'down'
    let prep='L'
    " let key="^E"
    let key='gj'
    let post='zb'
  endif
  "execute 'keepjumps normal! ' . prep . float2nr(round(height*0.24)) . key . post
  execute 'keepjumps normal! ' . prep . 5 . key
endfunction
nnoremap <silent> <C-k> <cmd>call ScrollGolden('up')<CR>
vnoremap <silent> <C-k> <cmd>call ScrollGolden('up')<CR>
nnoremap <silent> <C-j> <cmd>call ScrollGolden('down')<CR>
vnoremap <silent> <C-j> <cmd>call ScrollGolden('down')<CR>
]])

-- center when scrolling
map('n', '<C-d>', '<C-d>zz')
map('n', '<C-u>', '<C-u>zz')

-- Faster scrolling
map('n', '<C-e>', '3<C-e>')
map('n', '<C-y>', '3<C-y>')

-- More comfortable jumping to marks
map('n', "'", '`')
map('n', '`', "'")

-- like `gi` but stay in normal mode
map('n', 'mi', '`^')

-- Split line with X
map('n', 'X', ':keeppatterns substitute/\\s*\\%#\\s*/\\r/e <bar> normal! ==^<cr>')

-- Keep the cursor in place while joining lines
-- map('n', 'J', 'mzJ`z')

vim.cmd([[
  " line text object(using mini.ai instead)
  "xnoremap il g_o^
  "onoremap <silent> il :normal vil<CR>
  "xnoremap al g_o0
  "onoremap <silent> al :normal val<CR>
  "xnoremap ig GoggV
  "onoremap <silent> ig :normal vig<CR>

  " better start and end of line
  nnoremap gs _
  xnoremap gs _
  onoremap <silent> gs :normal vgs<CR>
  nnoremap gl g_
  xnoremap gl g_
  onoremap <silent> gl :normal vgl<CR>
  nnoremap gh 0
  xnoremap gh 0
  onoremap <silent> gh :normal hv0<CR>
]])

-- limit the search in the visual selection
map('x', '<leader>/', '<Esc>/\\%V', { desc = 'limit the search in the visual selection', silent = false })

-- use . to repeat a regular c-prefixed command as if it were perforced using cgn.
map('n', 'g.', '/\\V<C-r>"<CR>cgn<C-a><Esc>', { silent = false })
-- search for the word under the cursor and perform cgn on it
map('n', 'cg*', '*Ncgn', { silent = false })

-- Press * to search for the term under the cursor or a visual selection and
-- then press a key below to replace all instances of it in the current file.
map('n', '<leader>rr', ':%s///g<Left><Left>', { silent = false })
map('n', '<leader>rc', ':%s///gc<Left><left><Left>', { silent = false })

-- The same as above but instead of acting on the whole file it will be
-- restricted to the previously visually selected range.
map('x', '<leader>rr', ':s///g<Left><Left>', { silent = false })
map('x', '<leader>rc', ':s///gc<Left><left><Left>', { silent = false })

-- <leader>ra over word to find and replace all occurrences.
map('n', '<leader>ra', [[:%s/\<<C-r>=expand("<cword>")<CR>\>//g<Left><Left>]], { silent = false })

-- Replace selected characters, saving the word to which they belong(use dot to replace next occurrence)
map('x', '<leader>rw', [["sy:let @w='\<'.expand('<cword>').'\>' <bar> let @/=@s<CR>cgn]])

-- Replace full word
map('n', '<leader>rw', [[:let @/='\<'.expand('<cword>').'\>'<CR>cgn]])

-- Append to the end of a word
map('n', '<leader>sa', [[:let @/='\<'.expand('<cword>').'\>'<CR>cgn<C-r>"]])

-- Search selection and apply macro
-- from: https://vonheikemen.github.io/devlog/tools/how-to-survive-without-multiple-cursors-in-vim/
map('x', 'qi', [[y<cmd>let @/=substitute(escape(@", '/'), '\n', '\\n', 'g')<cr>gvqi]])

-- Apply macro in the next instance of the search
map('n', '<F9>', 'gn@i')

-- delete all trailing whitespace
map('n', '<F6>', [[:let _s=@/ <Bar> :%s/\s\+$//e <Bar> :let @/=_s <Bar> :nohl <Bar> :unlet _s <CR>]])

-- print current time
map({ 'n', 'i' }, '<F8>', function()
  local t = os.date('*t')
  local time = string.format('%02d:%02d:%02d', t.hour, t.min, t.sec)
  print(time)
end)

-- yank to system clipboard
map({ 'n', 'v' }, '<leader>y', '"+y')
map('n', '<leader>Y', '"+y$')
map({ 'n', 'v' }, '<leader>p', '"+p')
map('n', '<leader>P', '"+P')
-- use the ctrl+shift+v instead
-- map('i', '<M-p>', '<C-r><C-o>+', { desc = "Insert the contents of a register literally and don't auto-indent" })
-- map('c', '<M-p>', '<C-r>+', { silent = false })
if vim.fn.has('gui_running') == 1 then
  map('i', '<C-S-v>', '<C-r><C-o>+', { desc = "Insert the contents of a register literally and don't auto-indent" })
  map('c', '<C-S-v>', '<C-r><C-o>+', { desc = 'Insert the contents of a register literally', silent = false })
end

-- paste from ditto
map('n', '<S-Insert>', '"+p')
map('v', '<S-Insert>', '"+p')
map('i', '<S-Insert>', '<C-r>+')

-- reselect pasted or yanked text
map('n', 'gy', '`[v`]', { desc = 'reselect pasted or yanked text' })

-- Copies last yank/cut to clipboard register
-- map('n', '<leader>cy', ':let @*=@"<CR>', { desc = 'Copy last yank/cut to clipboard' })
map('n', '<leader>dy', ':let @*=@"<CR>', { desc = 'Copy last yank/cut to clipboard' })

-- Copy contents of the unnamed register (") to system clipboard (+)
map('n', '<leader>cy', function()
  local copy = vim.fn.getreg('"')
  if copy ~= '' then
    vim.fn.setreg('+', copy)
    vim.notify('Copied to clipboard:\n' .. copy)
  end
end, { desc = 'Copy last yank/cut to clipboard' })

-- Redirect change/delete operations to the blackhole
-- NOTE: before these mapping map something with <leader>c and <leader>d like
-- above to prevent it from triggering instantly(fix for mini.clue)
map({ 'n', 'x' }, '<leader>c', '"_c')
map('n', '<leader>C', '"_C')
map({ 'n', 'x' }, '<leader>d', '"_d')
map('n', '<leader>D', '"_D')
-- -- x and X won't alter the register
-- map('n', 'x', '"_x')
-- map('n', 'X', '"_X')

-- use black hole register when deleting empty line
local function smart_dd()
  if vim.api.nvim_get_current_line():match('^%s*$') then
    return '"_dd'
  else
    return 'dd'
  end
end

map('n', 'dd', smart_dd, { expr = true })

-- unexpected behavior when pasting above highlighted text
-- map('v', '<leader>p', '"_dP') -- already exists with P

-- change directory to the file being edited and print the directory after changing
map('n', '<leader>cd', ':cd %:p:h<CR>:pwd<CR>', { desc = 'change directory to the file being edited' })

-- Copy absolute file name to clipboard
map('n', '<Leader>cl', function()
  local path = vim.fn.expand('%:p')
  vim.fn.setreg('+', path)
  print('Copied: ' .. path)
end, { desc = 'Copy absolute file name to clipboard' })

-- Saner behavior of n and N(from vim-galore)
map('n', 'n', "'Nn'[v:searchforward].'zv'", { expr = true, desc = 'Next search result' })
map('x', 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Next search result' })
map('o', 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Next search result' })
map('n', 'N', "'nN'[v:searchforward].'zv'", { expr = true, desc = 'Prev search result' })
map('x', 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Prev search result' })
map('o', 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Prev search result' })

-- Quickly edit your macros(from vim-galore)
-- Use it like this <leader>me or "q<leader>me.
map(
  'n',
  '<leader>me',
  ":<c-u><c-r><c-r>='let @'. v:register .' = '. string(getreg(v:register))<cr><c-f><left>",
  { desc = 'Quickly edit macros' }
)

-- %% expands to the path of the directory that contains the current file.
-- works with with :cd, :grep etc.
vim.cmd("cabbr <expr> %% expand('%:h')")

-- type \e  to enter :e /some/path/ on the command line.
map('n', '<Bslash>e', ":e <C-R>=expand('%:h') . '\\'<CR>", { silent = false })

-- Use curl to upload visual selection to ix.io to easily share it: http://ix.io/3QMC
map('v', '<Bslash>c', [[:w !curl -F "f:1=<-" ix.io<CR>]])

-- Append ; at end of line
-- map('n', '<leader>;', [[:execute "normal! mqA;\<lt>esc>`q"<enter>]])

-- change font size in GUI
if vim.g.nvy then
  vim.opt.guifont = 'JetBrainsMono Nerd Font:h12'
  vim.cmd([[
  command! Bigger  :let &guifont = substitute(&guifont, '\d\+$', '\=submatch(0)+1', '')
  command! Smaller :let &guifont = substitute(&guifont, '\d\+$', '\=submatch(0)-1', '')
  ]])
  map('n', '<C-=>', ':Bigger<CR>')
  map('n', '<C-->', ':Smaller<CR>')
  map('n', '<C-0>', ':set guifont=:h12<CR>')
end

if vim.g.neovide then
  local change_scale_factor = function(delta)
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
  end
  map('n', '<C-=>', function()
    change_scale_factor(1.05)
  end)
  map('n', '<C-->', function()
    change_scale_factor(1 / 1.05)
  end)
  map('n', '<C-0>', function()
    vim.g.neovide_scale_factor = 1.0
  end)
end

-- Zoom / Restore window.
-- https://stackoverflow.com/questions/13194428/is-better-way-to-zoom-windows-in-vim-than-zoomwin
vim.cmd([[
function! ToggleZoom(toggle)
  if exists("t:restore_zoom") && (t:restore_zoom.win != winnr() || a:toggle == v:true)
    exec t:restore_zoom.cmd
    unlet t:restore_zoom
  elseif a:toggle
    let t:restore_zoom = { 'win': winnr(), 'cmd': winrestcmd() }
    vert resize | resize
  endi
endfunction

augroup restorezoom
  au WinEnter * silent! :call ToggleZoom(v:false)
augroup END
]])
-- map('n', '<C-t>', ':call ToggleZoom(v:true)<CR>')
-- map('t', '<C-t>', [[<C-\><C-n>:call ToggleZoom(v:true)<CR>i]])

-- open current file in explorer
map('n', '<leader>ue', ':silent !start %:p:h<CR>', { desc = 'Open current file in explorer' })

-- Toggle quickfix window
map('n', '<leader>x', function()
  local qf_exists = false
  for _, win in pairs(vim.fn.getwininfo()) do
    if win['quickfix'] == 1 then
      qf_exists = true
    end
  end

  if qf_exists == true then
    vim.cmd('cclose')
    return
  end
  -- dont open if quickfix is empty
  if not vim.tbl_isempty(vim.fn.getqflist()) then
    vim.cmd('copen')
  end
end, { desc = 'toggle quickfix window' })

-- Terminal Mappings
map('t', '`', '<c-\\><c-n>', { desc = 'Enter Normal Mode' })
map('t', '<C-r>', [['<C-\><C-n>"' . nr2char(getchar()) . 'pi']], { expr = true })
-- map('t', '<M-p>', [[<C-\><C-n>"+pi]])

----------------------------------
--- functions
----------------------------------

-- autoload/functions.vim
map('v', '<leader>cy', ':call functions#CompleteYank()<CR>')
map('x', '@', ':<C-u>call functions#ExecuteMacroOverVisualRange()|stopinsert<CR>')

-- essentials.lua functions
map('n', '<leader>ru', ":lua require('essentials').run_file()<CR>")
map('n', '<leader>sb', ":lua require('essentials').swap_bool()<CR>")
map('n', '<leader>sc', ":lua require('essentials').scratch()<CR>", { desc = 'Command to scratch buffer' })

----------------------------------
--- definition of new commands ---
----------------------------------

vim.cmd([[
command! JsonFormat :%!jq .
command! JsonUnformat :%!jq -c .
command! TabToSpace silent! call functions#T2S()
command! SpaceToTab silent! call functions#S2T()
command! ReplaceFile silent! call functions#ReplaceFile()
command! RenameFile call functions#RenameFile()
command! RemoveFile call functions#RemoveFile()
command! DeleteHiddenBuffers call functions#DeleteHiddenBuffers()
command! -nargs=1 -complete=command -bar -range Redir silent call functions#Redir(<q-args>, <range>, <line1>, <line2>)
]])

vim.api.nvim_create_user_command('Json', function()
  vim.cmd([[ enew | norm! "+p ]])
  vim.cmd([[ setlocal filetype=json noswapfile ]])
  vim.cmd([[ nnoremap <silent> <buffer> q :bw!<CR> ]])
end, { force = true, desc = 'paste JSON in new buffer' })

vim.api.nvim_create_user_command('Mdn', function(cmd_opts)
  local url = 'https://mdn.io/'
  vim.cmd('silent !start "" "' .. url .. unpack(cmd_opts.fargs) .. '"')
end, { nargs = 1, desc = 'search in mdn' })

vim.api.nvim_create_user_command('Bonly', "silent! execute '%bd|e#|bd#'", { desc = 'delete all but current buffer' })

----------------------------------
---------- abbreviations ---------
----------------------------------

vim.cmd([[
iab <expr> t/ strftime('%Y-%m-%d')
iab <expr> td/ strftime('TODO(' . '%Y-%m-%d):')
" Open help and man pages in a tab:
cab he tab help
cab mdn Mdn
cab f find
]])

-----------------------------------
------------- Plugins -------------
-----------------------------------

---------------------------------------------------------------
-- => telescope.nvim
---------------------------------------------------------------
-- map(
--   "n",
--   "<leader>f",
--   "<cmd>lua require'telescope.builtin'.find_files(require('telescope.themes').get_dropdown({ previewer = false }))<cr>"
-- )
map('n', '<leader>fd', function()
  require('telescope.builtin').find_files({ cwd = '~/.config/symlinks', prompt_title = 'Dotfiles' })
end, { desc = 'Telescope Find symlinks' })
map('n', '<leader>ff', function()
  require('telescope.builtin').find_files({ cwd = vim.fn.expand('%:p:h'), prompt_title = 'From Current Buffer' })
end, { desc = 'Telescope Find files from current buffer' })
map('n', '<leader>fw', function()
  require('telescope').extensions.recent_files.pick({ only_cwd = true, initial_mode = 'normal' })
end, { desc = 'Telescope recent files' })
map('n', '<leader>fW', function()
  require('telescope').extensions.recent_files.pick({ only_cwd = false, initial_mode = 'normal' })
end, { desc = 'Telescope recent files' })
-- telescope neoclip
-- map('n', '<leader>fn', function()
--   require('telescope').extensions.neoclip.default(require('telescope.themes').get_dropdown({
--     initial_mode = 'normal',
--     layout_strategy = 'vertical',
--     layout_config = { height = 0.95 },
--   }))
-- end)
-- map('n', '<leader>fm', function()
--   require('telescope').extensions.macroscope.default({ initial_mode = 'normal' })
-- end)
-- improve oldfiles sorting
-- https://github.com/nvim-telescope/telescope.nvim/issues/2539
map('n', '<leader>fo', function()
  require('telescope.builtin').oldfiles({
    tiebreak = function(current_entry, existing_entry, _)
      return current_entry.index < existing_entry.index
    end,
  })
end, { desc = 'Telescope oldfiles' })
map(
  'n',
  '<leader>fm',
  ':Telescope marks mark_type=local previewer=true initial_mode=normal<CR>',
  { desc = 'Telescope marks local' }
)
map('n', '<leader>fj', ':Telescope jumplist previewer=true initial_mode=normal<CR>', { desc = 'Telescope jumplist' })
map('n', '<leader>fs', ':Telescope find_files<CR>', { desc = 'Telescope find_files' })
map('n', '<leader>b', ':Telescope buffers<CR>', { desc = 'Telescope buffers' })
map('n', '<leader>fn', ':Telescope git_files<CR>', { desc = 'Telescope git_files' })
map('n', '<leader>fi', ':Telescope git_status<CR>', { desc = 'Telescope git_status' })
map('n', "<leader>'", ':Telescope resume<CR>', { desc = 'Telescope resume' })
map('n', '<leader>fr', ':Telescope registers<CR>', { desc = 'Telescope registers' })
map('n', '<leader>fq', ':Telescope quickfix<CR>', { desc = 'Telescope quickfix' })
map('n', '<leader>fv', ':Telescope vim_options<CR>', { desc = 'Telescope vim_options' })
map('n', '<leader>fg', ':Telescope live_grep<CR>', { desc = 'Telescope live_grep' })
map('n', '<leader>fh', ':Telescope help_tags<CR>', { desc = 'Telescope help_tags' })
map('n', '<leader>fH', ':Telescope highlights<CR>', { desc = 'Telescope highlights' })
map('n', '<leader>fk', ':Telescope keymaps<CR>', { desc = 'Telescope keymaps' })
map('n', '<leader>fa', ':Telescope autocommands<CR>', { desc = 'Telescope autocommands' })
map('n', '<leader>fc', ':Telescope commands<CR>', { desc = 'Telescope commands' })
map('n', '<leader>fC', ':Telescope colorscheme enable_preview=true<CR>', { desc = 'Telescope colorscheme' })
map('n', '<leader>f;', ':Telescope command_history<CR>', { desc = 'Telescope command_history' })
map('n', '<leader>f/', ':Telescope search_history<CR>', { desc = 'Telescope search_history' })
map('n', '<leader>fb', ':Telescope current_buffer_fuzzy_find<CR>', { desc = 'Telescope current_buffer_fuzzy_find' })
map('n', '<leader>lr', ':Telescope lsp_references<CR>', { desc = 'Telescope lsp_references' })
map('n', '<leader>lt', ':Telescope lsp_type_definitions<CR>', { desc = 'Telescope lsp_type_definitions' })
map('n', '<leader>ld', ':Telescope diagnostics<CR>', { desc = 'Telescope diagnostics' })
map('n', '<leader>ft', ':Telescope treesitter previewer=true<CR>', { desc = 'Telescope treesitter' })
map(
  'n',
  '<leader>lS',
  ':Telescope lsp_document_symbols previewer=true<CR>',
  { desc = 'Telescope lsp_document_symbols all' }
)
map('n', '<leader>lwW', ':Telescope lsp_dynamic_workspace_symbols<CR>', { desc = 'LSP: [W]orkspace [S]ymbols' })
local symbols = {
  'Class',
  'Function',
  'Method',
  'Constructor',
  'Interface',
  'Module',
  'Struct',
  'Trait',
  'Field',
  'Property',
}
map('n', '<leader>ls', function()
  require('telescope.builtin').lsp_document_symbols({
    previewer = true,
    symbols = symbols,
  })
end, { desc = 'Telescope lsp_document_symbols' })
map('n', '<leader>lww', function()
  require('telescope.builtin').lsp_dynamic_workspace_symbols({
    previewer = true,
    symbols = symbols,
  })
end, { desc = 'Telescope lsp_document_symbols' })

---------------------------------------------------------------
-- => document-color.nvim
---------------------------------------------------------------
-- map('n', '<leader>tw', "<cmd>lua require('document-color').buf_toggle()<CR>", { desc = 'toggle tailwind colors' })

---------------------------------------------------------------
-- => ton/vim-bufsurf
---------------------------------------------------------------
-- map("n", "<C-j>", "<Plug>(buf-surf-forward)")
-- map("n", "<C-k>", "<Plug>(buf-surf-back)")

---------------------------------------------------------------
-- => small.nvim
---------------------------------------------------------------
require('small.highlight_selected').setup()

-- stylua: ignore start
-- map('n', '<leader>i', function() require('small.bufend').run() end, { desc = 'Bufend' })

local treeselect = require('small.treeselect')
map('n', '<M-Up>', function() treeselect.current() end, { desc = 'TreeSelect current node' })
map('x', '<M-Right>', function() treeselect.next() end, { desc = 'TreeSelect next node' })
map('x', '<M-Left>', function() treeselect.prev() end, { desc = 'TreeSelect prev node' })
map('x', '<M-Up>', function() treeselect.up() end, { desc = 'TreeSelect parent node' })
map('x', '<M-Down>', function() treeselect.down() end, { desc = 'TreeSelect child node' })
map({'n', 'x'}, '<M-Home>', function() treeselect.base() end, { desc = 'TreeSelect one below root node' })
map({'n', 'x'}, '<M-End>', function() treeselect.line() end, { desc = 'TreeSelect current node linewise' })
-- stylua: ignore end

-- NOTE: using these mappings for small.nvim treeselect
-- Move Lines
-- map('n', '<M-Down>', "<cmd>execute 'move .+' . v:count1<cr>==", { desc = 'Move Down' })
-- map('n', '<M-Up>', "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = 'Move Up' })
-- map('i', '<M-Down>', '<esc><cmd>m .+1<cr>==gi', { desc = 'Move down' })
-- map('i', '<M-Up>', '<esc><cmd>m .-2<cr>==gi', { desc = 'Move up' })

-- NOTE: using these mappings for small.nvim treeselect
-- map('v', '<M-Down>', ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = 'Move Down' })
-- map('v', '<M-Up>', ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = 'Move Up' })

local fn = vim.fn
local api = vim.api
-- move around indents
-- from https://github.com/tj-moody/.dotfiles/blob/c2afec06b68cd0413c20d332672907c11f0a9c47/nvim/lua/mappings.lua#L171C1-L171C1
-- Adapted from https://vi.stackexchange.com/a/12870
-- Traverse to indent >= or > current indent
---@param direction integer 1 - forwards | -1 - backwards
---@param equal boolean include lines equal to current indent in search?
local function indent_traverse(direction, equal) -- {{{
  return function()
    -- Get the current cursor position
    local current_line, column = unpack(api.nvim_win_get_cursor(0))
    local match_line = current_line
    local match_indent = false
    local match = false
    local buf_length = api.nvim_buf_line_count(0)

    -- Look for a line of appropriate indent
    -- level without going out of the buffer
    while (not match) and (match_line ~= buf_length) and (match_line ~= 1) do
      match_line = match_line + direction
      local match_line_str = api.nvim_buf_get_lines(0, match_line - 1, match_line, false)[1]
      -- local match_line_is_whitespace = match_line_str and match_line_str:match('^%s*$')
      local match_line_is_whitespace = match_line_str:match('^%s*$')

      if equal then
        match_indent = fn.indent(match_line) <= fn.indent(current_line)
      else
        match_indent = fn.indent(match_line) < fn.indent(current_line)
      end
      match = match_indent and not match_line_is_whitespace
    end

    -- If a line is found go to line
    if match or match_line == buf_length then
      vim.cmd('normal! m`') -- add current position to jumplist with m`
      fn.cursor({ match_line, column + 1 })
    end
  end
end

map({ 'n', 'x' }, 'gj', indent_traverse(1, true), { desc = 'next equal indent' })
map({ 'n', 'x' }, 'gk', indent_traverse(-1, true), { desc = 'previous equal indent' })
-- map({ 'n', 'x' }, 'gJ', indent_traverse(1, false), { desc = 'next bigger indent' })
-- map({ 'n', 'x' }, 'gK', indent_traverse(-1, false), { desc = 'previous bigger indent' })

-- toggle options
local toggle = require('utils.toggle')
-- stylua: ignore start
map('n', '<leader>us', function() toggle('spell') end, { desc = 'Toggle Spelling' })
map('n', '<leader>uw', function() toggle('wrap') end, { desc = 'Toggle Word Wrap' })
map('n', '<leader>ul', function() toggle('list') end, { desc = 'Toggle List' })
map('n', '<leader>ur', function() toggle('relativenumber') end, { desc = 'Toggle Relative Line Numbers' })
map('n', '<leader>un', function() toggle.number() end, { desc = 'Toggle Line Numbers' })
map('n', '<leader>uD', function() toggle.diagnostics() end, { desc = 'Toggle Diagnostics' })
map('n', '<leader>uT', function() toggle.buffer_semantic_tokens() end, { desc = 'Toggle Semantic Tokens' })
map('n', '<leader>uh', ':let v:hlsearch = 1 - v:hlsearch<CR>', { desc = 'Toggle hlsearch', silent = true })

local conceallevel = vim.o.conceallevel > 0 and vim.o.conceallevel or 2
map('n', '<leader>uc', function() toggle('conceallevel', false, { 0, conceallevel }) end, { desc = 'Toggle Conceal' })

if vim.lsp.buf.inlay_hint or vim.lsp.inlay_hint  then
  map('n', '<leader>uH', function() toggle.inlay_hints()  end, { desc = 'Toggle Inlay Hints' })
end

map('n', '<leader>ut', function()
  if vim.b.ts_highlight then vim.treesitter.stop()
  else vim.treesitter.start() vim.opt.emoji = true end
end, { desc = 'Toggle Treesitter Highlight' })
-- stylua: ignore end

vim.keymap.set('n', '<leader>ud', function()
  local new_config = not vim.diagnostic.config().virtual_lines
  vim.diagnostic.config({ virtual_lines = new_config })
end, { desc = 'Toggle diagnostic virtual_lines' })

map('n', '<leader>la', '<Cmd>Lazy<CR>', { desc = 'Lazy' })
map('n', '<leader>uf', vim.show_pos, { desc = 'Inspect Pos' })
-- print current/alternate file name
map(
  'n',
  '<leader>up',
  [[:echo "current file: " .. expand('%') .. "\nalternate file: " ..expand('#')<CR>]],
  { desc = 'Print current file/alternate name' }
)
