---@diagnostic disable: param-type-mismatch,  unused-local
-- source: https://github.com/tamton-aquib/essentials.nvim
local M = {}
local line = vim.fn.line
local map = vim.api.nvim_buf_set_keymap

--> Run code according to filetypes
function M.run_file(height)
  local fts = {
    rust = 'cargo run',
    python = 'python %',
    javascript = 'node %',
    c = 'make',
    cpp = 'make',
  }

  local cmd = fts[vim.bo.ft]
  vim.cmd(cmd and ('w | ' .. (height or '') .. 'sp | term ' .. cmd) or "echo 'No command for this filetype'")
end

--> VSCode like rename function
function M.post(rename_old)
  vim.cmd([[stopinsert!]])
  local new = vim.api.nvim_get_current_line()
  vim.schedule(function()
    vim.api.nvim_win_close(0, true)
    vim.lsp.buf.rename(vim.trim(new))
  end)
  -- vim.notify(rename_old .. " -> " .. new)
end

function M.rename()
  local rename_old = vim.fn.expand('<cword>')
  local noice_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_open_win(noice_buf, true, {
    relative = 'cursor',
    style = 'minimal',
    border = 'single',
    row = 1,
    col = 1,
    width = 15,
    height = 1,
  })
  vim.cmd([[startinsert]])
  map(
    noice_buf,
    'i',
    '<CR>',
    '<cmd>lua require"essentials".post("' .. rename_old .. '")<CR>',
    { noremap = true, silent = true }
  )
end

--> comment function
local comment_map = {
  javascript = '//',
  typescript = '//',
  javascriptreact = '//',
  c = '//',
  java = '//',
  rust = '//',
  cpp = '//',
  python = '#',
  sh = '#',
  conf = '#',
  dosini = '#',
  yaml = '#',
  lua = '--',
  autohotkey = ';',
}

function M.toggle_comment(visual)
  local starting, ending = vim.fn.getpos("'<")[2], vim.fn.getpos("'>")[2]

  local leader = comment_map[vim.bo.ft]
  local current_line = vim.api.nvim_get_current_line()
  local cursor_position = vim.api.nvim_win_get_cursor(0)
  local noice = visual and starting .. ',' .. ending or ''

  vim.cmd(
    current_line:find('^%s*' .. vim.pesc(leader)) and noice .. 'norm ^' .. ('x'):rep(#leader + 1)
      or noice .. 'norm I' .. leader .. ' '
  )

  vim.api.nvim_win_set_cursor(0, cursor_position)
  -- if visual then vim.cmd [[norm gv]] end
end

--> git links
local function git_stuff(args)
  return require('plenary.job'):new({ command = 'git', args = args }):sync()[1]
end

local function git_url()
  return git_stuff({ 'config', '--get', 'remote.origin.url' })
end
local function git_branch()
  return git_stuff({ 'branch', '--show-current' })
end
local function git_root()
  return git_stuff({ 'rev-parse', '--show-toplevel' })
end

local function parse_url()
  local url = git_url()
  if not url then
    error('No git remote found!')
    return
  end

  return url:match('https://github.com/(.+)$') or url:match('git@github.com:(.+).git$')
end

function M.get_git_url()
  local final = parse_url()
  local git_file = vim.fn.expand('%:p'):match(git_root() .. '(.+)')
  local starting, ending = vim.fn.getpos("'<")[2], vim.fn.getpos("'>")[2]

  local noice = ('https://github.com/%s/blob/%s%s#L%s-L%s'):format(final, git_branch(), git_file, starting, ending)

  vim.fn.setreg('+', noice)
  print('link copied to clipboard!')
  -- os.execute('xdg-open '..noice)
end

--> clean folds
function M.simple_fold()
  local fs, fe = vim.v.foldstart, vim.v.foldend
  local start_line = vim.fn.getline(fs):gsub('\t', ('\t'):rep(vim.o.tabstop))
  local end_line = vim.trim(vim.fn.getline(fe))
  local spaces = (' '):rep(vim.o.columns - start_line:len() - end_line:len() - 7)

  return start_line .. '  ' .. end_line .. spaces
end
-- set this: vim.opt.foltext = 'v:lua.require("essentials").simple_fold()'
---------------------------------

--> Swap booleans
function M.swap_bool()
  local c = vim.api.nvim_get_current_line()
  local subs = c:match('true') and c:gsub('true', 'false') or c:gsub('false', 'true')
  vim.api.nvim_set_current_line(subs)
end

--> Go to last edited place
function M.last_place()
  local _, row, col, _ = unpack(vim.fn.getpos([['"]]))
  local last = vim.api.nvim_buf_line_count(0)
  if (row > 0 or col > 0) and (row <= last) then
    vim.cmd([[norm! '"]])
  end
end

--> Go To URL
function M.go_to_url(cmd)
  local url = vim.api.nvim_get_current_line():match([[%[.*]%((.%S+)%)]]) -- markdown links
  if url == nil then
    return
  end
  if not url:match('http') then
    -- can only have one jump per line
    vim.cmd([[
      " add current position to jumplist with m'
      normal! m'f(
      " When the :keepjumps command modifier is used, jumps are not stored in the jumplist.
      keepjumps normal! gf
    ]])
  else
    os.execute(cmd .. ' ' .. url)
  end
end

--> redirect output of command to scratch buffer
function M.scratch()
  vim.ui.input({ prompt = 'enter command: ', completion = 'command' }, function(input)
    if input == nil then
      return
    elseif input == 'scratch' then
      input = "echo('')"
    end
    ---@diagnostic disable-next-line: deprecated
    local cmd = vim.api.nvim_exec(input, { output = true })
    local output = {}
    ---@diagnostic disable-next-line: redefined-local
    for line in cmd:gmatch('[^\n\r]+') do
      table.insert(output, line)
    end
    local buf = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)
    vim.api.nvim_win_set_buf(0, buf)
  end)
end

--> netrw gx replacement to  open in browser
function M.open_in_browser()
  -- support comma or semicolon at the end of line(matches `)` at the end)
  -- local url = string.match(vim.fn.expand("<cWORD>"), "https?://[%w-_%.%?%.:/%+=&]+[^ >\"',;`]*")
  -- new pattern
  -- INFO mastodon URLs contain `@`, neovim docs urls can contain a `'`
  ---@diagnostic disable-next-line: param-type-mismatch
  local url = string.match(vim.fn.expand('<cWORD>'), 'https?://[A-Za-z0-9_%-/.#%%=?&@]+')
  if url ~= nil then
    if vim.fn.has('win32') == 1 then
      os.execute(('start %s'):format(url))
    else
      vim.cmd(('silent !xdg-open "%s"'):format(url))
    end
  else
    print('No https or http URI found in line.')
  end
end

return M
