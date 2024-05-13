---@class utils.toggle
local M = {}

---@param silent boolean?
---@param values? {[1]:any, [2]:any}
function M.option(option, silent, values)
  if values then
    if vim.opt_local[option]:get() == values[1] then
      vim.opt_local[option] = values[2]
    else
      vim.opt_local[option] = values[1]
    end
    return print('Set ' .. option .. ' to ' .. vim.opt_local[option]:get())
  end
  vim.opt_local[option] = not vim.opt_local[option]:get()
  if not silent then
    if vim.opt_local[option]:get() then
      print('Enabled ' .. option)
    else
      print('Disabled ' .. option)
    end
  end
end

local nu = { number = true, relativenumber = true }
function M.number()
  if vim.opt_local.number:get() or vim.opt_local.relativenumber:get() then
    nu = { number = vim.opt_local.number:get(), relativenumber = vim.opt_local.relativenumber:get() }
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    print('Disabled line numbers')
  else
    vim.opt_local.number = nu.number
    vim.opt_local.relativenumber = nu.relativenumber
    print('Enabled line numbers')
  end
end

local enabled = true
function M.diagnostics()
  enabled = not enabled
  if enabled then
    vim.diagnostic.enable()
    print('Enabled diagnostics')
  else
    vim.diagnostic.disable()
    print('Disabled diagnostics')
  end
end

---@param buf? number
---@param value? boolean
function M.inlay_hints(buf, value)
  local ih = vim.lsp.buf.inlay_hint or vim.lsp.inlay_hint
  if type(ih) == 'function' then
    ih(buf, value)
  elseif type(ih) == 'table' and ih.enable then
    if value == nil then
      value = not ih.is_enabled(buf)
    end
    ih.enable(value, { bufnr = buf })
  end
end

--- Toggle buffer semantic token highlighting for all language servers that support it
---@param bufnr? integer the buffer to toggle the clients on
---@param silent? boolean if true then don't sent a notification
function M.buffer_semantic_tokens(bufnr, silent)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  vim.b[bufnr].semantic_tokens = not vim.b[bufnr].semantic_tokens
  local toggled = false
  for _, client in ipairs((vim.lsp.get_clients)({ bufnr = bufnr })) do
    if client.server_capabilities.semanticTokensProvider then
      vim.lsp.semantic_tokens[vim.b[bufnr].semantic_tokens and 'start' or 'stop'](bufnr, client.id)
      toggled = true
    end
  end
  if not silent then
    if toggled then
      vim.notify(('%s semantic highlighting'):format(vim.b[bufnr].semantic_tokens and 'Enabled' or 'Disabled'))
    end
  end
end

setmetatable(M, {
  __call = function(m, ...)
    return m.option(...)
  end,
})

return M
