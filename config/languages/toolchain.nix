{
  config',
  lib,
  pkgs,
  ...
}: let
  toolchain = import ../../lib/toolchain.nix {inherit lib pkgs;};

  languageConfig = language:
    lib.recursiveUpdate
    (config'.lsp.lspServers.${language} or {})
    (config'.lsp.additionalConfig.${language} or {});

  lspServers = lib.mapAttrs (_: serverConfig: serverConfig // {enable = lib.mkDefault false;}) toolchain.lspServers;

  rustCfg = languageConfig "rust";
  rustLspEnabled = (rustCfg.enable or false) && ((rustCfg.lsp or {}).enable or true);

  # nvf no longer exposes `vim.languages.rust.lsp.package`; rust-analyzer is
  # configured through the generic `vim.lsp.servers.rust-analyzer` option.
  # Override its command with the project-aware resolver at the same priority
  # used for the other toolchain LSPs.
  rustAnalyzerServer = lib.optionalAttrs rustLspEnabled {
    rust-analyzer = {
      cmd = lib.mkOverride toolchain.overridePriority [(toolchain.bin "rust-analyzer")];
    };
  };
in
  lib.mkIf (config'.toolchain.preferProjectTools or false) {
    vim = {
      lsp.servers = lspServers // rustAnalyzerServer;

      formatter.conform-nvim.setupOpts.formatters = toolchain.formatters;

      diagnostics.nvim-lint.linters = toolchain.linters;
      luaConfigRC.dashvim-project-roslyn = lib.nvim.dag.entryBefore ["lsp-servers"] ''
        vim.lsp.config["roslyn"] = {
        cmd = ${lib.nvim.lua.toLuaObject [(toolchain.bin "roslyn-ls") "--stdio"]},
        }
      '';
    };
  }
