-- from: https://github.com/altermo/small.nvim/blob/main/lua/small/bufend.lua
-- last commit: 35ecddc
-- skipped this: https://github.com/altermo/small.nvim/commit/d6a65c78bf9357966684bec448d56c09eeb3f744
local M = {}
function M.buf_get_file(buf)
  local filepath = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ':p')
  if vim.fn.filereadable(filepath) ~= 1 then
    return
  end
  return filepath
end
function M.buf_get_lfile(buf)
  return M.file_to_lfile(M.buf_get_file(buf))
end
function M.file_to_lfile(file)
  -- return file:gsub(vim.fn.getcwd(), '.')
  return vim.fn.fnamemodify(file, ':.') -- custom
end
M.marked_buf = {}
function M.get_buf_list(key)
  return vim
    .iter(vim.api.nvim_list_bufs())
    :filter(vim.api.nvim_buf_is_loaded)
    :filter(function(v)
      local file = M.buf_get_file(v)
      return file and ((not key) or key == vim.fn.fnamemodify(file, ':t'):sub(1, 1)) or false
    end)
    :rev()
    :totable()
end
function M.mark_buf(key)
  M.marked_buf[key] = vim.api.nvim_get_current_buf()
end
function M.unmark_buf(key)
  M.marked_buf[key] = nil
end
function M.select(list)
  require('small.lib.select')(vim.tbl_map(M.buf_get_lfile, list), {}, function(file)
    vim.cmd.edit(file)
  end)
end
function M.run()
  local keys = {}
  for _, buf in pairs(M.get_buf_list()) do
    local file = assert(M.buf_get_file(buf))
    local key = vim.fn.fnamemodify(file, ':t'):sub(1, 1)
    keys[key] = M.get_buf_list(key)
  end
  for key, buf in pairs(M.marked_buf) do
    keys[key] = keys[key] or {}
    table.insert(keys[key], buf)
  end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'wipe'
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
    '<space>: quick toggle buffer mark',
    '<cr>   : search buffer files',
    '<tab>  : toggle buffer mark (input)',
    '<C-s>  : search files (input)',
    '',
  })
  for key, bufs in vim.spairs(keys) do
    vim.api.nvim_buf_set_lines(
      buf,
      -1,
      -1,
      false,
      { (M.marked_buf[key] and '#' or '') .. key .. ' : ' .. table.concat(vim.tbl_map(M.buf_get_lfile, bufs), ' ;; ') }
    )
  end

  -- custom
  local width = 70
  local height = 15
  local center_y = ((vim.opt.lines:get() - height) / 2) - vim.opt.cmdheight:get()
  local center_x = (vim.opt.columns:get() - width) / 2
  local win = vim.api.nvim_open_win(buf, false, {
    relative = 'editor',
    width = width,
    height = height,
    col = center_x,
    row = center_y,
    focusable = false,
    style = 'minimal',
    border = 'rounded',
    noautocmd = true,
  })
  vim.api.nvim_buf_set_lines(buf, -1, -1, false, { '* : find files starting with *' })
  vim.cmd.redraw()
  local key = vim.fn.getcharstr()
  vim.api.nvim_win_close(win, true)
  local curbuf = vim.api.nvim_get_current_buf()
  if key == ' ' then
    local file = M.buf_get_file(curbuf)
    if not file then
      return
    end
    key = vim.fn.fnamemodify(file, ':t'):sub(1, 1)
    if M.marked_buf[key] == curbuf then
      M.unmark_buf(key)
    else
      M.mark_buf(key)
    end
  elseif key == '\r' then
    M.select(M.get_buf_list())
  elseif key == '\t' then
    key = vim.fn.getcharstr()
    if not key:match('[%w_.-]') then
      return
    end
    if M.marked_buf[key] == curbuf then
      M.unmark_buf(key)
    else
      M.mark_buf(key)
    end
  elseif key == '\x13' then
    key = vim.fn.getcharstr()
    if key:match('[%w_.-]') then
      local cb = function(files)
        local openfiles = vim.tbl_map(M.buf_get_file, keys[key])
        files = vim.tbl_filter(function(x)
          return not vim.tbl_contains(openfiles, x)
        end, files)
        if #files == 0 then
          vim.notify('no files found starting with ' .. key, vim.log.levels.INFO)
          return
        end
        if #files == 1 then
          vim.cmd.edit(files[1])
          return
        end
        require('small.lib.select')(vim.tbl_map(M.file_to_lfile, files), {}, function(file)
          if not file then
            return
          end
          vim.defer_fn(function()
            vim.cmd.edit(file)
          end, 50)
        end)
      end
      if vim.fn.executable('fd') == 0 then
        cb(vim.fs.find(function(name, path)
          return name:sub(1, 1) == key and not path:sub(#vim.fn.getcwd()):match('/%.')
        end, { type = 'file', limit = 1000 }))
      else
        vim.system({ 'fd', '-tfile', '-s', '-a', '^' .. key }, {}, function(ev)
          vim.schedule_wrap(cb)(vim.split(ev.stdout, '\n', { trimempty = true }))
        end)
      end
    end
  elseif key ~= '\x1b' then
    if keys[key] then
      if M.marked_buf[key] and curbuf ~= M.marked_buf[key] then
        vim.cmd.buf(M.marked_buf[key])
        return
      end
      local k = vim.tbl_filter(function(x)
        return x ~= curbuf
      end, keys[key])
      if #k == 1 then
        vim.cmd.buf(k[1])
        return
      elseif #k == 0 then
      else
        M.select(k)
        return
      end
    end
    if key:match('[%w_.-]') then
      local cb = function(files)
        files = vim.tbl_filter(function(x)
          return x ~= vim.fn.fnamemodify(vim.api.nvim_buf_get_name(curbuf), ':p')
        end, files)
        if #files == 0 then
          vim.notify('no files found starting with ' .. key, vim.log.levels.INFO)
          return
        end
        if #files == 1 then
          vim.cmd.edit(files[1])
          return
        end
        require('small.lib.select')(vim.tbl_map(M.file_to_lfile, files), {}, function(file)
          if not file then
            return
          end
          vim.defer_fn(function()
            vim.cmd.edit(file)
          end, 50)
        end)
      end
      if vim.fn.executable('fd') == 0 then
        cb(vim.fs.find(function(name, path)
          return name:sub(1, 1) == key and not path:sub(#vim.fn.getcwd()):match('/%.')
        end, { type = 'file', limit = 1000 }))
      else
        vim.system({ 'fd', '-tfile', '-s', '-a', '^' .. key }, {}, function(ev)
          vim.schedule_wrap(cb)(vim.split(ev.stdout, '\n', { trimempty = true }))
        end)
      end
    end
  end
end
if vim.dev then
  M.run()
end
return M
