{
  config',
  pkgs,
  mkDashDefault,
  lib,
  ...
}: let
  agentic-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "agentic.nvim";
    version = "2026-07-20";

    src = pkgs.fetchFromGitHub {
      owner = "carlos-algms";
      repo = "agentic.nvim";
      rev = "246feb4773923a10a6fedc40048657516bd05792";
      hash = "sha256-dIHH1ayd3Vqer1Rj4CpdazqcG8haZ9ITQb2upj7BH6o=";
    };
  };

  # agent.variant selects the ACP provider:
  #   "copilot"  → copilot-acp (direct GitHub adapter: copilot --acp --stdio)
  #   otherwise  → opencode-acp (via opencode binary: opencode acp)
  providerName =
    if config'.agent.variant == "copilot"
    then "copilot-acp"
    else "opencode-acp";
in {
  vim = {
    # agentic.nvim handles its own copilot connection via ACP —
    # no need for nvf's built-in copilot.vim plugin.
    assistant.copilot.enable = false;

    lazy.plugins = {
      "agentic.nvim" = mkDashDefault {
        package = agentic-nvim;
        setupModule = "agentic";
        setupOpts =
          {
            provider = providerName;

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
