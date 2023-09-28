return {
  'folke/tokyonight.nvim',
  lazy = false, -- make sure we load this during startup if it is your main colorscheme
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
    require('tokyonight').setup({
      style = 'night',
      styles = {
        comments = { italic = false },
        keywords = { italic = false },
      },
      sidebars = { 'lspinfo', 'null-ls-info' }, -- Set a darker background on sidebar-like windows. For example: `["qf", "vista_kind", "terminal", "packer"]`
      on_colors = function(colors)
        colors.bg = '#0c0d11'
        colors.bg_dark = '#121218'
        colors.bg_popup = '#121218'
        colors.bg_sidebar = '#121218'
        -- colors.bg_highlight = "#24283b"
        colors.bg_highlight = '#181a22'
        colors.bg_statusline = '#121218'
      end,
      on_highlights = function(hl, colors)
        hl.TabLineSel = { bg = '#1A2336' }
      end,
    })

    -- load the colorscheme here
    vim.cmd([[colorscheme tokyonight]])
  end,
}
