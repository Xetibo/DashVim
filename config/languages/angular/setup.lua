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

-- Single-ownership reconciler: runs on every attach, decides from the
-- clients actually present instead of guessing from the project root.
-- angular owns template buffers and references (it sees external .html
-- usages); typescript-tools keeps everything else. When angular failed
-- to start, typescript-tools keeps references (graceful degradation).
local dashvim_angular_group = vim.api.nvim_create_augroup("DashVimAngularLsp", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
  group = dashvim_angular_group,
  callback = function(ev)
    local buf = ev.buf
    local bufname = vim.api.nvim_buf_get_name(buf)
    local start = (bufname ~= nil and bufname ~= "") and vim.fs.dirname(bufname) or vim.fn.getcwd()
    if not DashVimAngular.is_angular(start) then
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
    if angular_client == nil then
      return
    end
    if ts_client ~= nil then
      ts_client.server_capabilities.referencesProvider = false
    end
    angular_client.server_capabilities.documentFormattingProvider = false
    angular_client.server_capabilities.documentRangeFormattingProvider = false
    angular_client.server_capabilities.documentOnTypeFormattingProvider = false
    local ft = vim.bo[buf].filetype
    if ft == "typescript" or ft == "typescriptreact" then
      angular_client.server_capabilities.completionProvider = false
      angular_client.server_capabilities.hoverProvider = false
      angular_client.server_capabilities.signatureHelpProvider = false
      angular_client.server_capabilities.definitionProvider = false
      angular_client.server_capabilities.codeActionProvider = false
      angular_client.server_capabilities.documentSymbolProvider = false
      angular_client.server_capabilities.diagnosticProvider = false
      angular_client.server_capabilities.inlayHintProvider = false
    elseif ft == "html" or ft == "htmlangular" then
      -- Only the vanilla html LSP conflicts here; other companions
      -- (e.g. tailwind) keep their providers.
      for _, other in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
        if other.id ~= angular_client.id and other.name == "html" then
          other.server_capabilities.completionProvider = false
          other.server_capabilities.hoverProvider = false
          other.server_capabilities.signatureHelpProvider = false
          other.server_capabilities.definitionProvider = false
          other.server_capabilities.referencesProvider = false
          other.server_capabilities.documentSymbolProvider = false
          other.server_capabilities.codeActionProvider = false
          other.server_capabilities.diagnosticProvider = false
        end
      end
    end
  end,
})
