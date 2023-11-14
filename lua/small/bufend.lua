local M = {}
M.locked_files = {}
function M.get_list(key)
  return vim
    .iter(vim.api.nvim_list_bufs())
    :filter(vim.api.nvim_buf_is_loaded)
    :map(function(v)
      local filepath = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(v), ':p')
      if vim.fn.filereadable(filepath) ~= 1 then
        return
      end
      if key and key ~= vim.fn.fnamemodify(filepath, ':t'):sub(1, 1) then
        return
      end
      return filepath
    end)
    :rev()
    :totable()
end
function M.unlock_file(key)
  M.locked_files[key] = nil
end
function M.lock_file(key)
  require('small.lib.select')(M.get_list(), {
    -- custom
    format_item = function(file)
      return vim.fn.fnamemodify(file, ':.')
    end,
  }, function(i)
    M.locked_files[key] = i
  end)
end
function M.goto_file(key)
  local dict = M.get_list(key)
  if M.locked_files[key] then
    vim.cmd.edit(M.locked_files[key])
  elseif #dict == 0 then
    if not vim.regex('\\v[a-z.-_]'):match_str(key) then
      return
    end
    require('small.lib.select')(
      vim.fs.find(function(name, path)
        return string.lower(name:sub(1, 1)) == key and not path:sub(#vim.fn.getcwd()):match('/%.')
      end, { type = 'file', limit = math.huge }),
      {
        -- custom
        format_item = function(file)
          return vim.fn.fnamemodify(file, ':.')
        end,
      },
      function(file)
        -- custom
        if file ~= nil then
          vim.cmd.edit(vim.fn.fnamemodify(file, ':.'))
        end
      end
    )
  elseif #dict == 1 then
    vim.cmd.edit(dict[1])
  else
    M.select(key)
  end
end
function M.select(key)
  require('small.lib.select')(M.get_list(key), {
    format_item = function(file)
      local relative_file = vim.fn.fnamemodify(file, ':.') -- custom
      return vim.tbl_contains(M.locked_files, file) and '>> ' .. relative_file or relative_file
    end,
  }, function(file)
    vim.cmd.edit(file)
  end)
end
function M.run()
  local char = vim.fn.getcharstr()
	-- vim.print(char)
  if char == '\t' then
    M.lock_file(vim.fn.getcharstr())
  elseif char == '\x80kb' then
    M.unlock_file(vim.fn.getcharstr())
  elseif char == '\r' then
    M.select()
  elseif char ~= '' then
    M.goto_file(char)
  end
end
return M
