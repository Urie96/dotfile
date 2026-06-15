vim.bo.commentstring = '# %s'

vim.keymap.set('n', '<CR>', function()
  require('util.rpc_runner').run_current()
end, { buffer = true, silent = true, desc = 'Run current RPC request' })

vim.api.nvim_buf_create_user_command(0, 'RpcRun', function()
  require('util.rpc_runner').run_current()
end, { desc = 'Run current RPC request' })
