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

function M.indent(size)
  vim.opt_local.tabstop = size
  vim.opt_local.shiftwidth = size
  -- vim.opt_local.softtabstop = size
end

return M
