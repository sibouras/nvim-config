return {
  -- LSP Configuration & Plugins
  'neovim/nvim-lspconfig',
  commit = '1393aaca8a59a9ce586ed55770b3a02155a56ac2',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    -- Automatically install LSPs to stdpath for neovim
    { 'williamboman/mason.nvim', config = true },
    'williamboman/mason-lspconfig.nvim',
    { 'b0o/SchemaStore.nvim' },

    -- Useful status updates for LSP
    -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
    { 'j-hui/fidget.nvim', tag = 'legacy', opts = {} },
  },
  config = function()
    -- Diagnostic keymaps
    local opts = { noremap = true, silent = true }
    local map = vim.keymap.set
    map('n', '<leader>dg', vim.diagnostic.open_float, opts)
    map('n', '<leader>dq', vim.diagnostic.setloclist, opts)
    map('n', '<M-F>', function()
      vim.lsp.buf.format({ async = true })
    end, opts)
    map('v', '<M-F>', function()
      vim.lsp.buf.format({ async = true, range = true })
    end)
    map('n', '<leader>li', '<Cmd>LspInfo<CR>')
    map('n', '<leader>lm', '<Cmd>Mason<CR>')
    map('n', '<leader>ln', '<Cmd>NullLsInfo<CR>')
    map('n', '<leader>la', '<Cmd>Lazy<CR>')

    -- toggle LSP diagnostics
    vim.g.diagnostics_active = true
    map('n', '<leader>td', function()
      vim.g.diagnostics_active = not vim.g.diagnostics_active
      if vim.g.diagnostics_active then
        vim.diagnostic.enable()
      else
        vim.diagnostic.disable()
      end
    end, { desc = 'toggle LSP diagnostics' })

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

      if client.name == 'sumneko_lua' or client.name == 'tsserver' or client.name == 'html' then
        client.server_capabilities.documentFormattingProvider = false
      end

      if client.name == 'denols' then
        require('null-ls').disable('prettierd')
      end

      local nmap = function(keys, func, desc)
        if desc then
          desc = 'LSP: ' .. desc
        end

        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
      end

      nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
      nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
      nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
      nmap('gR', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
      nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
      nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
      nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
      nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

      -- See `:help K` for why this keymap
      nmap('K', vim.lsp.buf.hover, 'Hover Documentation')

      local bufopts = { noremap = true, silent = true, buffer = bufnr, desc = 'Signature Documentation' }
      vim.keymap.set({ 'n', 'i' }, '<M-/>', vim.lsp.buf.signature_help, bufopts)

      -- Lesser used LSP functionality
      nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
      nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
      nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
      nmap('<leader>wl', function()
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
    vim.lsp.handlers['textDocument/hover'] = function(_, result, ctx, config)
      config = config or { border = 'rounded' }
      config.focus_id = ctx.method
      if not (result and result.contents) then
        return
      end
      local markdown_lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
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
        require('lspconfig').sumneko_lua.setup({
          on_attach = on_attach,
          capabilities = capabilities,
          single_file_support = false,
          settings = {
            Lua = {
              runtime = {
                version = 'LuaJIT',
              },
              diagnostics = {
                globals = { 'vim' },
              },
              workspace = {
                library = {
                  [vim.fn.expand('$VIMRUNTIME/lua')] = true,
                  [vim.fn.stdpath('config') .. '/lua'] = true,
                },
              },
              telemetry = {
                enable = false,
              },
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
          -- https://openbase.com/js/typescript-language-server/documentation
          -- Diagnostics code to be omitted when reporting diagnostics.
          -- See https://github.com/microsoft/TypeScript/blob/master/src/compiler/diagnosticMessages.json for a full list of valid codes.
          settings = {
            diagnostics = {
              ignoredCodes = { 80001 },
            },
          },
          -- init_options = {
          --   preferences = {
          --     disableSuggestions = true,
          --   },
          -- },
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
          on_attach = function(client, bufnr)
            client.server_capabilities.completionProvider.triggerCharacters = { '-' }
          end,
          capabilities = capabilities,
        })
      end,

      ['tailwindcss'] = function()
        lspconfig.tailwindcss.setup({
          on_attach = function(client, bufnr)
            if client.server_capabilities.colorProvider then
              -- require("user.lsp.utils.documentcolors").buf_attach(bufnr)
              require('document-color').buf_attach(bufnr)
            end
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
          on_attach = function(client, bufnr)
            client.server_capabilities.completionProvider.triggerCharacters = { '.', '>', '*', '+' }
          end,
          capabilities = capabilities,
          filetypes = { 'html', 'typescriptreact', 'javascriptreact', 'css', 'sass', 'scss', 'less' },
          -- filetypes = { "html", "css", "sass", "scss", "less" },
        })
      end,

      ['marksman'] = function()
        lspconfig.marksman.setup({
          on_attach = on_attach,
          capabilities = capabilities,
          cmd = { 'marksman.cmd', 'server' },
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
              validate = { enable = true },
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

    -- Turn on lsp status information
    require('fidget').setup()
  end,
}
