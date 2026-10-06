local function notify_rpc_clients(event, payload)
  for _, channel in ipairs(vim.api.nvim_list_chans()) do
    if channel.mode == "rpc" then
      pcall(vim.rpcnotify, channel.id, event, payload)
    end
  end
end
