local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = ' ' -- Make sure to set `mapleader` before lazy so your mappings are correct

require('lazy').setup('plugins', {
  -- "folke/which-key.nvim",
  performance = {
    rtp = {
      disabled_plugins = {
        'gzip',
        'zipPlugin',
        'tarPlugin',
        'matchit',
        'tohtml',
        'man',
        'spellfile',
      },
    },
  },
})

require('keymaps')
require('options')
require('autocmds')

vim.cmd([[
  highlight Underlined guisp=#7aa2f7 " change markdown link color
  highlight markdownLinkText guisp=#7aa2f7
  highlight WinSeparator guifg=#3b4261
  highlight HarpoonCurrentFile guifg=#7aa2f7
]])
