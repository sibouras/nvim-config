-- Any files inside the lua/plugins directory will also
-- automatically be sourced. These plugins are those that
-- do not require any configuration.

return {
  { 'dstein64/vim-startuptime', cmd = 'StartupTime', enabled = false },
  'Sangdol/mintabline.vim',
  -- 'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
  { 'airblade/vim-matchquote', event = 'VeryLazy' }, -- should be loaded after matchit plugin
  { 'utilyre/sentiment.nvim', event = 'VeryLazy', opts = {} },
  { 'svban/YankAssassin.vim', event = 'VeryLazy' },
  'stevearc/profile.nvim',
}
