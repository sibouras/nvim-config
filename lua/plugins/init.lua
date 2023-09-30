-- Any files inside the lua/plugins directory will also
-- automatically be sourced. These plugins are those that
-- do not require any configuration.

return {
  { 'dstein64/vim-startuptime', cmd = 'StartupTime', enabled = true },
  'svban/YankAssassin.vim',
  'Sangdol/mintabline.vim',
  { 'utilyre/sentiment.nvim', event = 'VeryLazy', opts = {} },
}
