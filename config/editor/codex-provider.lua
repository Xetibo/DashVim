local BaseProvider = require("99.providers").BaseProvider
local config = require("99.codex-config")

local CodexProvider = setmetatable({}, { __index = BaseProvider })

function CodexProvider._build_command(_, query, context)
  local command = {
    config.command,
    "exec",
    "--model",
    context.model,
    "--output-last-message",
    context.tmp_file,
  }
  vim.list_extend(command, require("dashvim.codex-bridge").args(config.args))
  table.insert(command, query)
  return command
end

function CodexProvider._get_provider_name()
  return "CodexProvider"
end

function CodexProvider._get_default_model()
  return "gpt-5.3-codex"
end

function CodexProvider.fetch_models(callback)
  callback({ CodexProvider._get_default_model() }, nil)
end

return CodexProvider
