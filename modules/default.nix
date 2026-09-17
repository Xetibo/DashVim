{lib, ...}: {
  options.programs.dashvim = {
    colorscheme = lib.mkOption {
      # catppuccin
      default = {
        base00 = "1e1e2e"; # base
        base01 = "181825"; # mantle
        base02 = "313244"; # surface0
        base03 = "45475a"; # surface1
        base04 = "585b70"; # surface2
        base05 = "cdd6f4"; # text
        base06 = "f5e0dc"; # rosewater
        base07 = "b4befe"; # lavender
        base08 = "f38ba8"; # red
        base09 = "fab387"; # peach
        base0A = "f9e2af"; # yellow
        base0B = "a6e3a1"; # green
        base0C = "94e2d5"; # teal
        base0D = "89b4fa"; # blue
        base0E = "cba6f7"; # mauve
        base0F = "f2cdcd"; # flamingo
      };
      example = {
        # custom tokyo night
        base00 = "1A1B26";
        base01 = "191a25";
        base02 = "2F3549";
        base03 = "444B6A";
        base04 = "787C99";
        base05 = "A9B1D6";
        base06 = "CBCCD1";
        base07 = "D5D6DB";
        base08 = "C0CAF5";
        base09 = "A9B1D7";
        base0A = "0DB9D7";
        base0B = "9ECE6A";
        base0C = "B4F9F8";
        base0D = "366fea";
        base0E = "BB9AF7";
        base0F = "F7768E";
      };
      type = with lib.types;
        oneOf [
          str
          attrs
          path
        ];
      description = ''
        Base16 colorscheme.
        Can be an attribute set with base00 to base0F,
        a string that leads to a yaml file in base16-schemes path,
        or a path to a custom yaml file.
      '';
    };
    accentColor = lib.mkOption {
      default = null;
      example = "F7768E";
      type = with lib.types; nullOr str;
      description = ''
        Overrides base0D as it is most widely used as primary color.
      '';
    };

    enableNvfDefaultKeybinds = lib.mkOption {
      default = false;
      example = true;
      type = lib.types.bool;
      description = ''
        Nvf has a ton of default keybinds, this options re-enables them.
      '';
    };

    useDefaultKeybinds = lib.mkOption {
      default = true;
      example = false;
      type = lib.types.bool;
      description = ''
        Enables the default keybinds for DashVim.
        Keep in mind that regular keymaps from plugin defaults and Neovim are still active.
      '';
    };

    dashboardAscii = lib.mkOption {
      default = [
        " _______       ___           _______. __    __   __   _______ "
        "|       \\     /   \\         /       ||  |  |  | |  | |   ____|"
        "|  .--.  |   /  ^  \\       |   (----`|  |__|  | |  | |  |__   "
        "|  |  |  |  /  /_\\  \\       \\   \\    |   __   | |  | |   __|  "
        "|  '--'  | /  _____  \\  .----)   |   |  |  |  | |  | |  |____ "
        "|_______/ /__/     \\__\\ |_______/    |__|  |__| |__| |_______|"
        "                                                               "
      ];
      example = ["yourpicture"];
      type = with lib.types; listOf str;
      description = ''
        The Ascii picture for dashboard.nvim.
      '';
    };

    useDefaultCmpConfig = lib.mkOption {
      default = true;
      example = false;
      type = lib.types.bool;
      description = ''
        Enables default cmp config
      '';
    };

    instantUsername = lib.mkOption {
      default = "DashVim";
      example = "yourUserName";
      type = lib.types.str;
      description = ''
        Username for instant.nvim
      '';
    };

    opencode = {
      enable = lib.mkOption {
        default = true;
        example = false;
        type = lib.types.bool;
        description = ''
          Enables opencode integration including the opencode-nvim plugin,
          the opencode binary, theme syncing, and config deployment.
        '';
      };
      theme = lib.mkOption {
        default = "dashvim";
        example = "catppuccin";
        type = lib.types.str;
        description = ''
          The opencode theme name. By default uses "dashvim" which is
          auto-generated from your base16/base24 colorscheme.
        '';
      };
      config = lib.mkOption {
        default = {};
        example = {
          permission = "ask";
          autoupdate = false;
        };
        type = with lib.types; attrsOf anything;
        description = ''
          Additional opencode.json configuration to merge.
        '';
      };
      plugin = lib.mkOption {
        default = [
          "@slkiser/opencode-quota"
          # TODO beforepr
          # configure before continuing to use this
          # "oh-my-openagent"
          "@tarquinen/opencode-dcp@latest"
        ];
        example = ["opencode-helicone-session"];
        type = with lib.types; listOf str;
        description = ''
          List of opencode plugins to enable (npm package names).
        '';
      };

      tuiPlugin = lib.mkOption {
        default = [];
        # TODO beforepr
        # configure before continuing to use this
        # default = ["oh-my-openagent"];
        example = [];
        type = with lib.types; listOf str;
        description = ''
          List of opencode TUI plugins to include in tui.json.
          These are terminal UI plugins, separate from opencode.json plugins.
          Defaults to ["oh-my-openagent"] for oh-my-openagent TUI integration.
        '';
      };

      modelMode = lib.mkOption {
        default = "free";
        example = "copilot";
        type = lib.types.enum ["copilot" "free"];
        description = ''
          Default oh-my-openagent model mode.
          "copilot" — all agents/categories use github-copilot/* models.
          "free"    — all agents/categories use opencode/* free models.
          Both configs are deployed; switch at runtime with :OpenCodeAgentMode.
        '';
      };
    };

    agent = {
      enable = lib.mkOption {
        default = false;
        example = true;
        type = lib.types.bool;
        description = ''
          Enables agentic.nvim
        '';
      };
      variant = lib.mkOption {
        default = "copilot";
        example = "opencode";
        type = lib.types.enum ["copilot" "opencode" "codex"];
        description = ''
          agentic.nvim ACP provider variant.

          "copilot"  → copilot-acp provider (direct GitHub ACP adapter: copilot --acp --stdio)
          "opencode" → opencode-acp provider (via opencode binary: opencode acp)
          "codex"    → codex-acp provider (Nix-packaged adapter using Codex auth).
          Switch providers in agentic.nvim with <localLeader>s.
        '';
      };
      key = lib.mkOption {
        default = null;
        example = null;
        type = with lib.types; nullOr anything;
        description = ''
          No longer used by agentic.nvim (ACP providers handle auth).
          Kept for backward compatibility — will be removed in a future release.
        '';
      };
      config = lib.mkOption {
        default = {};
        example = {};
        type = with lib.types; attrsOf anything;
        description = ''
          Additional setupOpts passed to agentic.nvim's setup function.
          Merged with (and overrides) the default options.
        '';
      };

      ninetyNine = {
        enable = lib.mkOption {
          default = true;
          example = false;
          type = lib.types.bool;
          description = ''
            Enables ThePrimeagen/99 (agentic search/vibe workflow).
            Only effective when programs.dashvim.agent.enable is true.
          '';
        };
        provider = lib.mkOption {
          default = "OpenCodeProvider";
          example = "ClaudeCodeProvider";
          type = lib.types.enum [
            "OpenCodeProvider"
            "CodexProvider"
            "ClaudeCodeProvider"
            "CursorAgentProvider"
            "KiroProvider"
            "GeminiCLIProvider"
          ];
          description = ''
            99 AI CLI backend. Selects the provider table passed to 99's setup.
          '';
        };
        model = lib.mkOption {
          default = null;
          example = "anthropic/claude-sonnet-4-5";
          type = with lib.types; nullOr str;
          description = ''
            Model override for 99 requests. When null, OpenCode uses
            opencode/big-pickle (its available default) because the provider default
            (OpenCode: opencode/claude-sonnet-4-5) is not a valid model id in
            current opencode and makes every query fail with
            "OpenCodeProvider make_query failed".
            Other providers use their own default model (Codex: gpt-5.3-codex).
            Override this for another model; the Codex picker only lists its
            default because the Codex CLI does not expose a model listing command.
          '';
        };
        providerExtraArgs = lib.mkOption {
          default = [];
          example = ["--extra" "args"];
          type = with lib.types; listOf str;
          description = ''
            Extra CLI args appended by the 99 provider (provider_extra_args).
          '';
        };
        tmpDir = lib.mkOption {
          default = "/tmp/99";
          example = "/tmp/99";
          type = lib.types.str;
          description = ''
            Directory 99 uses for transient state (tmp_dir). Absolute path
            keeps prompt/response/state files out of the repo; a relative
            path resolves against Neovim's cwd and pollutes it.
          '';
        };
        mdFiles = lib.mkOption {
          default = ["AGENTS.md"];
          example = ["AGENTS.md"];
          type = with lib.types; listOf str;
          description = ''
            Markdown files 99 auto-attaches based on the request location (md_files).
          '';
        };
        displayErrors = lib.mkOption {
          default = false;
          example = true;
          type = lib.types.bool;
          description = ''
            Whether 99 surfaces provider errors inline (display_errors).
          '';
        };
        autoAddSkills = lib.mkOption {
          default = null;
          example = true;
          type = with lib.types; nullOr bool;
          description = ''
            Whether 99 auto-attaches discovered skills (auto_add_skills).
            Null leaves the 99 default in place.
          '';
        };
        logger = {
          level = lib.mkOption {
            default = "debug";
            example = "info";
            type = lib.types.enum ["debug" "info" "warn" "error" "fatal"];
            description = ''
              99 file-log verbosity, mapped to require("99").DEBUG etc.
            '';
          };
          type = lib.mkOption {
            default = null;
            example = "file";
            type = with lib.types; nullOr (enum ["print" "void" "file"]);
            description = ''
              99 logger sink. Null leaves the 99 default in place.
            '';
          };
          path = lib.mkOption {
            default = null;
            example = "/tmp/99.debug";
            type = with lib.types; nullOr str;
            description = ''
              99 log file path. Null computes "/tmp/<cwd-basename>.99.debug" at setup.
            '';
          };
          printOnError = lib.mkOption {
            default = true;
            example = false;
            type = lib.types.bool;
            description = ''
              Whether 99 prints log output when a request errors (print_on_error).
            '';
          };
          maxRequestsCached = lib.mkOption {
            default = null;
            example = 50;
            type = with lib.types; nullOr int;
            description = ''
              How many requests 99 keeps for log viewing (max_requests_cached).
              Null leaves the 99 default in place.
            '';
          };
        };
        completion = {
          source = lib.mkOption {
            default = "blink";
            example = "native";
            type = lib.types.enum ["native" "cmp" "blink"];
            description = ''
              Completion engine for #rules and @files in the 99 prompt buffer.
              "native" uses 99's built-in completion; "blink" matches DashVim's
              default completion setup.
            '';
          };
          customRules = lib.mkOption {
            default = [];
            example = ["scratch/custom_rules/"];
            type = with lib.types; listOf str;
            description = ''
              Folders holding SKILL.md rules for #rule completion (custom_rules).
              Expected layout: <dir>/<skill_name>/SKILL.md.
            '';
          };
          files = {
            enabled = lib.mkOption {
              default = true;
              example = false;
              type = lib.types.bool;
              description = ''
                Whether @file completion is enabled.
              '';
            };
            maxFileSize = lib.mkOption {
              default = 102400;
              example = 102400;
              type = lib.types.int;
              description = ''
                Files larger than this (bytes) are skipped by @file completion.
              '';
            };
            maxFiles = lib.mkOption {
              default = 5000;
              example = 5000;
              type = lib.types.int;
              description = ''
                Cap on total files discovered for @file completion.
              '';
            };
            exclude = lib.mkOption {
              default = [
                ".env"
                ".env.*"
                "node_modules"
                ".git"
                "dist"
                "build"
                "*.log"
                ".DS_Store"
                "tmp"
                ".cursor"
              ];
              example = [".env"];
              type = with lib.types; listOf str;
              description = ''
                Exclude patterns for @file completion, applied on top of .gitignore.
              '';
            };
          };
        };
        inFlight = {
          enable = lib.mkOption {
            default = true;
            example = false;
            type = lib.types.bool;
            description = ''
              Whether 99 shows the in-flight request indicator (in_flight_options.enable).
            '';
          };
          interval = lib.mkOption {
            default = null;
            example = 500;
            type = with lib.types; nullOr int;
            description = ''
              Poll interval (ms) for the in-flight indicator (in_flight_interval).
              Null leaves the 99 default in place.
            '';
          };
          throbber = lib.mkOption {
            default = {};
            example = {
              throb_time = 1000;
            };
            type = with lib.types; attrsOf anything;
            description = ''
              Throbber timing overrides (throb_time, cooldown_time, tick_time).
            '';
          };
        };
        extraConfig = lib.mkOption {
          default = {};
          example = {};
          type = with lib.types; attrsOf anything;
          description = ''
            Additional setupOpts passed to 99's setup function.
            Merged with (and overrides) the generated options.
          '';
        };
      };
    };

    markdownPreview = {
      enable = lib.mkOption {
        default = true;
        example = false;
        type = lib.types.bool;
        description = ''
          Enables iamcco/markdown-preview.nvim.
          Toggle the preview with <leader>mm (MarkdownPreviewToggle);
          toggling again stops the preview and its node server.
        '';
      };
      port = lib.mkOption {
        default = "";
        example = "8080";
        type = lib.types.str;
        description = ''
          Port for the preview server (g:mkdp_port).
          Empty means a random free port.
        '';
      };
      theme = lib.mkOption {
        default = "dark";
        example = "light";
        type = lib.types.enum [
          "dark"
          "light"
        ];
        description = ''
          Preview page theme (g:mkdp_theme).
        '';
      };
      browser = lib.mkOption {
        default = "";
        example = "firefox";
        type = lib.types.str;
        description = ''
          Browser command for opening the preview (g:mkdp_browser).
          Empty uses the system default browser.
        '';
      };
      autoStart = lib.mkOption {
        default = false;
        example = true;
        type = lib.types.bool;
        description = ''
          Open the preview automatically when entering a markdown buffer
          (g:mkdp_auto_start). Off by default so markdown never hijacks
          your browser uninvited.
        '';
      };
      autoClose = lib.mkOption {
        default = true;
        example = false;
        type = lib.types.bool;
        description = ''
          Close the preview page when leaving the markdown buffer
          (g:mkdp_auto_close).
        '';
      };
      combinePreview = lib.mkOption {
        default = false;
        example = true;
        type = lib.types.bool;
        description = ''
          Reuse one preview page across markdown buffers instead of one
          page per buffer (g:mkdp_combine_preview).
        '';
      };
      filetypes = lib.mkOption {
        default = ["markdown"];
        example = ["markdown" "vimwiki"];
        type = with lib.types; listOf str;
        description = ''
          Filetypes the preview activates for (g:mkdp_filetypes).
        '';
      };
      extraConfig = lib.mkOption {
        default = {};
        example = {mkdp_page_title = "\${name}";};
        type = with lib.types; attrsOf anything;
        description = ''
          Additional g:mkdp_* globals for markdown-preview.nvim.
          Merged with (and overrides) the generated options.
        '';
      };
    };

    formatters = lib.mkOption {
      default = let
        prettier = [
          "prettierd"
          "prettier"
        ];
      in {
        json = prettier;
        htmlangular = prettier;
        html = prettier;
        css = prettier;
        scss = prettier;
        javascript = prettier;
        javascriptreact = prettier;
        typescript = prettier;
        typescriptreact = prettier;
        markdown = prettier;
        php = prettier;
        csharp = ["csharpier"];
        cs = ["csharpier"];
        fsharp = ["fantomas"];
        python = ["black"];
        lua = ["stylua"];
        nix = ["alejandra"];
        yaml = [
          "yamllint"
          "yamlfmt"
        ];
      };
      example = {};
      type = with lib.types; attrsOf anything;
      description = ''
        Config for conform
      '';
    };

    toolchain = {
      preferProjectTools = lib.mkOption {
        default = true;
        example = false;
        type = lib.types.bool;
        description = ''
          Prefer project-local LSP, formatter, and linter executables found in Neovim's runtime PATH.
          DashVim's pinned Nix tools remain the fallback when no different project tool is available.
        '';
      };
    };

    lsp = {
      useDefaultSpecialLspServers = lib.mkOption {
        default = true;
        example = false;
        type = lib.types.bool;
        description = ''
          These are LSP servers which are installed via plugins. For example rustaceanvim for rust.
          Disabling this will remove all special servers. You can install specific ones using the additionalConfig.
        '';
      };

      special = {
        useAngular = lib.mkOption {
          default = false;
          example = true;
          type = lib.types.bool;
          description = ''
            Whether to enable angular ls. Note this disables Html-ls and removes the typescript renaming function.
          '';
        };

        roslyn = {
          filewatching = lib.mkOption {
            default = "off";
            example = "auto";
            type = lib.types.enum ["auto" "roslyn" "off"];
            description = ''
              File watching mode for roslyn.nvim. "off" disables recursive watched-file
              registrations to avoid Roslyn or Neovim watching too much of the filesystem,
              while DashVim still sends targeted save notifications for C# project files.
              "auto" lets roslyn.nvim choose client or server watching, and "roslyn" forces
              Roslyn's built-in file watcher.
            '';
          };

          broadSearch = lib.mkOption {
            default = true;
            example = false;
            type = lib.types.bool;
            description = ''
              Whether roslyn.nvim should search parent and child directories for solution files.
            '';
          };

          lockTarget = lib.mkOption {
            default = true;
            example = false;
            type = lib.types.bool;
            description = ''
              Whether roslyn.nvim should keep using the selected solution target for later C# buffers.
            '';
          };
        };
      };

      lspServers = lib.mkOption {
        default = {
          # Defaults
          enableDAP = true;
          enableExtraDiagnostics = true;
          enableFormat = true;
          enableTreesitter = true;

          assembly = {
            enable = true;
            lsp.enable = true;
          };
          bash = {
            enable = true;
            lsp.enable = true;
          };
          clang = {
            enable = true;
            lsp.enable = true;
          };
          fsharp = {
            enable = true;
            lsp.enable = true;
          };
          csharp = {
            enable = true;
            lsp = {
              enable = false;
              servers = ["roslyn-ls"];
            };
          };
          css = {
            enable = true;
            lsp.enable = true;
          };
          terraform = {
            enable = true;
            lsp.enable = true;
          };
          typst = {
            enable = true;
            lsp.enable = true;
          };
          typescript = {
            enable = true;
            lsp.enable = false;
          };
          tsx = {
            enable = true;
            lsp.enable = false;
          };
          vala = {
            enable = true;
            lsp.enable = true;
          };
          wgsl = {
            enable = true;
            lsp.enable = true;
          };
          yaml = {
            enable = true;
            lsp.enable = true;
          };
          svelte = {
            enable = true;
            lsp.enable = true;
          };
          php = {
            enable = true;
            lsp.enable = true;
          };
          python = {
            enable = true;
            lsp.enable = true;
          };
          go = {
            enable = true;
            lsp.enable = true;
          };
          lua = {
            enable = true;
            lsp.enable = true;
          };
          # haskell = {
          #   enable = true;
          #   lsp.enable = true;
          # };
          html = {
            enable = true;
          };
          java = {
            enable = true;
            lsp.enable = true;
          };
          kotlin = {
            enable = true;
            lsp.enable = true;
          };
          markdown = {
            enable = true;
            lsp.enable = true;
          };
          nix = {
            enable = true;
            lsp.enable = true;
          };
          ruby = {
            enable = true;
            lsp.enable = true;
          };
          zig = {
            enable = true;
            lsp.enable = true;
          };
          sql = {
            enable = true;
            lsp.enable = true;
          };
          rust = {
            enable = true;
            lsp.enable = true;
            extensions.crates-nvim.enable = true;
          };
          gleam = {
            enable = true;
            lsp.enable = true;
          };
          elixir = {
            enable = true;
            lsp.enable = true;
          };
          dart = {
            enable = true;
            lsp.enable = true;
          };
        };
        example = {};
        type = with lib.types; attrsOf anything;
        description = ''
          Nvf LSP config -> vim.languages
        '';
      };

      tailwind.enable = lib.mkOption {
        default = true;
        example = false;
        description = ''
          Whether to use tailwind lsp
        '';
      };

      additionalConfig = lib.mkOption {
        default = {};
        type = with lib.types; attrsOf anything;
        description = ''
          Nvf lsp configuration to be added to DashVim.
        '';
      };
    };

    additionalConfig = lib.mkOption {
      default = {};
      type = with lib.types; attrsOf anything;
      description = ''
        Nvf configuration to be added to DashVim.
      '';
    };

    additionalLuaConfigFiles = lib.mkOption {
      default = [];
      type = with lib.types; listOf path;
      description = ''
        A list of lua files to be added to DashVim
      '';
    };
  };
}
