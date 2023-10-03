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

-- Remap space as leader key
vim.g.mapleader = ' ' -- Make sure to set `mapleader` before lazy so your mappings are correct
vim.g.maplocalleader = ' '
vim.keymap.set('n', '<Space><Esc>', '<Nop>') -- prevent cursor jumping when escaping bofore which-key pops

require('lazy').setup('plugins', {
  change_detection = {
    notify = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        'gzip',
        'netrwPlugin',
        'rplugin',
        'zipPlugin',
        'tarPlugin',
        -- 'shada', -- for editing ShaDa files
        -- 'matchit', -- matches html tags
        'matchparen', -- replaced with sentiment.nvim
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
-- require('lightbulb')
