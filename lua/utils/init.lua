local M = {}

-- a simple setTimeout wrapper
function M.setTimeout(timeout, callback)
  local timer = vim.uv.new_timer()
  timer:start(timeout, 0, function()
    timer:stop()
    timer:close()
    callback()
  end)
  return timer
end

return M
