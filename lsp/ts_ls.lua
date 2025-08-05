---@diagnostic disable-next-line: undefined-doc-name
---@type vim.lsp.Config
return {
  -- autostart = false,
  -- single_file_support = false,
  -- commands = {
  --   OrganizeImports = {
  --     organize_imports,
  --     description = 'Organize Imports',
  --   },
  -- },
  -- DOCS: https://github.com/typescript-language-server/typescript-language-server/blob/master/docs/configuration.md
  -- Diagnostics code to be omitted when reporting diagnostics.
  -- See https://github.com/microsoft/TypeScript/blob/main/src/compiler/diagnosticMessages.json for a full list of valid codes.
  settings = {
    diagnostics = {
      -- 80001: File is a CommonJS module; it may be converted to an ES module
      -- 6133: '{0}' is declared but its value is never read.
      ignoredCodes = { 80001, 6133 },
    },
  },
  init_options = {
    preferences = {
      -- disableSuggestions = true,
      -- includeInlayParameterNameHints = 'literals',
      includeInlayVariableTypeHints = true,
      includeInlayFunctionLikeReturnTypeHints = true,
    },
  },
  -- disable lsp in node_modules
  -- not needed anymore: https://github.com/neovim/nvim-lspconfig/pull/2287
  -- root_dir = function(fname)
  --   if string.find(fname, "node_modules/") then
  --     return
  --   end
  --   local root_files = { "package.json", "tsconfig.json", "jsconfig.json", ".git" }
  --   return lspconfig.util.root_pattern(unpack(root_files))(fname)
  -- end,
}
