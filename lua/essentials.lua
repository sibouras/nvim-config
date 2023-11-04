---@diagnostic disable: param-type-mismatch
-- source: https://github.com/tamton-aquib/essentials.nvim
local M = {}

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

--> clean folds
function M.simple_fold()
  local fs, fe = vim.v.foldstart, vim.v.foldend
  local start_line = vim.fn.getline(fs):gsub('\t', ('\t'):rep(vim.opt.ts:get()))
  local end_line = vim.trim(vim.fn.getline(fe))
  local spaces = (' '):rep(vim.o.columns - start_line:len() - end_line:len() - 7)

  return start_line .. '  ' .. end_line .. spaces
end
-- set this: vim.opt.foldtext = 'v:lua.require("essentials").simple_fold()'
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
      let path = expand("%:h") .. '/' .. expand('<cfile>')
      " When the :keepjumps command modifier is used, jumps are not stored in the jumplist.
      execute ":keepjumps edit " .. path
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
    vim.cmd('setlocal filetype=Redir buflisted')
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
