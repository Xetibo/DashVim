-- DashVimAngular runtime: root detection, --angularCoreVersion resolution,
-- race-free htmlangular filetype detection, and the LspAttach reconciler.
-- _G.DashVimAngular itself (root_markers + .nix store paths) is set by the nix
-- prelude in angular.nix before this file loads.

function DashVimAngular.find_root(startpath)
  local found = vim.fs.find(DashVimAngular.root_markers, {
    path = startpath,
    upward = true,
  })[1]
  if found == nil then
    return nil
  end
  return vim.fs.dirname(found)
end

function DashVimAngular.is_angular(startpath)
  return DashVimAngular.find_root(startpath) ~= nil
end

local function package_version_major(package_json)
  local ok, lines = pcall(vim.fn.readfile, package_json)
  if not ok then
    return nil
  end
  local version = table.concat(lines, "\n"):match('"version"%s*:%s*"([^"]+)')
  if version == nil then
    return nil
  end
  return version:match("(%d+)")
end

-- Major of @angular/core for --angularCoreVersion. Prefers the installed
-- package (exact version) over the declared range ("^19.0.0" -> "19").
-- Returns nil when unknown so the caller omits the flag entirely.
function DashVimAngular.core_major(root_dir)
  local installed = vim.fs.find("node_modules/@angular/core/package.json", {
    path = root_dir,
    upward = true,
  })[1]
  if installed ~= nil then
    local major = package_version_major(installed)
    if major ~= nil then
      return major
    end
  end
  local manifest = vim.fs.find("package.json", {
    path = root_dir,
    upward = true,
  })[1]
  if manifest == nil then
    return nil
  end
  local ok, lines = pcall(vim.fn.readfile, manifest)
  if not ok then
    return nil
  end
  local parsed_ok, pkg = pcall(vim.json.decode, table.concat(lines, "\n"))
  if not parsed_ok or type(pkg) ~= "table" then
    return nil
  end
  local range = ((pkg.dependencies or {})["@angular/core"] or (pkg.devDependencies or {})["@angular/core"] or "")
  return range:match("(%d+)")
end

-- Race-free filetype detection: runs during BufRead, from the file's own
-- directory upward, before any LSP attaches. Returning nil falls through
-- to the default "html" detection.
vim.filetype.add({
  pattern = {
    [".*%.html"] = function(path, _)
      if type(path) ~= "string" or path == "" then
        return nil
      end
      local dir = vim.fs.dirname(path)
      if dir == nil or not DashVimAngular.is_angular(dir) then
        return nil
      end
      return "htmlangular"
    end,
  },
})

-- Single-ownership reconciler: server_capabilities is per-client (global),
-- not per-buffer, so ownership must follow the *current* buffer — every LSP
-- request originates there. apply() neuters or restores providers for the
-- given buffer and runs on LspAttach (clients changed) and BufEnter (buffer
-- changed; e.g. TS attach must not keep angular neutered after switching
-- back to a template). angular owns template buffers and references (it sees
-- external .html usages); typescript-tools keeps everything else. When angular
-- failed to start, typescript-tools keeps references (graceful degradation).
-- Outside Angular projects everything is restored to server defaults.
local dashvim_angular_group = vim.api.nvim_create_augroup("DashVimAngularLsp", { clear = true })

local managed_keys = {
  "documentFormattingProvider",
  "documentRangeFormattingProvider",
  "documentOnTypeFormattingProvider",
  "completionProvider",
  "hoverProvider",
  "signatureHelpProvider",
  "definitionProvider",
  "referencesProvider",
  "codeActionProvider",
  "documentSymbolProvider",
  "diagnosticProvider",
  "inlayHintProvider",
}

local ts_buffer_keys = {
  "completionProvider",
  "hoverProvider",
  "signatureHelpProvider",
  "definitionProvider",
  "codeActionProvider",
  "documentSymbolProvider",
  "diagnosticProvider",
  "inlayHintProvider",
}

-- Providers must be tables or nil: completion sources (e.g. blink-cmp)
-- index completionProvider, so raw booleans crash them. Disable with nil,
-- restore from a pristine snapshot taken before the first mutation.
local snapshots = {}

local function snapshot(client)
  local s = snapshots[client.id]
  if s == nil then
    s = {}
    for _, key in ipairs(managed_keys) do
      s[key] = client.server_capabilities[key]
    end
    snapshots[client.id] = s
  end
  return s
end

local function set_enabled(client, key, enabled)
  if enabled then
    client.server_capabilities[key] = snapshot(client)[key]
  else
    snapshot(client)
    client.server_capabilities[key] = nil
  end
end

function DashVimAngular.apply(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  local angular_client = nil
  local ts_client = nil
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
    if c.name == "angular" then
      angular_client = c
    elseif c.name == "typescript-tools" then
      ts_client = c
    end
  end
  local bufname = vim.api.nvim_buf_get_name(buf)
  local start = (bufname ~= nil and bufname ~= "") and vim.fs.dirname(bufname) or vim.fn.getcwd()
  if not DashVimAngular.is_angular(start) then
    if ts_client ~= nil then
      set_enabled(ts_client, "referencesProvider", true)
    end
    if angular_client ~= nil then
      for _, key in ipairs(managed_keys) do
        set_enabled(angular_client, key, true)
      end
    end
    return
  end
  if angular_client == nil then
    return
  end
  if ts_client ~= nil then
    set_enabled(ts_client, "referencesProvider", false)
  end
  set_enabled(angular_client, "documentFormattingProvider", false)
  set_enabled(angular_client, "documentRangeFormattingProvider", false)
  set_enabled(angular_client, "documentOnTypeFormattingProvider", false)
  local ft = vim.bo[buf].filetype
  if ft == "typescript" or ft == "typescriptreact" then
    for _, key in ipairs(ts_buffer_keys) do
      set_enabled(angular_client, key, false)
    end
  elseif ft == "html" or ft == "htmlangular" then
    for _, key in ipairs(ts_buffer_keys) do
      set_enabled(angular_client, key, true)
    end
    -- Only the vanilla html LSP conflicts here; other companions
    -- (e.g. tailwind) keep their providers.
    for _, other in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
      if other.id ~= angular_client.id and other.name == "html" then
        snapshot(other)
        other.server_capabilities.completionProvider = nil
        other.server_capabilities.hoverProvider = nil
        other.server_capabilities.signatureHelpProvider = nil
        other.server_capabilities.definitionProvider = nil
        other.server_capabilities.referencesProvider = nil
        other.server_capabilities.documentSymbolProvider = nil
        other.server_capabilities.codeActionProvider = nil
        other.server_capabilities.diagnosticProvider = nil
      end
    end
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = dashvim_angular_group,
  callback = function(ev)
    DashVimAngular.apply(ev.buf)
  end,
})
vim.api.nvim_create_autocmd("BufEnter", {
  group = dashvim_angular_group,
  callback = function(ev)
    local ft = vim.bo[ev.buf].filetype
    if ft == "typescript" or ft == "typescriptreact" or ft == "html" or ft == "htmlangular" then
      DashVimAngular.apply(ev.buf)
    end
  end,
})
vim.api.nvim_create_autocmd("LspDetach", {
  group = dashvim_angular_group,
  callback = function(ev)
    snapshots[ev.data.client_id] = nil
  end,
})
