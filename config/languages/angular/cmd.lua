-- ngserver spawn for nvf's `vim.lsp.servers.angular.cmd`.
-- Requires _G.DashVimAngular (nix store paths under .nix, helpers in setup.lua).
-- Probe shapes mirror the nixpkgs ngserver wrapper: tsProbe entries point at the
-- typescript package dir (holds lib/tsserverlibrary.js); ngProbe entries point at
-- a node_modules dir (holds @angular/).
-- Must stay a bare function value (no `return`): nvf embeds this file in
-- expression position, anything else breaks startup with E5113.
function(dispatchers, config)
  local root_dir = (config and config.root_dir) or vim.fn.getcwd()
  local ts_probes = {}
  local ng_probes = {}
  local seen = {}

  local function add_probe(list, path)
    if path ~= nil and path ~= "" and not seen[path] and vim.uv.fs_stat(path) then
      seen[path] = true
      table.insert(list, path)
    end
  end

  local project_node_modules = vim.fs.find("node_modules", {
    path = root_dir,
    upward = true,
    type = "directory",
  })[1]

  if project_node_modules ~= nil then
    add_probe(ng_probes, project_node_modules)
    add_probe(ts_probes, project_node_modules .. "/typescript")
  end
  add_probe(ts_probes, DashVimAngular.nix.ts_probe)
  add_probe(ng_probes, DashVimAngular.nix.ng_probe)

  local args = {
    DashVimAngular.nix.ngserver,
    "--stdio",
    "--tsProbeLocations",
    table.concat(ts_probes, ","),
    "--ngProbeLocations",
    table.concat(ng_probes, ","),
  }

  -- Only pass --angularCoreVersion when the project states a major:
  -- an empty value disables ngserver's own version handling.
  local ok, major = pcall(DashVimAngular.core_major, root_dir)
  if ok and major ~= nil and major ~= "" then
    table.insert(args, "--angularCoreVersion")
    table.insert(args, major)
  end

  return vim.lsp.rpc.start(args, dispatchers)
end
