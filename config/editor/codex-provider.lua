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
  return config.model
end

function CodexProvider.fetch_models(callback)
  local models, seen = {}, {}
  local function add(model)
    if type(model) == "string" and model ~= "" and not seen[model] then
      seen[model] = true
      table.insert(models, model)
    end
  end
  add(config.model)
  for _, model in ipairs(config.models) do add(model) end
  local home = vim.env.CODEX_HOME or (vim.env.HOME .. "/.codex")
  local ok, catalog = pcall(function()
    return vim.json.decode(table.concat(vim.fn.readfile(home .. "/models_cache.json"), "\n"))
  end)
  if ok and type(catalog) == "table" and type(catalog.models) == "table" then
    for _, model in ipairs(catalog.models) do
      if type(model) == "table" and model.visibility == "list" then add(model.slug) end
    end
  end
  callback(models, nil)
end

return CodexProvider
