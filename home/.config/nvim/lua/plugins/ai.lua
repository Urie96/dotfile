local start_pos = string.find(vim.uv.cwd() or '', '/work/')
local use_work_ai = start_pos ~= nil and os.getenv 'WORK_ENV'

if not use_work_ai then
  Config.on_event('InsertEnter', function()
    vim.pack.add { 'https://github.com/Exafunction/windsurf.nvim' }

    local windsurf = require 'codeium'
    local windsurf_config = require 'codeium.config'
    local allow_ft =
      vim.split('sh,go,rust,python,lua,nix,java,c,cpp,javascript,typescript,json,yaml,toml,sql,html,css,markdown', ',')
    local ft_table = {}
    for _, ft in ipairs(allow_ft) do
      ft_table[ft] = true
    end

    Snacks.toggle({
      name = 'AI',
      get = function() return windsurf_config.options.virtual_text.manual ~= true end,
      set = function(state)
        if state then
          windsurf_config.options.virtual_text.manual = false
        else
          windsurf_config.options.virtual_text.manual = true
        end
      end,
    }):map '<leader>uA'

    windsurf.setup {
      enable_cmp_source = false,
      virtual_text = {
        enabled = true,
        filetypes = ft_table,
        default_filetype_enabled = false,
        key_bindings = {
          accept = '<C-Tab>',
          next = '<C-l>',
          prev = '<C-j>',
        },
      },
    }
    -- vim.defer_fn(function() vim.cmd.colorscheme 'tokyonight' end, 100) -- 不然virtualtext是白色的
  end)
else
  Config.on_event('InsertEnter', function()
    vim.g.marscode_no_map_tab = true
    vim.g.marscode_disable_bindings = true

    vim.pack.add { 'https://code.byted.org/chenjiaqi.cposture/codeverse.vim.git' }

    vim.cmd 'inoremap <script><silent><nowait><expr> <C-Tab> trae#Accept()'
    vim.cmd 'imap <C-Enter> <Plug>(marscode-next-or-complete)'
    vim.defer_fn(function() vim.cmd.colorscheme 'tokyonight' end, 100) -- 不然virtualtext是白色的
  end)
end
