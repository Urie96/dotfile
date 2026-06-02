---@diagnostic disable: missing-fields

Config.now(function()
  vim.pack.add { 'https://github.com/folke/tokyonight.nvim' }
  require('tokyonight').setup {
    style = 'night',
    on_colors = function(colors)
      colors.border = '#565f89' -- make windows gap noticeable
    end,
  }

  vim.cmd.colorscheme 'tokyonight-night'
end)

Config.now(function() require('mini.statusline').setup() end)

-- Config.later(function()
--   vim.pack.add { 'https://github.com/nvim-lualine/lualine.nvim' }
--
--   local lualine = require 'lualine'
--
--   local rec_msg = '' -- TODO: wait PR merged: https://github.com/nvim-lualine/lualine.nvim/pull/1227
--   vim.api.nvim_create_autocmd({ 'RecordingEnter', 'RecordingLeave' }, {
--     group = vim.api.nvim_create_augroup('LualineRecordingSection', { clear = true }),
--     callback = function(e)
--       if e.event == 'RecordingLeave' then
--         rec_msg = ''
--       else
--         rec_msg = 'Recording @' .. vim.fn.reg_recording()
--       end
--       lualine.refresh()
--     end,
--   })
--
--   lualine.setup {
--     sections = {
--       lualine_c = {
--         { 'filename', path = 1 },
--         {
--           function() return rec_msg end,
--           color = { fg = '#ff9e64' },
--         },
--       },
--     },
--   }
-- end)

Config.on_filetype('markdown', function()
  vim.pack.add { 'https://github.com/MeanderingProgrammer/render-markdown.nvim' }
  require('render-markdown').setup {}
end)

Config.later(function()
  vim.pack.add { 'https://github.com/folke/noice.nvim', 'https://github.com/MunifTanjim/nui.nvim' }
  require('noice').setup {}
  vim.keymap.set('n', '<PageDown>', function()
    if not require('noice.lsp').scroll(6) then return '<c-d>' end
  end, { silent = true, expr = true, desc = 'Scroll Forward' })
  vim.keymap.set('n', '<PageUp>', function()
    if not require('noice.lsp').scroll(-6) then return '<c-u>' end
  end, { silent = true, expr = true, desc = 'Scroll Backward' })
end)
