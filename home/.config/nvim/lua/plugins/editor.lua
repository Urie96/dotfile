return {
  {
    'folke/trouble.nvim',
    cmd = { 'Trouble' },
    keys = {
      { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Diagnostics (Trouble)' },
      -- { '<leader>ss', '<cmd>Trouble symbols toggle<cr>', desc = 'Symbols (Trouble)' },
      {
        'jq',
        function()
          if require('trouble').is_open() then
            require('trouble').prev { skip_groups = true, jump = true }
          else
            local ok, err = pcall(vim.cmd.cprev)
            if not ok then vim.notify(err, vim.log.levels.ERROR) end
          end
        end,
        desc = 'Previous Trouble/Quickfix Item',
      },
      {
        'lq',
        function()
          if require('trouble').is_open() then
            require('trouble').next { skip_groups = true, jump = true }
          else
            local ok, err = pcall(vim.cmd.cnext)
            if not ok then vim.notify(err, vim.log.levels.ERROR) end
          end
        end,
        desc = 'Next Trouble/Quickfix Item',
      },
    },
    config = function()
      require('trouble').setup {
        modes = {
          symbols = {
            auto_open = false,
            focus = true,
            win = { size = 50 },
            filter = function(items)
              local ft = items[1] and items[1].buf and vim.bo[items[1].buf].filetype
              if vim.tbl_contains({ 'help', 'markdown' }, ft) then return items end
              return vim.tbl_filter(function(item)
                if ft == 'help' or ft == 'markdown' then return true end
                if vim.tbl_contains({ 'go', 'lua' }, ft) then
                  return vim.tbl_contains({ 'Method', 'Function', 'Interface' }, item.kind)
                end
                -- stylua: ignore
                return vim.tbl_contains({'Class', 'Constructor', 'Enum', 'Field', 'Function', 'Interface', 'Method', 'Module', 'Namespace', 'Package', 'Property', 'Struct', 'Trait',}, item.kind)
              end, items)
            end,
          },
        },
      }
    end,
  },
  {
    'MagicDuck/grug-far.nvim',
    cmd = 'GrugFar',
    keys = {
      {
        '<leader>sr',
        function()
          local grug = require 'grug-far'
          local ext = vim.bo.buftype == '' and vim.fn.expand '%:e'
          grug.open {
            transient = true,
            prefills = {
              filesFilter = ext and ext ~= '' and '*.' .. ext or nil,
              paths = vim.fn.expand '%',
            },
          }
        end,
        mode = { 'n' },
        desc = 'Search and Replace',
      },
    },
    config = function()
      require('grug-far').setup {
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
    end,
  },
  {
    'chrisgrieser/nvim-rip-substitute',
    cmd = 'RipSubstitute',
    keys = {
      { '<leader>sr', function() require('rip-substitute').sub() end, mode = { 'x' }, desc = ' rip substitute' },
    },
    config = function() require('rip-substitute').setup {} end,
  },
  {
    'lambdalisue/suda.vim',
    cmd = 'SudaWrite',
    config = false,
  },
  {
    'nvim-mini/mini.diff',
    event = 'VeryLazy',
    keys = {
      {
        '<leader>go',
        function() require('mini.diff').toggle_overlay(0) end,
        desc = 'Toggle mini.diff overlay',
      },
    },
    opts = {
      view = {
        style = 'sign',
        signs = {
          add = '▎',
          change = '▎',
          delete = '',
        },
      },
    },
  },
  {
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
    keys = {
      { '<leader>gh', '<cmd>DiffviewFileHistory<cr>', { desc = 'Repo history' } },
      { '<leader>gd', '<cmd>DiffviewOpen<cr>', { desc = 'Repo diff' } },
      { '<leader>cr', '<cmd>DiffviewOpen origin/HEAD<cr>', { desc = 'Code review' } },
    },
    config = function()
      require('diffview').setup {
        hooks = {
          -- diff_buf_read = function(bufnr) vim.opt_local.foldenable = false end, -- disable folding
        },
      }
    end,
  },
  {
    'folke/todo-comments.nvim',
    cmd = { 'TodoTrouble', 'TodoTelescope' },
    event = 'BufReadPost',
    keys = {
      { 'lt', function() require('todo-comments').jump_next() end, desc = 'Next Todo Comment' },
      { 'jt', function() require('todo-comments').jump_prev() end, desc = 'Previous Todo Comment' },
    },
    config = function() require('todo-comments').setup {} end,
  },
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'fredrikaverpil/neotest-golang',
    },
    keys = {
      { '<leader>tr', function() require('neotest').run.run() end, desc = 'Run Nearest (Neotest)' },
      {
        '<leader>to',
        function() require('neotest').output.open { enter = true, auto_close = true } end,
        desc = 'Show Output (Neotest)',
      },
      { '<leader>tO', function() require('neotest').output_panel.toggle() end, desc = 'Toggle Output Panel (Neotest)' },
    },
    config = function()
      local neotest_ns = vim.api.nvim_create_namespace 'neotest'
      vim.diagnostic.config({
        virtual_text = {
          format = function(diagnostic)
            -- Replace newline and tab characters with space for more compact diagnostics
            local message = diagnostic.message:gsub('\n', ' '):gsub('\t', ' '):gsub('%s+', ' '):gsub('^%s+', '')
            return message
          end,
        },
      }, neotest_ns)

      ---@diagnostic disable-next-line: missing-fields
      require('neotest').setup {
        adapters = {
          require 'neotest-golang',
        },
      }
    end,
  },
  {
    'nanotee/sqls.nvim',
    ft = { 'sql', 'mysql' },
    config = function()
      vim.lsp.config('sqls', {
        settings = {
          sqls = {
            connections = {
              -- {
              --   driver = 'sqlite3',
              --   dataSourceName = 'file:/Users/bytedance/.local/share/newsboat/cache.db',
              -- },
            },
          },
        },
      })
      vim.lsp.enable 'sqls'
    end,
  },
}
