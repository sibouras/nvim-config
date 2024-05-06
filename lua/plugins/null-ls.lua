return {
  'nvimtools/none-ls.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = { 'mason.nvim' },
  opts = function()
    local null_ls = require('null-ls')
    -- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
    local formatting = null_ls.builtins.formatting
    -- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
    local diagnostics = null_ls.builtins.diagnostics
    local code_actions = null_ls.builtins.code_actions

    return {
      root_dir = require('null-ls.utils').root_pattern('.null-ls-root', '.neoconf.json', 'Makefile', '.git'),
      sources = {
        -- formatting.prettier.with({ extra_args = { "--single-quote", "--jsx-single-quote" } }),
        -- formatting.prettierd.with({
        --   filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "html", "css", "markdown" },
        -- }),
        formatting.prettierd.with({
          -- filetypes = { 'css', 'scss', 'less', 'yaml', 'markdown', 'markdown.mdx', 'vue', 'graphql' },
          disabled_filetypes = {
            'javascript',
            'javascriptreact',
            'typescript',
            'typescriptreact',
            'json',
            'jsonc',
            'css',
          },
          env = {
            PRETTIERD_DEFAULT_CONFIG = vim.fn.stdpath('config') .. '/linter-config/.prettierrc.json',
          },
        }),
        formatting.stylua.with({
          extra_args = { '--indent-type=Spaces', '--indent-width=2', '--quote-style=AutoPreferSingle' },
        }),
        -- code_actions.eslint_d.with({
        --   disabled_filetypes = { "typescript" },
        --   condition = function(utils)
        --     return utils.root_has_file({
        --       ".eslintrc",
        --       ".eslintrc.js",
        --       ".eslintrc.cjs",
        --       ".eslintrc.json",
        --       "eslint.config.js",
        --     })
        --   end,
        -- }),
        -- diagnostics.eslint_d.with({
        --   disabled_filetypes = { "typescript" },
        --   condition = function(utils)
        --     return utils.root_has_file({
        --       ".eslintrc",
        --       ".eslintrc.js",
        --       ".eslintrc.cjs",
        --       ".eslintrc.json",
        --       "eslint.config.js",
        --     })
        --   end,
        -- }),
      },
    }
  end,
}
