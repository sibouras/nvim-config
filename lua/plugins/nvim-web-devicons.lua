return {
  'nvim-tree/nvim-web-devicons',
  lazy = true,
  config = function()
    require('nvim-web-devicons').set_icon({
      astro = {
        icon = '',
        color = '#ff7e33',
        name = 'astro',
      },
    })
  end,
}
