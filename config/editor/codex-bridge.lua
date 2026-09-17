local M = {}
local socket

local function server_config()
  if not socket then
    local address = vim.fn.tempname() .. ".sock"
    socket = vim.fn.serverstart(address)
    vim.api.nvim_create_autocmd("VimLeavePre", {
      once = true,
      callback = function()
        vim.fn.serverstop(socket)
      end,
    })
  end

  return {
    command = require("dashvim.codex-bridge-config").command,
    args = { "--connect", socket, "--always-expose-connection-tools" },
    enabled = true,
    required = true,
    disabled_tools = { "lsp_formatting", "lsp_range_formatting", "lsp_organize_imports" },
  }
end

function M.env(base)
  local config = vim.deepcopy(base)
  config.mcp_servers = config.mcp_servers or {}
  config.mcp_servers.neovim = server_config()
  return { CODEX_CONFIG = vim.json.encode(config) }
end

function M.args(base)
  local args = vim.deepcopy(base)
  local settings = server_config()
  for _, key in ipairs({ "command", "args", "enabled", "required", "disabled_tools" }) do
    vim.list_extend(args, { "-c", "mcp_servers.neovim." .. key .. "=" .. vim.json.encode(settings[key]) })
  end
  return args
end

return M
