-- Any files inside the lua/plugins directory will also
-- automatically be sourced. These plugins are those that
-- do not require any configuration.

return {
  { 'dstein64/vim-startuptime', cmd = 'StartupTime', enabled = false },
  'Sangdol/mintabline.vim',
  { 'airblade/vim-matchquote', event = 'VeryLazy' }, -- should be loaded after matchit plugin
  { 'utilyre/sentiment.nvim', event = 'VeryLazy', opts = {} },
}
