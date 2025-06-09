return {
  'nvimtools/none-ls.nvim',
  event = 'LazyFile',
  opts = function()
    local null_ls = require('null-ls')
    -- https://github.com/nvimtools/none-ls.nvim/blob/main/doc/BUILTINS.md
    local builtins = null_ls.builtins

    return {
      root_dir = require('null-ls.utils').root_pattern('.null-ls-root', '.neoconf.json', 'Makefile', '.git'),
      sources = {
        -- builtins.formatting.prettier.with({ extra_args = { "--single-quote", "--jsx-single-quote" } }),
        -- builtins.formatting.prettierd.with({
        --   filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "html", "css", "markdown" },
        -- }),
        builtins.formatting.prettierd.with({
          -- filetypes = { 'css', 'scss', 'less', 'yaml', 'markdown', 'markdown.mdx', 'vue', 'graphql' },
          -- disable biome supported filetypes
          disabled_filetypes = {
            'javascript',
            'javascriptreact',
            'typescript',
            'typescriptreact',
            'json',
            'jsonc',
            'css',
            'astro',
            'vue',
            'svelte',
            'graphql',
          },
          env = {
            PRETTIERD_DEFAULT_CONFIG = vim.fn.stdpath('config') .. '/linter-config/.prettierrc.json',
          },
        }),
        builtins.formatting.biome,
        builtins.formatting.stylua.with({
          extra_args = { '--indent-type=Spaces', '--indent-width=2', '--quote-style=AutoPreferSingle' },
        }),
        -- builtins.code_actions.eslint_d.with({
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
        -- builtins.diagnostics.eslint_d.with({
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
