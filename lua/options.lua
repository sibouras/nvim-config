local options = {
  -- clipboard = "unnamedplus", -- allows neovim to access the system clipboard
  cmdheight = 1, -- more space in the neovim command line for displaying messages
  laststatus = 3, -- have a global statusline at the bottom instead of one for each window
  completeopt = { 'menuone', 'noselect' }, -- mostly just for cmp
  conceallevel = 2, -- Concealed text is completely hidden unless it has a custom replacement character defined
  fileencoding = 'utf-8', -- the encoding written to a file
  fileformat = 'unix',
  fileformats = 'unix,dos',
  -- shellslash = true, -- breaks neo-tree and lir and maybe more
  hlsearch = true, -- highlight all matches on previous search pattern
  ignorecase = true, -- ignore case in search patterns
  mouse = 'a', -- allow the mouse to be used in neovim
  pumheight = 10, -- pop up menu height
  showmode = false, -- we don't need to see things like -- INSERT -- anymore
  showtabline = 1, -- always show tabs
  smartcase = true, -- smart case
  smartindent = true, -- make indenting smarter again
  splitbelow = true, -- force all horizontal splits to go below current window
  splitright = true, -- force all vertical splits to go to the right of current window
  splitkeep = 'screen', -- Keep the text on the same screen line.
  termguicolors = true, -- set term gui colors (most terminals support this)
  timeoutlen = 300, -- time to wait for a mapped sequence to complete (in milliseconds)
  updatetime = 300, -- faster completion (4000ms default)
  backup = false, -- creates a backup file
  writebackup = false, -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
  undofile = true, -- enable persistent undo
  swapfile = false, -- creates a swapfile
  expandtab = true, -- convert tabs to spaces
  shiftwidth = 2, -- the number of spaces inserted for each indentation
  tabstop = 2, -- insert 2 spaces for a tab
  cursorline = true, -- highlight the current line
  number = true, -- set numbered lines
  relativenumber = true, -- set relative numbered lines
  numberwidth = 4, -- Minimal number of columns to use for the line number.
  signcolumn = 'yes', -- always show the sign column, otherwise it would shift the text each time
  wrap = false, -- display lines as one long line
  breakindent = true, -- Indent wrapped lines to match line start
  linebreak = true, -- Wrap long lines at 'breakat' (if 'wrap' is set)
  scrolloff = 5,
  sidescrolloff = 10,
  keywordprg = ':help', -- default is :Man(crashes on windows)
  grepprg = 'rg --vimgrep --smart-case', -- Replacing grep with rg
  grepformat = '%f:%l:%c:%m',
  -- listchars = { eol = "↴", extends = "›", precedes = "‹", nbsp = "␣", trail = "·", tab = "> " },
  -- listchars = "tab:¦ ,eol:¬,trail:⋅,extends:❯,precedes:❮",
  listchars = 'tab:▸ ,nbsp:+,trail:·,extends:→,precedes:←,eol:↲',
  sessionoptions = 'buffers,curdir,folds,help,tabpages,terminal,winsize',
  -- guifont = 'JetBrainsMono Nerd Font:h12.5', -- the font used in graphical neovim applications
  -- guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:Cursor/lCursor", -- this makes changing Cursor highlight work
  shada = "!,'30,<50,s10,h", -- 30 oldfiles
}

for k, v in pairs(options) do
  vim.opt[k] = v
end

-- vim.opt.iskeyword:append("-")
vim.opt.whichwrap:append('<,>,[,],h,l') -- let movement keys reach the previous line
vim.opt.shortmess:append('c') -- don't show the dumb matching stuff
vim.opt.cpoptions:append('>') -- When appending to a register, put a line break before the appended text.
-- vim.opt.concealcursor:append("nc")
-- view: When you jump around, or switch buffers with ctrl-^ the viewport is
-- restored instead of resetting/recentering vertically.
-- vim.opt.jumpoptions:append('stack') -- stack:browser-like jumplist behavior
vim.opt.jumpoptions = 'stack,view'
-- NOTE: available by default in 0.11
if vim.fn.has('nvim-0.11') == 0 then
  vim.opt.diffopt:append('linematch:60')
