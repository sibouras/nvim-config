---@diagnostic disable: undefined-field
return {
  -- LSP Configuration & Plugins
  'neovim/nvim-lspconfig',
  -- commit = '1393aaca8a59a9ce586ed55770b3a02155a56ac2',
  event = 'LazyFile',
  dependencies = {
    -- Automatically install LSPs to stdpath for neovim
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'b0o/SchemaStore.nvim',

    -- Useful status updates for LSP
    -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
    { 'j-hui/fidget.nvim', opts = {} },
  },
  config = function()
    -- Diagnostic keymaps
    local opts = { noremap = true, silent = true }
    local map = vim.keymap.set
    map('n', '<leader>dg', vim.diagnostic.open_float, opts)
    map('n', '<leader>dq', vim.diagnostic.setloclist, opts)
    map('n', '<leader>li', '<Cmd>LspInfo<CR>', { desc = 'LspInfo' })
    map('n', '<leader>lm', '<Cmd>Mason<CR>', { desc = 'Mason' })
    map('n', '<leader>ln', '<Cmd>NullLsInfo<CR>', { desc = 'NullLsInfo' })

    -- restore terminal tab title after formatting
    local function restoreTitle()
      local title = vim.uv.get_process_title()
      -- require('utils').setTimeout(500, function()
      --   vim.uv.set_process_title(title)
      -- end)
      vim.defer_fn(function()
        vim.uv.set_process_title(title)
      end, 500)
    end
    map('n', '<M-F>', function()
      vim.lsp.buf.format({ async = true })
      if vim.g.is_win then
        restoreTitle()
      end
    end)
    map('v', '<M-F>', function()
      vim.lsp.buf.format({ async = true, range = true })
      if vim.g.is_win == 1 then
        restoreTitle()
      end
    end)

    -- LSP settings.
    --  This function gets run when an LSP connects to a particular buffer.
    local on_attach = function(client, bufnr)
      -- Make omnicomplete use LSP completions
      -- vim.bo.omnifunc = "v:lua.vim.lsp.omnifunc"

      -- local navic_status_ok, navic = pcall(require, "nvim-navic")
      -- if not navic_status_ok then
      --   print("nvim-navic not found")
      --   return
      -- end
      --
      -- -- attach nvim-navic
      -- if client.server_capabilities.documentSymbolProvider and client.name ~= "astro" then
      --   navic.attach(client, bufnr)
      -- end

      -- if client.supports_method('textDocument/inlayHint') then
      --   require('utils.toggle').inlay_hints(bufnr, true)
      -- end

      -- semantic tokens
      -- NOTE: get the method names from: vim.lsp.protocol.Methods
      if client.supports_method('textDocument/semanticTokens') then
        -- client.server_capabilities.semanticTokensProvider = nil
        if client.name == 'lua_ls' then
          -- override tokenTypes table because i only want to highlight parameters
          client.server_capabilities.semanticTokensProvider.legend.tokenTypes = {
            'namespace',
            'type',
            'class',
            'enum',
            'interface',
            'struct',
            'typeParameter',
            'parameter',
          }
        end
      end

      if client.name == 'tsserver' or client.name == 'html' then
        client.server_capabilities.documentFormattingProvider = false
      end

      if client.name == 'denols' then
        require('null-ls').disable({ 'prettierd', 'biome' })
      end

      local nmap = function(keys, func, desc)
        if desc then
          desc = 'LSP: ' .. desc
        end

        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
      end

      nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
      nmap('<leader>lc', vim.lsp.buf.code_action, '[C]ode [A]ction')
      nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
      -- nmap('gd', '<cmd>TroubleToggle lsp_definitions<cr>', '[G]oto [D]efinition')
      nmap('gR', '<cmd>TroubleToggle lsp_references<cr>', '[G]oto [R]eferences')

      -- See `:help K` for why this keymap
      nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
      nmap('<leader>k', vim.lsp.buf.hover, 'Hover Documentation')

      local bufopts = { noremap = true, silent = true, buffer = bufnr, desc = 'Signature Documentation' }
      vim.keymap.set({ 'n', 'i' }, '<M-/>', vim.lsp.buf.signature_help, bufopts)

      -- Lesser used LSP functionality
      nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
      nmap('<leader>lwa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
      nmap('<leader>lwr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
      nmap('<leader>lwl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end, '[W]orkspace [L]ist Folders')

      -- Create a command `:Format` local to the LSP buffer
      vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
        vim.lsp.buf.format()
      end, { desc = 'Format current buffer with LSP' })
    end

    -- :LspInfo border
    require('lspconfig.ui.windows').default_options.border = 'rounded'

    local signs = {
      { name = 'DiagnosticSignError', text = '✘' },
      { name = 'DiagnosticSignWarn', text = '▲' },
      { name = 'DiagnosticSignHint', text = '⚑' },
      { name = 'DiagnosticSignInfo', text = '' },
    }

    for _, sign in ipairs(signs) do
      vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = '' })
    end

    local config = {
      -- virtual_text = { prefix = "" },
      -- disable virtual text
      virtual_text = false,
      -- show signs
      -- signs = {
      --   active = signs,
      -- },
      update_in_insert = false,
      underline = true,
      severity_sort = true,
      float = {
        focusable = true,
        style = 'minimal',
        border = 'rounded',
        source = 'always',
        header = '',
        prefix = '',
      },
    }

    vim.diagnostic.config(config)

    vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, {
      border = 'rounded',
    })

    -- vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    --   border = "rounded",
    -- })

    -- disable notifications in vim.lsp.buf.hover
    -- from: https://github.com/neovim/neovim/issues/20457
    ---@diagnostic disable-next-line: redefined-local
    vim.lsp.handlers['textDocument/hover'] = function(_, result, ctx, config)
      config = config or { border = 'rounded' }
      config.focus_id = ctx.method
      if not (result and result.contents) then
        return
      end
      local markdown_lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
      ---@diagnostic disable-next-line: deprecated
      markdown_lines = vim.lsp.util.trim_empty_lines(markdown_lines)
      if vim.tbl_isempty(markdown_lines) then
        return
      end
      return vim.lsp.util.open_floating_preview(markdown_lines, 'markdown', config)
    end

    -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

    -- Setup mason so it can manage external tooling
    require('mason').setup({
      ui = {
        border = 'rounded',
        icons = {
          package_installed = '✓',
          package_pending = '➜',
          -- package_uninstalled = "✗",
        },
      },
    })

    local lspconfig = require('lspconfig')

    -- Ensure the servers above are installed
    local mason_lspconfig = require('mason-lspconfig')

    -- https://github.com/williamboman/mason.nvim/discussions/92#discussioncomment-3173425

    -- Extension to bridge mason.nvim with the lspconfig plugin
    -- this slows down startuptime
    -- mason_lspconfig.setup({
    --   -- A list of servers to automatically install if they're not already installed.
    --   ensure_installed = {
    --     "lua-language-server",
    --   },
    -- })

    local function organize_imports()
      local params = {
        command = '_typescript.organizeImports',
        arguments = { vim.api.nvim_buf_get_name(0) },
        title = '',
      }
      vim.lsp.buf.execute_command(params)
    end

    mason_lspconfig.setup_handlers({
      function(server_name)
        require('lspconfig')[server_name].setup({
          capabilities = capabilities,
          on_attach = on_attach,
          -- settings = servers[server_name],
        })
      end,

      -- Next, you can provide targeted overrides for specific servers.
      -- For example, a handler override for the `rust_analyzer`:
      -- ["rust_analyzer"] = function()
      --   require("rust-tools").setup({})
      -- end,

      ['lua_ls'] = function()
        require('lspconfig').lua_ls.setup({
          on_attach = on_attach,
          capabilities = capabilities,
          single_file_support = false,
          on_init = function(client)
            local path = client.workspace_folders[1].name
            if not vim.uv.fs_stat(path .. '/.luarc.json') and not vim.uv.fs_stat(path .. '/.luarc.jsonc') then
              client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
                -- Tell the language server which version of Lua you're using
                -- (most likely LuaJIT in the case of Neovim)
                runtime = { version = 'LuaJIT' },
                -- Make the server aware of Neovim runtime files
                workspace = {
                  checkThirdParty = false,
                  library = {
                    -- vim.env.VIMRUNTIME,
                    -- '${3rd}/luv/library',
                  },
                  -- maxPreload = 0, -- lua_ls is preloading files with diagnotic errors and adding them to oldfiles
                },
              })
              client.notify(
                vim.lsp.protocol.Methods.workspace_didChangeConfiguration,
                { settings = client.config.settings }
              )
            end
            return true
          end,
          settings = {
            Lua = {
              format = { enable = false },
              diagnostics = { globals = { 'vim' } },
              telemetry = { enable = false },
              hint = { enable = true, arrayIndex = 'Disable' },
            },
          },
        })
      end,

      ['tsserver'] = function()
        lspconfig.tsserver.setup({
          -- autostart = false,
          on_attach = on_attach,
          capabilities = capabilities,
          single_file_support = false,
          commands = {
            OrganizeImports = {
              organize_imports,
              description = 'Organize Imports',
            },
          },
          -- DOCS: https://github.com/typescript-language-server/typescript-language-server/blob/master/docs/configuration.md
          -- Diagnostics code to be omitted when reporting diagnostics.
          -- See https://github.com/microsoft/TypeScript/blob/main/src/compiler/diagnosticMessages.json for a full list of valid codes.
          settings = {
            diagnostics = {
              ignoredCodes = { 80001 }, -- File is a CommonJS module; it may be converted to an ES module
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
        })
      end,

      ['unocss'] = function()
        lspconfig.unocss.setup({
          on_attach = function(client)
            client.server_capabilities.completionProvider.triggerCharacters = { '-' }
          end,
          capabilities = capabilities,
        })
      end,

      ['tailwindcss'] = function()
        lspconfig.tailwindcss.setup({
          on_attach = function(client, bufnr)
            -- if client.server_capabilities.colorProvider then
            --   -- require("user.lsp.utils.documentcolors").buf_attach(bufnr)
            --   -- slows opening files
            --   require('document-color').buf_attach(bufnr)
            -- end
            -- client.server_capabilities.hoverProvider = false
            -- client.server_capabilities.completionProvider = false
            client.server_capabilities.completionProvider.triggerCharacters = {
              '"',
              "'",
              '`',
              '.',
              '(',
              '[',
              '!',
              '/',
              ':',
            }
          end,
          capabilities = capabilities,
          -- flags = {
          --   debounce_text_changes = 500,
          -- },
          filetypes = { 'html', 'css', 'javascriptreact', 'typescriptreact', 'vue', 'svelte' },
          root_dir = lspconfig.util.root_pattern('tailwind.config.js', 'tailwind.config.ts'),
        })
      end,

      ['cssls'] = function()
        lspconfig.cssls.setup({
          on_attach = on_attach,
          capabilities = capabilities,
          settings = {
            css = {
              validate = true,
              lint = {
                -- Do not warn for Tailwind's @apply rule
                unknownAtRules = 'ignore',
              },
            },
          },
        })
      end,

      ['emmet_ls'] = function()
        lspconfig.emmet_ls.setup({
          on_attach = function(client)
            client.server_capabilities.completionProvider.triggerCharacters = { '.', '>', '*', '+' }
          end,
          capabilities = capabilities,
          filetypes = { 'html', 'typescriptreact', 'javascriptreact', 'css', 'sass', 'scss', 'less' },
          -- filetypes = { "html", "css", "sass", "scss", "less" },
        })
      end,

      ['emmet_language_server'] = function()
        lspconfig.emmet_language_server.setup({
          capabilities = capabilities,
          filetypes = { 'html', 'typescriptreact', 'javascriptreact', 'css', 'sass', 'scss', 'less' },
        })
      end,

      ['jsonls'] = function()
        lspconfig.jsonls.setup({
          on_attach = on_attach,
          capabilities = capabilities,
          init_options = {
            provideFormatter = false,
          },
          settings = {
            json = {
              schemas = require('schemastore').json.schemas(),
              validate = { enable = false },
            },
          },
        })
      end,

      ['eslint'] = function()
        lspconfig.eslint.setup({
          on_attach = on_attach,
          capabilities = capabilities,
          root_dir = lspconfig.util.root_pattern(
            '.eslintrc',
            '.eslintrc.js',
            '.eslintrc.cjs',
            '.eslintrc.json',
            'eslint.config.js'
          ),
        })
      end,

      ['gopls'] = function()
        lspconfig.gopls.setup({
          on_attach = on_attach,
          capabilities = capabilities,
          cmd = { 'gopls.cmd' },
        })
      end,
    })

    lspconfig.rust_analyzer.setup({
      on_attach = on_attach,
      capabilities = capabilities,
      cmd = { 'rustup', 'run', 'stable', 'rust-analyzer' },
    })

    lspconfig.denols.setup({
      on_attach = on_attach,
      capabilities = capabilities,
      cmd = { 'deno', 'lsp' },
      root_dir = lspconfig.util.root_pattern('deno.json', 'deno.jsonc'),
    })

    lspconfig.biome.setup({
      root_dir = lspconfig.util.root_pattern('biome.json', 'biome.jsonc'),
      single_file_support = false,
    })
  end,
}
