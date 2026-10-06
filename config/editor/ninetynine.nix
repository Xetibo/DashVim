{
  config',
  pkgs,
  mkDashDefault,
  lib,
  ...
}: let
  cfg = config'.agent.ninetyNine;
  codexEditor = import ../../lib/codex-editor.nix {
    inherit lib;
    inherit (config'.agent.codex) reasoningEffort;
  };

  nineNine = pkgs.vimUtils.buildVimPlugin {
    pname = "99";
    version = "2026-09-09";

    src = pkgs.fetchFromGitHub {
      owner = "ThePrimeagen";
      repo = "99";
      rev = "c17422457027c913c76c75a921fca1e623d2678e";
      hash = "sha256-iilpiG81kHIv7Y0qvPzZOanNA0lsPotlB18cvtmTy0o=";
    };
    # Upstream lua/99/editor/lsp.lua requires 99.editor.treesitter, which does
    # not exist in the repo, so nixpkgs' neovim require-check fails. Skip it.
    doCheck = false;
    postInstall = ''
      cp ${./codex-provider.lua} $out/lua/99/codex-provider.lua
      cat > $out/lua/99/codex-config.lua <<'EOF'
      return vim.json.decode([==[${builtins.toJSON {
        command = "${pkgs.codex}/bin/codex";
        args = codexEditor.args.ninetyNine;
        inherit (config'.agent.codex) model models;
      }}]==])
      EOF
    '';
  };

  levelMap = {
    debug = "DEBUG";
    info = "INFO";
    warn = "WARN";
    error = "ERROR";
    fatal = "FATAL";
  };
in
  lib.mkIf (config'.agent.enable && cfg.enable) {
    vim = {
      lazy.plugins = {
        "99" = mkDashDefault {
          package = nineNine;
          setupModule = "99";
          setupOpts =
            {
              # provider is a Lua table (require("99").Providers.X), not a string.
              provider = lib.mkLuaInline ''
                (function()
                  local providers = require("99").Providers
                  providers.CodexProvider = require("99.codex-provider")
                  return providers.${cfg.provider}
                end)()
              '';
              model =
                if cfg.model != null
                then cfg.model
                else if cfg.provider == "OpenCodeProvider"
                then "opencode/big-pickle"
                else null;
              provider_extra_args = cfg.providerExtraArgs;
              tmp_dir = cfg.tmpDir;
              md_files = cfg.mdFiles;
              display_errors = cfg.displayErrors;
              auto_add_skills = cfg.autoAddSkills;
              logger = {
                level = lib.mkLuaInline ''require("99").${levelMap.${cfg.logger.level}}'';
                type = cfg.logger.type;
                path =
                  if cfg.logger.path != null
                  then cfg.logger.path
                  else lib.mkLuaInline ''"/tmp/" .. vim.fs.basename(vim.uv.cwd()) .. ".99.debug"'';
                print_on_error = cfg.logger.printOnError;
                max_requests_cached = cfg.logger.maxRequestsCached;
              };
              completion = {
                # upstream nil means native; pass null through for the same effect.
                source =
                  if cfg.completion.source == "native"
                  then null
                  else cfg.completion.source;
                custom_rules = cfg.completion.customRules;
                files = {
                  enabled = cfg.completion.files.enabled;
                  max_file_size = cfg.completion.files.maxFileSize;
                  max_files = cfg.completion.files.maxFiles;
                  exclude = cfg.completion.files.exclude;
                };
              };
              in_flight_options =
                {
                  enable = cfg.inFlight.enable;
                  in_flight_interval = cfg.inFlight.interval;
                }
                // lib.optionalAttrs (cfg.inFlight.throbber != {}) {
                  throbber_opts = cfg.inFlight.throbber;
                };
            }
            // cfg.extraConfig;
        };
      };
    };
  }
