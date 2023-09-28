return {
  'goolord/alpha-nvim',
  -- enabled = false,
  event = 'VimEnter',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    local dashboard = require('alpha.themes.dashboard')
    dashboard.section.header.val = {
      [[                               __                ]],
      [[  ___     ___    ___   __  __ /\_\    ___ ___    ]],
      [[ / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\  ]],
      [[/\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \ ]],
      [[\ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\]],
      [[ \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/]],
    }
    dashboard.section.buttons.val = {
      dashboard.button('e', '  New file', ':enew <BAR> startinsert<CR>'),
      dashboard.button('f', '  Find file', ':Telescope find_files<CR>'),
      dashboard.button('p', '  Find project', ':Telescope workspaces<CR>'),
      dashboard.button('o', '  old files', ':Telescope oldfiles<CR>'),
      dashboard.button('w', '  Wiki', ':WorkspacesOpen docuwiki<CR>'),
      dashboard.button('c', '  Configuration', ':WorkspacesOpen nvim<CR>'),
      dashboard.button('s', '󱎫  Startup time', ':StartupTime<CR>'),
      dashboard.button('l', '󰒲 ' .. ' Lazy', ':Lazy<CR>'),
      dashboard.button('q', '  Quit Neovim', ':qa<CR>'),
    }
    -- local fortune = require("alpha.fortune")
    -- dashboard.section.footer.val = fortune()
    dashboard.section.footer.opts.hl = 'Type'
    dashboard.section.header.opts.hl = 'Include'
    dashboard.section.buttons.opts.hl = 'Keyword'
    dashboard.opts.opts.noautocmd = true

    -- -- close Lazy and re-open when the dashboard is ready
    -- if vim.o.filetype == "lazy" then
    --   vim.cmd.close()
    --   vim.api.nvim_create_autocmd("User", {
    --     pattern = "AlphaReady",
    --     callback = function()
    --       require("lazy").show()
    --     end,
    --   })
    -- end

    require('alpha').setup(dashboard.opts)

    vim.api.nvim_create_autocmd('User', {
      pattern = 'LazyVimStarted',
      callback = function()
        local stats = require('lazy').stats()
        local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
        dashboard.section.footer.val = '⚡ Neovim loaded ' .. stats.count .. ' plugins in ' .. ms .. 'ms'
        pcall(vim.cmd.AlphaRedraw)
      end,
    })
  end,
}
