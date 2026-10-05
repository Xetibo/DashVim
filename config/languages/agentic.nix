{
  config',
  pkgs,
  mkDashDefault,
  lib,
  ...
}: let
  codexEditor = import ../../lib/codex-editor.nix {inherit lib;};
  agentic-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "agentic.nvim";
    version = "2026-07-20";

    src = pkgs.fetchFromGitHub {
      owner = "carlos-algms";
      repo = "agentic.nvim";
      rev = "246feb4773923a10a6fedc40048657516bd05792";
      hash = "sha256-dIHH1ayd3Vqer1Rj4CpdazqcG8haZ9ITQb2upj7BH6o=";
    };
    postInstall = ''
      mkdir -p $out/lua/dashvim
      cp ${./agentic.lua} $out/lua/dashvim/agentic.lua
    '';
  };

  # agent.variant selects the ACP provider:
  #   "copilot"  → copilot-acp (direct GitHub adapter: copilot --acp --stdio)
  #   "codex"    → codex-acp (Nix-packaged ACP adapter)
  #   "opencode" → opencode-acp (via opencode binary: opencode acp)
  providerName =
    if config'.agent.variant == "copilot"
    then "copilot-acp"
    else if config'.agent.variant == "codex"
    then "codex-acp"
    else "opencode-acp";
in
  lib.mkIf config'.agent.enable {
    vim = {
      # agentic.nvim handles its own copilot connection via ACP —
      # no need for nvf's built-in copilot.vim plugin.
      assistant.copilot.enable = false;

      # Set theme highlights BEFORE plugin loads (theme.lua only sets if not exists)
      luaConfigRC.agentic-theme =
        mkDashDefault
        /*
        lua
        */
        ''
          vim.api.nvim_set_hl(0, "AgenticStatusPending", { fg = "#${config'.colorscheme.base00 or "1e1e2e"}", bg = "#${config'.colorscheme.base0E or "cba6f7"}", bold = true })
          vim.api.nvim_set_hl(0, "AgenticStatusCompleted", { fg = "#${config'.colorscheme.base00 or "1e1e2e"}", bg = "#${config'.colorscheme.base0B or "a6e3a1"}", bold = true })
          vim.api.nvim_set_hl(0, "AgenticStatusFailed", { fg = "#${config'.colorscheme.base00 or "1e1e2e"}", bg = "#${config'.colorscheme.base08 or "f38ba8"}", bold = true })
          vim.api.nvim_set_hl(0, "AgenticTitle", { bg = "#${config'.colorscheme.base0D or "89b4fa"}", fg = "#${config'.colorscheme.base00 or "1e1e2e"}", bold = true })
          vim.api.nvim_set_hl(0, "AgenticSpinnerGenerating", { fg = "#${config'.colorscheme.base0D or "89b4fa"}", bold = true })
          vim.api.nvim_set_hl(0, "AgenticSpinnerThinking", { fg = "#${config'.colorscheme.base0E or "cba6f7"}", bold = true })
          vim.api.nvim_set_hl(0, "AgenticSpinnerSearching", { fg = "#${config'.colorscheme.base0A or "f9e2af"}", bold = true })
          vim.api.nvim_set_hl(0, "AgenticDiffDeleteWord", { fg = "#${config'.colorscheme.base00 or "1e1e2e"}", bg = "#${config'.colorscheme.base08 or "f38ba8"}", bold = true })
          vim.api.nvim_set_hl(0, "AgenticDiffAddWord", { fg = "#${config'.colorscheme.base00 or "1e1e2e"}", bg = "#${config'.colorscheme.base0B or "a6e3a1"}", bold = true })
          vim.api.nvim_set_hl(0, "AgenticPermissionButtonInactive", { fg = "#${config'.colorscheme.base05 or "cdd6f4"}", bg = "#${config'.colorscheme.base03 or "45475a"}" })
        '';

      lazy.plugins = {
        "agentic.nvim" = mkDashDefault {
          package = agentic-nvim;
          setupModule = "agentic";
          setupOpts =
            {
              provider = providerName;

              acp_providers =
                {
                  "codex-acp" = {
                    command = "${pkgs.codex-acp}/bin/codex-acp";
                    env = lib.mkLuaInline ''require("dashvim.codex-bridge").env(vim.json.decode([==[${builtins.toJSON codexEditor.config.agentic}]==]))'';
                  };
                }
                // lib.optionalAttrs (providerName == "copilot-acp") {
                  "copilot-acp".initial_model = "gpt-5.6-terra";
                };

              windows = {
                position = "left";
                width = "40%";
              };

              # agentic.nvim keymaps mix positional and named keys in a single table
              # (e.g. { "<S-Tab>", mode = { "i", "n", "v" } }), which can't be
              # expressed in pure Nix — use inline Lua to preserve the exact structure.
              keymaps =
                lib.mkLuaInline
                /*
                lua
                */
                ''
                  {
                    widget = {
                      close = "q",
                      change_mode = {
                        { "<S-Tab>", mode = { "i", "n", "v" } },
                      },
                      switch_provider = "<localLeader>s",
                      switch_model = "<localLeader>m",
                      change_thought_level = "<localLeader>t",
                    },
                    prompt = {
                      submit = {
                        "<CR>",
                        { "<C-s>", mode = { "i", "n", "v" } },
                      },
                      paste_image = {
                        { "<localLeader>p", mode = { "n" } },
                        { "<C-v>", mode = { "i" } },
                      },
                    },
                    chat = {
                      next_heading = "]]",
                      prev_heading = "[[",
                      next_tool_call = "]t",
                      prev_tool_call = "[t",
                    },
                    diff_preview = {
                      next_hunk = "]c",
                      prev_hunk = "[c",
                    },
                    permission = {
                      cycle_next = "<C-n>",
                      cycle_prev = "<C-p>",
                    },
                  }
                '';
            }
            // config'.agent.config;
        };
      };
    };
  }
