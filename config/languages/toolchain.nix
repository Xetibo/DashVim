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
in
  lib.mkIf (config'.toolchain.preferProjectTools or false) {
    vim =
      {
        lsp.servers = lspServers;

        formatter.conform-nvim.setupOpts.formatters = toolchain.formatters;

        diagnostics.nvim-lint.linters = toolchain.linters;
        luaConfigRC.dashvim-project-roslyn = lib.nvim.dag.entryBefore ["lsp-servers"] ''
          vim.lsp.config["roslyn"] = {
          cmd = ${lib.nvim.lua.toLuaObject [(toolchain.bin "roslyn-ls") "--stdio"]},
          }
        '';
      }
      // lib.optionalAttrs rustLspEnabled {
        languages.rust.lsp.package = lib.mkOverride toolchain.overridePriority [(toolchain.bin "rust-analyzer")];
      };
  }
