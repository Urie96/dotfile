Config.now_if_args(function()
  local ts_update = function() vim.cmd 'TSUpdate' end
  Config.on_packchanged('nvim-treesitter', { 'update' }, ts_update, ':TSUpdate')
  vim.pack.add {
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects', version = 'main' },
    'https://github.com/nvim-treesitter/nvim-treesitter-context',
  }
--stylua: ignore
  local ensure_languages = {
    'bash',      'c',               'cmake',  'cpp',    'css',    'csv',    'diff', 'dockerfile', 'fish',
    'gitcommit', 'go',              'gomod',  'gosum',  'gotmpl', 'gowork', 'html', 'http',
    'ini',       'javascript',      'jq',     'jsdoc',  'json',   'json5',  'just', 'lua',        'luadoc', 'luap',
    'markdown',  'markdown_inline', 'ninja',  'nix',    'proto',  'python',
    'rust',      'sql',             'thrift', 'toml',
    'tsx',       'typescript',      'vim',    'vimdoc', 'vue',    'xml',    'yaml'
  }
  local treesitter = require 'nvim-treesitter'
  local treesitter_context = require 'treesitter-context'
  local treesitter_move = require 'nvim-treesitter-textobjects.move'
  local ts = require 'nvim-treesitter-textobjects'

  treesitter.install(ensure_languages)
  ts.setup {}
  treesitter_context.setup {
    enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
    max_lines = 3, -- How many lines the window should span. Values <= 0 mean no limit.
    mode = 'cursor', -- Line used to calculate context. Choices: 'cursor', 'topline'
  }

  ---@param buf integer
  ---@param language string
  local function treesitter_try_attach(buf, language)
    -- Check if a parser exists and load it
    if not vim.treesitter.language.add(language) then return end
    -- Enable syntax highlighting and other treesitter features
    vim.treesitter.start(buf, language)

    -- Check if treesitter indentation is available for this language, and if so enable it
    -- in case there is no indent query, the indentexpr will fallback to the vim's built in one
    if vim.treesitter.query.get(language, 'indents') ~= nil then
      vim.bo.indentexpr = 'v:lua.vim.treesitter.foldexpr()'
      vim.wo.foldmethod = 'expr'
    end
  end

  local available_parsers = treesitter.get_available()
  vim.api.nvim_create_autocmd('FileType', {
    callback = function(args)
      local buf, filetype = args.buf, args.match

      local language = vim.treesitter.language.get_lang(filetype)
      if not language then return end

      local installed_parsers = treesitter.get_installed 'parsers'

      if vim.tbl_contains(installed_parsers, language) then
        -- Enable the parser if it is already installed
        treesitter_try_attach(buf, language)
      elseif vim.tbl_contains(available_parsers, language) then
        -- If a parser is available in `nvim-treesitter`, auto-install it and enable it after the installation is done
        treesitter.install(language):await(function() treesitter_try_attach(buf, language) end)
      else
        -- Try to enable treesitter features in case the parser exists but is not available from `nvim-treesitter`
        treesitter_try_attach(buf, language)
      end
    end,
  })

  vim.keymap.set(
    'n',
    'ju',
    function() treesitter_context.go_to_context(vim.v.count1) end,
    { desc = 'Open yazi at the current file' }
  )

  local moves = {
    goto_next_start = { ['lf'] = '@function.outer', ['la'] = '@parameter.inner' },
    goto_next_end = { ['lF'] = '@function.outer', ['lA'] = '@parameter.inner' },
    goto_previous_start = { ['jf'] = '@function.outer', ['ja'] = '@parameter.inner' },
    goto_previous_end = { ['jF'] = '@function.outer', ['jA'] = '@parameter.inner' },
  }
  for method, keymaps in pairs(moves) do
    for key, query in pairs(keymaps) do
      vim.keymap.set({ 'n', 'x', 'o' }, key, function() treesitter_move[method](query, 'textobjects') end)
    end
  end
end)
