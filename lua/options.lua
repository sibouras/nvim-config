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
  linebreak = true,
  scrolloff = 4,
  sidescrolloff = 10,
  keywordprg = ':help', -- default is :Man(crashes on windows)
  grepprg = 'rg --vimgrep --smart-case', -- Replacing grep with rg
  grepformat = '%f:%l:%c:%m',
  -- listchars = { eol = "↴", extends = "›", precedes = "‹", nbsp = "␣", trail = "·", tab = "> " },
  -- listchars = "tab:¦ ,eol:¬,trail:⋅,extends:❯,precedes:❮",
  listchars = 'tab:▸ ,nbsp:+,trail:·,extends:→,precedes:←,eol:↲',
  sessionoptions = 'buffers,curdir,folds,help,tabpages,terminal,winsize',
  -- guifont = "JetbrainsMono Nerd Font:h16", -- the font used in graphical neovim applications
  guifont = 'JetBrainsMono NF:h13', -- the font used in graphical neovim applications
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
vim.opt.jumpoptions:append('stack') -- stack:browser-like jumplist behavior
vim.opt.diffopt:append('linematch:60')
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
  -- fold = "⸱",
  fold = ' ',
  foldsep = ' ',
  diff = '╱',
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
vim.opt.foldtext = "v:lua.require'small.foldtext'.setup()"

vim.opt.statuscolumn = [[%!v:lua.require'utils.ui'.statuscolumn()]]

if vim.g.nvy then
  vim.cmd('cd $home')
end

if vim.g.neovide then
  -- vim.g.neovide_cursor_animation_length = 0
  vim.g.neovide_position_animation_length = 0
  vim.g.neovide_scroll_animation_far_lines = 0
end

vim.g.python3_host_prog = 'python3'