end
vim.opt.path = ',,.' -- the default '.,,' doesn't work
-- the lazy way(slow): https://gist.github.com/romainl/7e2b425a1706cd85f04a0bd8b3898805#the-lazy-way
-- vim.opt.path:append('**') -- find files recursively
-- vim.opt.wildignore = {
--   '**/node_modules/**',
--   '**/.git/**',
-- }

local setPath = function()
  -- use default path if not in git directory
  local path = vim.uv.cwd() .. '/.git'
  local ok, err = vim.uv.fs_stat(path)
  if not ok then
    return ',,.'
  end

  local items = {}
  for path, path_type in
    vim.fs.dir(vim.uv.cwd(), {
      -- skip = function(dir_name)
      --   return dir_name ~= 'node_modules' and dir_name ~= '.git' and dir_name ~= '.docusaurus'
      -- end,
      -- depth = math.huge,
      depth = 1,
    })
  do
    if
      path_type == 'directory'
      and not path:match('%.git')
      and not path:match('node_modules')
      and not path:match('%.docusaurus')
    then
      table.insert(items, path .. '/')
      table.insert(items, path .. '/**')
    end
  end
  return ',,' .. table.concat(items, ',')
end

-- defer setPath to not slow down startup time
vim.defer_fn(function()
  vim.opt.path = setPath()
end, 500)

vim.api.nvim_create_autocmd('DirChanged', {
  desc = 'set path',
  group = vim.api.nvim_create_augroup('MyGroup_path', { clear = true }),
  callback = function()
    vim.defer_fn(function()
      vim.opt.path = setPath()
    end, 500)
  end,
})

-- skip common junk in 'shada' oldfiles
vim.opt.shada:append('r/tmp/,rfugitive:,rdiffview:,rterm:,rhealth:')

vim.opt.fillchars = {
  foldopen = '',
  foldclose = '',
  fold = '⸱',
  -- fold = ' ',
  foldsep = ' ',
  diff = ' ',
  eob = ' ',
}

-- prettier folding
function _G.MyFoldText()
  return vim.fn.getline(vim.v.foldstart) .. ' ... ' .. vim.fn.getline(vim.v.foldend):gsub('^%s*', '')
end

vim.opt.foldlevelstart = 99
-- folding with treesitter(slow for large files)
-- vim.opt.foldmethod = 'expr'
-- vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
-- vim.opt.foldexpr = "v:lua.require'utils.ui'.foldexpr()"

-- vim.opt.foldtext = 'v:lua.vim.treesitter.foldtext()'
-- vim.opt.foldtext = 'v:lua.MyFoldText()'
-- vim.opt.foldtext = "v:lua.require'small.foldtext'.setup()"
vim.o.foldtext = '' -- transparent foldtext

vim.opt.statuscolumn = [[%!v:lua.require'utils.ui'.statuscolumn()]]

if vim.fn.has('gui_running') == 1 then
  vim.cmd('cd $home')
end

if vim.g.neovide then
  vim.g.neovide_position_animation_length = 0
  vim.g.neovide_scroll_animation_far_lines = 0
  vim.g.neovide_scroll_animation_length = 0.2 -- default = 0.3
  vim.g.neovide_cursor_animation_length = 0.1 -- default = 0.15

  -- don't smooth scroll when switching buffers, https://github.com/neovide/neovide/issues/1771
  vim.api.nvim_create_autocmd('BufLeave', {
    group = vim.api.nvim_create_augroup('MyGroup_neovide_leave', { clear = true }),
    callback = function()
      vim.g.neovide_scroll_animation_length = 0
    end,
  })
  vim.api.nvim_create_autocmd('BufEnter', {
    group = vim.api.nvim_create_augroup('MyGroup_neovide_enter', { clear = true }),
    callback = function()
      vim.fn.timer_start(70, function()
        -- don't smooth scroll in telescope preview
        if vim.bo.filetype ~= 'TelescopePrompt' then
          vim.g.neovide_scroll_animation_length = 0.2
        end
      end)
    end,
  })
