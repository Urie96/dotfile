local map = Config.set_keymap

Config.on_cmd({ 'WhichKey' }, function()
  vim.pack.add { 'https://github.com/folke/which-key.nvim' }
  require('which-key').setup {}
end)

Config.on_keys({ '<leader>sr' }, function()
  vim.pack.add { 'https://github.com/MagicDuck/grug-far.nvim' }

  local grug = require 'grug-far'
  grug.setup {
    minSearchChars = 1,
    normalModeSearch = true,
    resultsHighlight = false,
    inputsHighlight = false,
    keymaps = {
      help = { n = '?' },
      historyOpen = { n = '<c-o>' },
    },
    resultLocation = {
      showNumberLabel = false,
    },
  }

  map {
    '<leader>sr',
    function()
      local ext = vim.bo.buftype == '' and vim.fn.expand '%:e'
      grug.open {
        transient = true,
        prefills = {
          filesFilter = ext and ext ~= '' and '*.' .. ext or nil,
          paths = vim.fn.expand '%',
        },
      }
    end,
    desc = 'Search and Replace',
  }
end)

Config.on_keys({ '<leader>sr' }, { 'x' }, function()
  vim.pack.add { 'https://github.com/chrisgrieser/nvim-rip-substitute' }
  local rip = require 'rip-substitute'
  map { '<leader>sr', function() rip.sub() end, mode = { 'x' }, desc = ' rip substitute' }
end)

Config.on_keys({ '<leader>gh', '<leader>gd', '<leader>cr' }, function()
  vim.pack.add { 'https://github.com/sindrets/diffview.nvim' }
  require('diffview').setup {}

  map { '<leader>gh', '<cmd>DiffviewFileHistory<cr>', desc = 'Repo history' }
  map { '<leader>gd', '<cmd>DiffviewOpen<cr>', desc = 'Repo diff' }
  map { '<leader>cr', '<cmd>DiffviewOpen origin/HEAD<cr>', desc = 'Code review' }
end)
