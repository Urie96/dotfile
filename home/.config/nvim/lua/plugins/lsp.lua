Config.on_filetype('lua', function()
  vim.pack.add { 'https://github.com/folke/lazydev.nvim' }

  require('lazydev').setup {
    library = {
      { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      { path = 'snacks.nvim', words = { 'Snacks' } },
    },
  }
end)

Config.on_filetype('rust', function()
  vim.g.rustaceanvim = {
    -- Plugin configuration
    tools = {},
    -- LSP configuration
    server = {
      on_attach = function(client, bufnr) vim.lsp.inlay_hint.enable(true, { bufnr = bufnr }) end,
      default_settings = {
        -- rust-analyzer language server configuration
        ['rust-analyzer'] = {
          cargo = {
            allFeatures = true,
            loadOutDirsFromCheck = true,
            buildScripts = {
              enable = true,
            },
          },
          checkOnSave = {
            enable = true,
          },
          diagnostics = {
            enable = true,
          },
          procMacro = {
            enable = true,
            ignored = {
              ['async-trait'] = { 'async_trait' },
              ['napi-derive'] = { 'napi' },
              ['async-recursion'] = { 'async_recursion' },
            },
          },
          files = {
            excludeDirs = {
              '.direnv', -- IMPORTANT: https://github.com/rust-lang/rust-analyzer/issues/12613
              '.git',
              '.github',
              '.gitlab',
              'bin',
              'node_modules',
              'target',
              'venv',
              '.venv',
            },
          },
        },
      },
    },
    -- DAP configuration
    dap = {},
  }
  vim.pack.add {
    {
      src = 'https://github.com/mrcjkb/rustaceanvim',
      version = vim.version.range '^9',
    },
  }
end)
