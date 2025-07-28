---@diagnostic disable: undefined-field
return {
  -- LSP Configuration & Plugins
  'neovim/nvim-lspconfig',
  -- commit = '1393aaca8a59a9ce586ed55770b3a02155a56ac2',
  event = 'LazyFile',
  dependencies = {
    -- Automatically install LSPs to stdpath for neovim
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
        if client.name == 'ts_ls' then
          -- this keeps creating tscancellation files in temp folder
          client.server_capabilities.documentHighlightProvider = false
        end
      end

      if client.name == 'ts_ls' or client.name == 'html' then
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
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
      nmap('<leader>k', function()
        ---@diagnostic disable-next-line: redundant-parameter
        vim.lsp.buf.hover({
          max_width = 100,
          -- max_height = math.floor(vim.o.lines * 0.5),
          -- max_width = math.floor(vim.o.columns * 0.4),
        })
      end, 'Hover Documentation')

      local bufopts = { noremap = true, silent = true, buffer = bufnr, desc = 'Signature Documentation' }
      vim.keymap.set({ 'n', 'i' }, '<M-/>', function()
        ---@diagnostic disable-next-line: redundant-parameter
        vim.lsp.buf.signature_help({
          max_width = 100,
        })
      end, bufopts)

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

    vim.api.nvim_create_autocmd('LspAttach', {
      desc = 'Configure LSP keymaps',
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        -- I don't think this can happen but it's a wild world out there.
        if not client then
          return
        end
        on_attach(client, args.buf)
      end,
    })

    local config = {
      -- virtual_text = { prefix = "" },
      virtual_text = false,
      virtual_lines = false,
      signs = {
        -- set sign by using extmark
        -- https://github.com/neovim/neovim/pull/26193
        text = { ['ERROR'] = '✘', ['WARN'] = '▲', ['HINT'] = '⚑', ['INFO'] = '' },
      },
      update_in_insert = false,
      underline = true,
      severity_sort = true,
      float = {
        focusable = true,
        style = 'minimal',
        source = 'always',
        header = '',
        prefix = '',
      },
    }

    vim.diagnostic.config(config)

    -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    -- capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
    capabilities = require('blink.cmp').get_lsp_capabilities(capabilities)

    vim.schedule(function()
      -- before 0.11.2 this used to work without vim.schedule
      -- https://old.reddit.com/r/neovim/comments/1l7pz1l/starting_from_0112_i_have_a_weird_issue/
      -- https://github.com/neovim/neovim/issues/33116
      -- https://github.com/neovim/neovim/pull/33762
      vim.lsp.enable({ 'lua_ls', 'ts_ls', 'html', 'taplo' })
    end)

    local lspconfig = require('lspconfig')

    lspconfig.cssls.setup({
      on_attach = on_attach,
      capabilities = capabilities,
      -- https://github.com/neovim/neovim/issues/33577
      init_options = {
        provideFormatter = false,
      },
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

    lspconfig.emmet_language_server.setup({
      on_attach = function(client)
        client.server_capabilities.completionProvider.triggerCharacters = {}
      end,
      capabilities = capabilities,
      filetypes = { 'html', 'typescriptreact', 'javascriptreact', 'css', 'sass', 'scss', 'less' },
    })

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

    lspconfig.rust_analyzer.setup({
      on_attach = on_attach,
      capabilities = capabilities,
      cmd = { 'rustup', 'run', 'stable', 'rust-analyzer' },
    })

    lspconfig.nushell.setup({
      on_attach = on_attach,
      capabilities = capabilities,
    })

    lspconfig.denols.setup({
      on_attach = on_attach,
      capabilities = capabilities,
      cmd = { 'deno', 'lsp' },
      root_dir = lspconfig.util.root_pattern('deno.json', 'deno.jsonc'),
    })

    lspconfig.biome.setup({
      on_attach = function(client)
        -- formatting modifies the buffer even when there's no changes, use null-ls instead
        client.capabilities.textDocument.formatting.dynamicRegistration = false
        client.capabilities.textDocument.rangeFormatting.dynamicRegistration = false
      end,
      -- check for the biome package within package.json using insert_package_json method
      -- https://github.com/neovim/nvim-lspconfig/pull/3648
      root_dir = function(fname)
        local root_files = { 'biome.json', 'biome.jsonc' }
        root_files = lspconfig.util.insert_package_json(root_files, 'biome', fname)
        -- return vim.fs.dirname(vim.fs.find(root_files, { path = fname, upward = true })[1])
        return lspconfig.util.root_pattern(unpack(root_files))(fname)
      end,
      single_file_support = false,
    })

    -- https://github.com/thqby/vscode-autohotkey2-lsp?tab=readme-ov-file#nvim-lspconfig
    local ahk2_configs = {
      autostart = true,
      single_file_support = true,
      on_attach = on_attach,
      capabilities = capabilities,
      filetypes = { 'ahk', 'autohotkey', 'ahk2' },
      cmd = { 'node', vim.fn.expand('$HOME/src/vscode-autohotkey2-lsp/server/dist/server.js'), '--stdio' },
      init_options = {
        ActionWhenV1IsDetected = 'Stop',
        locale = 'en-us',
        InterpreterPath = 'C:/Program Files/AutoHotkey/v2/AutoHotkey.exe',
      },
      flags = { debounce_text_changes = 500 },
    }

    local configs = require('lspconfig.configs')
    configs.ahk2 = { default_config = ahk2_configs }
    local nvim_lsp = require('lspconfig')
    nvim_lsp.ahk2.setup({})
  end,
}