end

vim.g.python3_host_prog = 'python3'

-- popup-menu
vim.cmd([[
nmenu 10.100 PopUp.Goto\ Definition <Cmd>Telescope lsp_definitions<CR>
nmenu 10.110 PopUp.References <Cmd>TroubleToggle lsp_references<CR>
nmenu 10.120 PopUp.-Sep-	:
aunmenu PopUp.How-to\ disable\ mouse
aunmenu PopUp.-1-
]])

if vim.g.is_win then
  --> nushell as shell
  vim.opt.shell = 'nu'
  -- `--stdin`: redirect all input to -c
  -- `--no-newline`: do not append `\n` to stdout
  -- `-c`: execute a command
  vim.opt.shellcmdflag = '--stdin --no-newline --no-config-file -c'
  -- disable all escaping and quoting
  vim.opt.shellxescape = ''
  vim.opt.shellxquote = ''
  vim.opt.shellquote = ''

  -- WARN: disable the usage of temp files for shell commands
  -- because Nu doesn't support `input redirection` which Neovim uses to send buffer content to a command:
  --      `{shell_command} < {temp_file_with_selected_buffer_content}`
  -- When set to `false` the stdin pipe will be used instead.
  -- NOTE: some info about `shelltemp`: https://github.com/neovim/neovim/issues/1008
  vim.opt.shelltemp = false

  -- string to be used to put the output of shell commands in a temp file
  -- 1. when 'shelltemp' is `true`
  -- 2. in the `diff-mode` (`nvim -d file1 file2`) when `diffopt` is set
  --    to use an external diff command: `set diffopt-=internal`
  vim.opt.shellredir = 'out+err> %s'

  -- string to be used with `:make` command to:
  -- 1. save the stderr of `makeprg` in the temp file which Neovim reads using `errorformat` to populate the `quickfix` buffer
  -- 2. show the stdout, stderr and the return_code on the screen
  -- NOTE: `ansi strip` removes all ansi coloring from nushell errors
  vim.opt.shellpipe =
    '| complete | update stderr { ansi strip } | tee { get stderr | save --force --raw %s } | into record'

  -- custom `:Term` command that executes `:term` without `--stdin` flag
  vim.api.nvim_create_user_command('Term', function(ctx)
    local flag = vim.opt.shellcmdflag:get()
    vim.opt.shellcmdflag = '--no-config-file -c'
    vim.cmd('term ' .. ctx.args)
    vim.opt.shellcmdflag = flag
  end, { nargs = '?' })

  vim.cmd('cabbrev term Term')
end

-- remove `cr` when pasting in wsl. https://stackoverflow.com/a/76388417
if vim.fn.has('wsl') == 1 then
  if vim.env.WAYLAND_DISPLAY and vim.fn.executable('wl-copy') and vim.fn.executable('wl-paste') then
    vim.g.clipboard = {
      name = 'wl-clipboard (wsl)',
      copy = {
        ['+'] = 'wl-copy --type text/plain',
        ['*'] = 'wl-copy --primary --type text/plain',
      },
      paste = {
        ['+'] = function()
          return vim.fn.systemlist("wl-paste --no-newline | sed -e 's/\r$//'", { '' }, 1) -- '1' keeps empty lines
        end,
        ['*'] = function()
          return vim.fn.systemlist("wl-paste --primary --no-newline | sed -e 's/\r$//'", { '' }, 1)
        end,
      },
      cache_enabled = true,
    }
  end
end
