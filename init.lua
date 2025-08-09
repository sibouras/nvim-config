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

-- LazyFile event ot Properly load file based plugins without blocking the UI
-- WARNING: load before Lazy
require('utils.plugin').lazy_file()

-- Remap space as leader key
vim.g.mapleader = ' ' -- Make sure to set `mapleader` before lazy so your mappings are correct
vim.g.maplocalleader = ' '
vim.g.is_win = vim.uv.os_uname().sysname:find('Windows') ~= nil
vim.keymap.set('n', '<Space><Esc>', '<Nop>') -- prevent cursor jumping when escaping bofore which-key pops

require('lazy').setup('plugins', {
  -- version = false, -- always use the latest git commit
  change_detection = { notify = false },
  -- checker = { enabled = true }, -- automatically check for plugin updates
  concurrency = jit.os:find('Windows') and 8 or nil,
  git = {
    log = { '--since=3 days ago' }, -- show commits from the last 3 days
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
        -- 'matchparen', -- uncomment this when using sentiment.nvim
        'tohtml',
        jit.os:find('Windows') and 'man',
        'spellfile',
      },
    },
  },
})

require('keymaps')
require('options')
require('autocmds')
require('close-unused-buffers')

local should_profile = os.getenv('NVIM_PROFILE')
if should_profile then
  require('profile').instrument_autocmds()
  if should_profile:lower():match('^start') then
    require('profile').start('*')
  else
    require('profile').instrument('*')
  end
end

local function toggle_profile()
  local prof = require('profile')
  if prof.is_recording() then
    prof.stop()
    vim.ui.input({ prompt = 'Save profile to:', completion = 'file', default = 'profile.json' }, function(filename)
      if filename then
        prof.export(filename)
        vim.notify(string.format('Wrote %s', filename))
      end
    end)
  else
    prof.start('*')
  end
end

vim.keymap.set('', '<F11>', toggle_profile)
