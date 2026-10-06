local M = {}
local socket
local read_tools = {
  "editor_context", "read_buffers", "find_files",
  "list_buffers", "buffer_diagnostics", "lsp_clients",
  "lsp_definition", "lsp_references", "lsp_hover", "lsp_document_symbols", "lsp_workspace_symbols",
}

local function server_config()
  if not socket then
    local address = vim.fn.tempname() .. ".sock"
    require("nvim-mcp").setup({ pipe = address, custom_tools = require("dashvim.codex-tools").tools() })
    socket = address
    vim.api.nvim_create_autocmd("VimLeavePre", {
      once = true,
      callback = function()
        vim.fn.serverstop(socket)
      end,
    })
  end

  local tools = {}
  for _, name in ipairs(read_tools) do
    tools[name] = { approval_mode = "approve" }
  end
  return {
    command = require("dashvim.codex-bridge-config").command,
    args = { "--connect", socket, "--always-expose-connection-tools" },
    enabled = true,
    required = true,
    disabled_tools = { "lsp_formatting", "lsp_range_formatting", "lsp_organize_imports" },
    enabled_tools = vim.list_extend(vim.deepcopy(read_tools), { "edit_buffer" }),
    default_tools_approval_mode = "auto",
    tools = tools,
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
  local function toml(value)
    if type(value) ~= "table" then return vim.json.encode(value) end
    local parts = {}
    if vim.islist(value) then
      for _, item in ipairs(value) do table.insert(parts, toml(item)) end
      return "[" .. table.concat(parts, ",") .. "]"
    end
    for _, key in ipairs(vim.fn.sort(vim.tbl_keys(value))) do
      table.insert(parts, vim.json.encode(key) .. "=" .. toml(value[key]))
    end
    return "{" .. table.concat(parts, ",") .. "}"
  end
  for _, key in ipairs({ "command", "args", "enabled", "required", "enabled_tools", "disabled_tools", "default_tools_approval_mode", "tools" }) do
    vim.list_extend(args, { "-c", "mcp_servers.neovim." .. key .. "=" .. toml(settings[key]) })
  end
  return args
end

return M
