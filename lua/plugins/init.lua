-- Any files inside the lua/plugins directory will also
-- automatically be sourced. These plugins are those that
-- do not require any configuration.

return {
  -- the colorscheme should be available when starting Neovim
  "folke/which-key.nvim",
  "dstein64/vim-startuptime",
  "famiu/bufdelete.nvim",
  {
    "windwp/nvim-autopairs",
    -- event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup()
    end
  },
}
