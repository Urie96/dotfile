Config.on_event('InsertEnter', function()
  vim.pack.add {
    -- { src = 'https://github.com/saghen/blink.lib', version = vim.version.range '1.*' },
    { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range '*' },
  }
  local cmp = require 'blink.cmp'

  local snippets_dir = { vim.fn.stdpath 'config' .. '/snippets' }
  local cwd = vim.uv.cwd() or vim.env.PWD
  local vscode_dir = cwd ~= vim.env.HOME
    and vim.fs.find('.vscode', { upward = true, stop = vim.env.HOME, limit = 1, path = cwd })
  if vscode_dir and #vscode_dir > 0 then
    vim.notify(string.format("Snippets in '%s' will be loaded", vscode_dir[1]))
    table.insert(snippets_dir, 1, vscode_dir[1])
  end

  cmp.setup {
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
      providers = {
        snippets = { opts = { search_paths = snippets_dir } },
        lsp = {
          transform_items = function(ctx, items)
            local item_kind = require('blink.cmp.types').CompletionItemKind
            local ft = vim.bo[ctx.bufnr].filetype

            local out = vim.tbl_filter(function(item)
              if item.kind == item_kind.Text then return false end
              if ft == 'go' and item.kind == item_kind.Snippet then return false end
              return true
            end, items)

            for _, item in ipairs(out) do
              if item.kind == item_kind.Snippet then
                item.score_offset = item.score_offset - 3 -- demote
              elseif ft == 'go' and (item.kind == item_kind.Module or item.kind == item_kind.Keyword) then
                item.score_offset = item.score_offset - 3
              end
            end
            return out
          end,
        },
        lazydev = {
          name = 'LazyDev',
          module = 'lazydev.integrations.blink',
          score_offset = 100, -- show at a higher priority than lsp
        },
      },
      per_filetype = { lua = { inherit_defaults = true, 'lazydev' } },
    },
    keymap = {
      preset = 'none',
      ['<Tab>'] = {
        'select_and_accept',
        function(cmp)
          local col = vim.api.nvim_win_get_cursor(0)[2]
          if vim.api.nvim_get_current_line():sub(1, col):match '^%s*$' == nil then return cmp.show() end
        end,
        'fallback',
      },
      ['<Up>'] = { 'select_prev', 'fallback' },
      ['<Down>'] = { 'select_next', 'fallback' },
      ['<PageUp>'] = { 'scroll_documentation_up', 'fallback' },
      ['<PageDown>'] = { 'scroll_documentation_down', 'fallback' },
      ['<C-l>'] = { 'snippet_forward', 'fallback' },
      ['<C-j>'] = { 'snippet_backward', 'fallback' },
    },
    completion = {
      keyword = { range = 'prefix' },
      menu = { draw = { treesitter = { 'lsp' } } },
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
    },
    cmdline = {
      keymap = {
        preset = 'none',
        ['<Tab>'] = { 'select_and_accept', 'fallback' },
        ['<Up>'] = { 'select_prev', 'fallback' },
        ['<Down>'] = { 'select_next', 'fallback' },
      },
      completion = {
        menu = { auto_show = function(ctx) return vim.fn.getcmdtype() == ':' end },
      },
    },
  }
end)

Config.on_keys({ 's' }, { 'n', 'x', 'o' }, function()
  vim.pack.add { 'https://github.com/folke/flash.nvim' }

  require('flash').setup {
    modes = {
      char = {
        highlight = { backdrop = false },
        multi_line = false,
      },
    },
  }
  vim.keymap.set({ 'n', 'x', 'o' }, 's', function() require('flash').jump() end)
end)

Config.on_keys({ '<leader>cg' }, function()
  vim.pack.add { 'https://github.com/danymat/neogen' }

  local neogen = require 'neogen'
  neogen.setup { snippet_engine = 'nvim' }
  vim.keymap.set('n', '<leader>cg', function() neogen.generate() end, { desc = 'Generate Annotations (Neogen)' })
end)
