local function map(mode, lhs, rhs, opts)
  local options = { silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

map('n', '<leader>la', '<Cmd>Lazy<CR>')

-- Horizontal scroll
map({ 'n', 'i', 'v' }, '<S-ScrollWheelUp>', '<ScrollWheelLeft>')
map({ 'n', 'i', 'v' }, '<S-ScrollWheelDown>', '<ScrollWheelRight>')

-- distinguish between <Tab> and <C-i> (ctrl+i is mapped to <M-C-S-F6> in ahk,terminal)
map('n', '<M-C-S-F6>', '<C-i>')

-- de-tab
map('i', '<S-Tab>', '<C-d>')

-- change mapping for diagraphs
map('i', '<C-f>', '<C-k>')

-- Quit vim
map('n', '<M-F4>', ':qa!<CR>')

-- new line
map('i', '<C-CR>', '<C-o>o')

-- search for word under cursor without moving
map('n', 'gw', '*N')
map('x', 'gw', [[y/\V<C-R>"<CR>N]])

-- Move Lines
map('n', '<M-Down>', '<cmd>m .+1<cr>==', { desc = 'Move down' })
map('n', '<M-Up>', '<cmd>m .-2<cr>==', { desc = 'Move up' })
map('i', '<M-Down>', '<esc><cmd>m .+1<cr>==gi', { desc = 'Move down' })
map('i', '<M-Up>', '<esc><cmd>m .-2<cr>==gi', { desc = 'Move up' })
map('v', '<M-Down>', ":m '>+1<cr>gv=gv", { desc = 'Move down' })
map('v', '<M-Up>', ":m '<-2<cr>gv=gv", { desc = 'Move up' })

-- Resize window using <ctrl> arrow keys
map('n', '<C-Up>', '<cmd>resize +2<cr>', { desc = 'Increase window height' })
map('n', '<C-Down>', '<cmd>resize -2<cr>', { desc = 'Decrease window height' })
map('n', '<C-Left>', '<cmd>vertical resize -2<cr>', { desc = 'Decrease window width' })
map('n', '<C-Right>', '<cmd>vertical resize +2<cr>', { desc = 'Increase window width' })

--> Navigate buffers
-- NOTE: b# doesn't work with jumpoption=view
-- from: https://sharats.me/posts/automating-the-vim-workplace/#switching-to-alternate-buffer
-- My remapping of <C-^>. If there is no alternate file, and there's no count
-- given, then switch to next file. We use `bufloaded` to check for alternate
-- buffer presence. This will ignore deleted buffers, as intended. To get
-- default behaviour, use `bufexists` in it's place.
-- map("n", "<M-w>", ":<C-u>exe v:count ? v:count . 'b' : 'keepjumps b' . (bufloaded(0) ? '#' : 'n')<CR>")
-- map("i", "<M-w>", "<C-o>:keepjumps b#<CR>")
-- this switches to the last used buffer even if its deleted
-- map({ "n", "i" }, "<M-w>", "<Cmd>keepjumps normal <CR>")

-- switch to the most recent buffer that's not deleted
map({ 'n', 'i' }, '<M-w>', function()
  local curbufnr = vim.api.nvim_get_current_buf()
  local buflist = vim.tbl_filter(function(buf)
    return vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted and buf ~= curbufnr
  end, vim.api.nvim_list_bufs())

  -- table is empty if buffers are not loaded
  if #buflist == 0 then
    vim.cmd('keepjumps b#')
  else
    local switch_bufnr
    local switch_bufnr_lastused = -1
    for _, bufnr in pairs(buflist) do
      local bufinfo = vim.fn.getbufinfo(bufnr)[1]
      if bufinfo.lastused > switch_bufnr_lastused then
        switch_bufnr = bufnr
        switch_bufnr_lastused = bufinfo.lastused
      end
    end
    vim.cmd('keepjumps b' .. switch_bufnr)
  end
end)

-- Navigate tabs
-- Number + , to select a tab, i.e. type 1, to select the first tab.
for i = 1, 9 do
  map('n', i .. ',', i .. 'gt')
end

-- Switch to last active tab
vim.cmd([[
  if !exists('g:Lasttab')
    let g:Lasttab = 1
    let g:Lasttab_backup = 1
  endif
  autocmd! TabLeave * let g:Lasttab_backup = g:Lasttab | let g:Lasttab = tabpagenr()
  autocmd! TabClosed * let g:Lasttab = g:Lasttab_backup
  nmap <silent> <C-h> :exe "tabn " . g:Lasttab<cr>
]])

-- Move text up and down(using nvim-gomove instead)
-- map("n", "<A-j>", "<Esc>:m .+1<CR>==gi")
-- map("n", "<A-k>", "<Esc>:m .-2<CR>==gi")

-- df to escape
-- map("i", "df", "<ESC>")

-- quick save
map('n', '<M-s>', ':silent update<CR>')
map('i', '<M-s>', '<Esc>:silent update<CR>')

-- Ctrl-Backspace to delete the previous word
map('i', '<C-BS>', '<C-w>', { noremap = false })
map('c', '<C-BS>', '<C-w>', { silent = false })

-- ctrl-z to undo
map('i', '<C-z>', '<C-o>:u<CR>')

-- undo break points
local undo_ch = { ',', '.', '!', '?', ';' }
for _, ch in ipairs(undo_ch) do
  map('i', ch, ch .. '<C-g>u')
end

-- Store relative line number jumps in the jumplist if they exceed a threshold.
map('n', 'k', '(v:count > 5 ? "m\'" . v:count : "") . "k"', { expr = true })
map('n', 'j', '(v:count > 5 ? "m\'" . v:count : "") . "j"', { expr = true })

-- When the :keepjumps command modifier is used, jumps are not stored in the jumplist.
map('n', '{', ":execute 'keepjumps norm! ' . v:count1 . '{'<CR>")
map('n', '}', ":execute 'keepjumps norm! ' . v:count1 . '}'<CR>")
map('n', '(', ":execute 'keepjumps norm! ' . v:count1 . '('<CR>")
map('n', ')', ":execute 'keepjumps norm! ' . v:count1 . ')'<CR>")

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
  execute 'keepjumps normal! ' . prep . float2nr(round(height*0.12)) . key . post
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
map('n', '<C-e>', '2<C-e>')
map('n', '<C-y>', '2<C-y>')

-- More comfortable jumping to marks
map('n', "'", '`')
map('n', '`', "'")

-- like `gi` but stay in normal mode
map('n', 'mi', '`^')

-- Split line with X
map('n', 'X', ':keeppatterns substitute/\\s*\\%#\\s*/\\r/e <bar> normal! ==^<cr>')

-- Keep the cursor in place while joining lines
map('n', 'J', 'mzJ`z')

vim.cmd([[
  " line text object
  xnoremap il g_o^
  onoremap il :normal vil<CR>
  xnoremap al $o^
  onoremap al :normal val<CR>
  xnoremap ig GoggV
  onoremap ig :normal vig<CR>

  " better start and end of line
  nnoremap gh _
  xnoremap gh _
  onoremap gh :normal vgh<CR>
  nnoremap gl g_
  xnoremap gl g_
  onoremap gl :normal vgl<CR>
]])

-- limit the search in the visual selection
map('x', '<leader>/', '<Esc>/\\%V', { desc = 'limit the search in the visual selection' })

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

-- from: https://old.reddit.com/r/neovim/comments/w59a4m/do_you_really_need_multiple_cursors_for_the/ih747rt/
-- Begin a "searchable" macro
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

-- Navigate quickfix list
map('n', '[q', ':cprevious<CR>')
map('n', ']q', ':cnext<CR>')

-- yank to system clipboard
map({ 'n', 'v' }, '<M-y>', '"+y')
map('n', '<M-Y>', '"+y$')
map({ 'n', 'v' }, '<M-p>', '"+p')
map('i', '<M-p>', '<C-r><C-o>+', { desc = 'Inserts text literally, not as if you typed it' })
map('c', '<M-p>', '<C-r>+', { silent = false })
map({ 'n', 'v' }, '<M-S-p>', '"+P')

-- Copies last yank/cut to clipboard register
map('n', '<leader>cp', ':let @*=@"<CR>')

-- Redirect change/delete operations to the blackhole
map('n', '<leader>c', '"_c')
map('n', '<leader>C', '"_C')
map('n', '<leader>d', '"_d')
map('n', '<leader>D', '"_D')
-- -- x and X won't alter the register
-- map("n", "x", '"_x')
-- map("n", "X", '"_X')

-- unexpected behavior when pasting above highlighted text
map('v', '<leader>p', '"_dP')

-- change directory to the file being edited and print the directory after changing
map('n', '<leader>cd', ':cd %:p:h<CR>:pwd<CR>')

-- print current file name
map('n', '<leader>cs', [[:echo expand('%') .. "\n"<CR>]])
-- print alternate file name
map('n', '<leader>co', [[:echo expand('#') .. "\n"<CR>]])
-- Copy absolute file name to clipboard
map('n', '<leader>cl', [[:let @*=expand('%:p')<CR>:echo expand('%:p') .. "\ncopied to clipboard\n"<CR>]])
-- nnoremap <silent> <leader>yf :call setreg(v:register, expand('%:p'))<CR>

-- paste from ditto
map('n', '<S-Insert>', '"+p')
map('v', '<S-Insert>', '"+p')
map('i', '<S-Insert>', '<C-r>+')

-- reselect pasted text
-- map("n", "sp", "`[v`]")

-- Quickly edit your macros(from vim-galore)
map('n', '<leader>me', ":<c-u><c-r><c-r>='let @'. v:register .' = '. string(getreg(v:register))<cr><c-f><left>")

-- Stay in indent mode
map('v', '<', '<gv')
map('v', '>', '>gv')

-- remove highlight
map('n', '<Esc>', '<Cmd>noh<CR>', { desc = 'Escape and clear hlsearch' })

-- %% expands to the path of the directory that contains the current file.
-- works with with :cd, :grep etc.
vim.cmd("cabbr <expr> %% expand('%:h')")

-- type \e  to enter :e /some/path/ on the command line.
map('n', '<Bslash>e', ":e <C-R>=expand('%:h') . '\\'<CR>", { silent = false })

-- Use curl to upload visual selection to ix.io to easily share it: http://ix.io/3QMC
map('v', '<Bslash>c', [[:w !curl -F "f:1=<-" ix.io<CR>]])

-- Append ; at end of line
map('n', '<leader>;', [[:execute "normal! mqA;\<lt>esc>`q"<enter>]])

-- open window in new tab
map('n', '<leader>tn', '<C-w>T')

-- edit keymaps in new tab
-- map("n", "<leader>tk", ":tab drop $LOCALAPPDATA/nvim/lua/user/keymaps.lua<CR>:Tz nvim<CR>")
map('n', '<leader>tk', ':tab drop $LOCALAPPDATA/nvim/lua/user/keymaps.lua<CR>')

-- Quickly change font size in GUI
vim.cmd([[
command! Bigger  :let &guifont = substitute(&guifont, '\d\+$', '\=submatch(0)+1', '')
command! Smaller :let &guifont = substitute(&guifont, '\d\+$', '\=submatch(0)-1', '')
]])
map('n', '<M-=>', ':Bigger<CR>')
map('n', '<M-->', ':Smaller<CR>')
map('n', '<M-S-_>', ':set guifont=:h16<CR>')

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
map('n', '<C-q>', ':call ToggleZoom(v:true)<CR>')
map('t', '<C-q>', [[<C-\><C-n>:call ToggleZoom(v:true)<CR>i]])

-- search for regex pattern
-- map("n", "<M-l>", "<Cmd>call search('[([{<]')<CR>")

-- open current file in explorer
map('n', '<leader>fl', ':silent !start %:p:h<CR>')

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

-- toggle cmp(mapped <C-;> to <M-C-S-F7> in ahk,terminal)
map({ 'i', 'n' }, '<M-C-S-F7>', function()
  vim.g.cmp_active = not vim.g.cmp_active
end, { desc = 'toggle cmp' })

----------------------------------
--- functions
----------------------------------

-- use black hole register when deleting empty line
local function smart_dd()
  if vim.api.nvim_get_current_line():match('^%s*$') then
    return '"_dd'
  else
    return 'dd'
  end
end

map('n', 'dd', smart_dd, { expr = true })

-- Quickly add empty lines
map('n', '[<space>', "<Cmd>call append(line('.') - 1, repeat([''], v:count1))<CR>", { desc = 'Put empty line above' })
map('n', ']<space>', "<Cmd>call append(line('.'),     repeat([''], v:count1))<CR>", { desc = 'Put empty line below' })

-- autoload/functions.vim
map('v', '<leader>cy', ':call functions#CompleteYank()<CR>')
map('x', '@', ':<C-u>call functions#ExecuteMacroOverVisualRange()<CR>')
map('n', '<leader>hl', ':call functions#GetHighlightGroupUnderCursor()<CR>')
-- map("n", "gx", ":call functions#open_url_under_cursor()<CR>")

-- essentials.lua functions
-- map("n", "<F2>", ":lua require('essentials').rename()<CR>")
map('n', 'g<CR>', ":lua require('essentials').open_in_browser()<CR>")
map('n', 'g/', ":lua require('essentials').toggle_comment()<CR>")
map('v', 'g/', ":lua require('essentials').toggle_comment(true)<CR>")
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

vim.api.nvim_create_user_command('Bonly', function()
  vim.cmd("silent! execute '%bd|e#|bd#'")
end, { desc = 'delete all but current buffer' })

----------------------------------
---------- abbreviations ---------
----------------------------------

vim.cmd([[
iab <expr> t/ strftime('%Y-%m-%d')
iab <expr> td/ strftime('TODO(' . '%Y-%m-%d):')
" Open help and man pages in a tab:
cab he tab help
cab mdn Mdn
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
end, { desc = 'Find symlinks' })
map('n', '<leader>ff', function()
  require('telescope.builtin').find_files({ cwd = vim.fn.expand('%:p:h'), prompt_title = 'From Current Buffer' })
end, { desc = 'Find files from current buffer' })
map('n', '<leader>fw', function()
  require('telescope').extensions.recent_files.pick({ initial_mode = 'normal' })
end, { desc = 'Telescope recent files extesion' })
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
map('n', '<leader>o', ':Telescope find_files<CR>')
map('n', '<leader>b', ':Telescope buffers<CR>')
map('n', '<leader>fs', ':Telescope git_files<CR>')
map('n', '<leader>fi', ':Telescope git_status<CR>')
map('n', '<leader>fe', ':Telescope resume<CR>')
map('n', '<leader>fr', ':Telescope registers<CR>')
map('n', '<leader>fm', ':Telescope marks<CR>')
-- improve oldfiles sorting
-- https://github.com/nvim-telescope/telescope.nvim/issues/2539
map('n', '<leader>fo', function()
  require('telescope.builtin').oldfiles({
    tiebreak = function(current_entry, existing_entry, _)
      return current_entry.index < existing_entry.index
    end,
  })
end, { desc = 'Telescope oldfiles' })
map('n', '<leader>fv', ':Telescope vim_options<CR>')
map('n', '<leader>fg', ':Telescope live_grep<CR>')
map('n', '<leader>fh', ':Telescope highlights<CR>')
map('n', '<leader>fk', ':Telescope keymaps<CR>')
map('n', '<leader>fa', ':Telescope autocommands<CR>')
map('n', '<leader>fc', ':Telescope commands<CR>')
map('n', '<leader>f;', ':Telescope command_history<CR>')
map('n', '<leader>f/', ':Telescope search_history<CR>')
map('n', '<leader>fb', ':Telescope current_buffer_fuzzy_find<CR>')
map('n', '<leader>fp', ':Telescope workspaces<CR>')
map('n', '<leader>lr', ':Telescope lsp_references<CR>')
map('n', '<leader>ld', ':Telescope diagnostics<CR>')
map('n', '<leader>ls', ':Telescope lsp_document_symbols<CR>')
map('n', '<leader>lt', ':Telescope treesitter<CR>')

---------------------------------------------------------------
-- => document-color.nvim
---------------------------------------------------------------
-- map('n', '<leader>tw', "<cmd>lua require('document-color').buf_toggle()<CR>", { desc = 'toggle tailwind colors' })

---------------------------------------------------------------
-- => ton/vim-bufsurf
---------------------------------------------------------------
-- map("n", "<C-j>", "<Plug>(buf-surf-forward)")
-- map("n", "<C-k>", "<Plug>(buf-surf-back)")

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

map({ 'n', 'x' }, 'gj', indent_traverse(1, true)) -- next equal indent
map({ 'n', 'x' }, 'gk', indent_traverse(-1, true)) -- previous equal indent
map({ 'n', 'x' }, 'gJ', indent_traverse(1, false)) -- next bigger indent
map({ 'n', 'x' }, 'gK', indent_traverse(-1, false)) -- previous bigger indent

-- For moving quickly up and down,
-- Goes to the first line above/below that isn't whitespace
-- Thanks to: http://vi.stackexchange.com/a/213
vim.cmd([[
  nnoremap <silent> <leader>j :let _=&lazyredraw<CR>:set lazyredraw<CR>/\%<C-R>=virtcol(".")<CR>v\S<CR>:nohl<CR>:let &lazyredraw=_<CR>
  nnoremap <silent> <leader>k :let _=&lazyredraw<CR>:set lazyredraw<CR>?\%<C-R>=virtcol(".")<CR>v\S<CR>:nohl<CR>:let &lazyredraw=_<CR>
]])
