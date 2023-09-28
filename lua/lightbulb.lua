-- VSCode-like lightbulb.
-- from: https://github.com/MariaSolOs/dotfiles/blob/main/.config/nvim/lua/lightbulb.lua
-- Implementation inspired from https://github.com/nvimdev/lspsaga.nvim/blob/c9b17bc7dc694bdbeb3788a583518073a30a6de2/lua/lspsaga/codeaction/lightbulb.lua

local lb_name = 'mariasolos/lightbulb'
local lb_namespace = vim.api.nvim_create_namespace(lb_name)
local lb_icon = require('icons').diagnostics.HINT
local lb_group = vim.api.nvim_create_augroup(lb_name, { clear = true })
local code_action_method = vim.lsp.protocol.Methods.textDocument_codeAction

local timer = vim.uv.new_timer()
assert(timer, 'Timer was not initialized')

local updated_bufnr = nil

--- Updates the current lightbulb.
---@param bufnr number?
---@param line number?
local function update_extmark(bufnr, line)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  vim.api.nvim_buf_clear_namespace(bufnr, lb_namespace, 0, -1)

  -- Extra check for not being in insert mode here because sometimes the autocommand
  -- fails with motions from Comment.nvim.
  if not line or vim.api.nvim_get_mode().mode:sub(1, 1) == 'i' then
    return
  end

  -- TODO: If I continue seeing decorator errors, wrap this in a pcall.
  vim.api.nvim_buf_set_extmark(bufnr, lb_namespace, line, -1, {
    virt_text = { { ' ' .. lb_icon, 'DiagnosticSignHint' } },
    hl_mode = 'combine',
  })

  updated_bufnr = bufnr
end

--- Queries the LSP servers for code actions and updates the lightbulb
--- accordingly.
---@param bufnr number
local function render(bufnr)
  local line = vim.api.nvim_win_get_cursor(0)[1] - 1
  local diagnostics = vim.diagnostic.get(bufnr, { lnum = line })

  -- If there are hints in the current line, don't show yet another lightbulb.
  if vim.iter(diagnostics):any(function(diag)
    return diag.severity == vim.diagnostic.severity.HINT
  end) then
    update_extmark(bufnr, nil)
    return
  end

  local params = vim.lsp.util.make_range_params()
  params.context = {
    diagnostics = diagnostics,
    triggerKind = vim.lsp.protocol.CodeActionTriggerKind.Automatic,
  }

  vim.lsp.buf_request(bufnr, code_action_method, params, function(_, res, _)
    if vim.api.nvim_get_current_buf() ~= bufnr then
      return
    end

    update_extmark(bufnr, (res and #res > 0 and line) or nil)
  end)
end

-- I don't fully understand how this works, kind of just copy-pasted it
-- from lspsaga.
---@param bufnr number
local function update(bufnr)
  timer:stop()
  update_extmark(updated_bufnr)
  timer:start(100, 0, function()
    timer:stop()
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_get_current_buf() == bufnr then
        render(bufnr)
      end
    end)
  end)
end

vim.api.nvim_create_autocmd('LspAttach', {
  group = lb_group,
  desc = 'Configure code action lightbulb',
  callback = function(event)
    local buf = event.buf
    local client = vim.lsp.get_client_by_id(event.data.client_id)

    if not client or not client.supports_method(code_action_method) then
      return
    end

    local buf_group_name = lb_name .. tostring(buf)
    if pcall(vim.api.nvim_get_autocmds, { group = buf_group_name, buffer = buf }) then
      return
    end

    local lb_buf_group = vim.api.nvim_create_augroup(buf_group_name, { clear = true })
    vim.api.nvim_create_autocmd('CursorMoved', {
      group = lb_buf_group,
      desc = 'Update lightbulb when moving the cursor in normal/visual mode',
      buffer = buf,
      callback = function()
        update(buf)
      end,
    })

    vim.api.nvim_create_autocmd({ 'InsertEnter', 'BufLeave' }, {
      group = lb_buf_group,
      desc = 'Update lightbulb when entering insert mode or leaving the buffer',
      buffer = event.buf,
      callback = function()
        update_extmark(buf, nil)
      end,
    })
  end,
})

vim.api.nvim_create_autocmd('LspDetach', {
  group = lb_group,
  desc = 'Detach code action lightbulb',
  callback = function(event)
    pcall(vim.api.nvim_del_augroup_by_name, lb_name .. tostring(event.buf))
  end,
})
