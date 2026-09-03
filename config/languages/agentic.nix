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

  # System instructions for the agent: caveman skill + project docs + restrictions
  # Written to a store path at build time to avoid Lua string escaping issues.
  systemInstructionsFile = pkgs.writeText "agentic-system-instructions.md" ''
    ## Communication Style

    Respond terse like smart caveman. All technical substance stay. Only fluff die.

    Drop: articles (a/an/the), filler (just/really/basicelly/actually/simply), pleasantries (sure/certanly/of course/happy to), hedging. Fragments OK. Short synonyms (big not extensive, fix not "implement a solution for"). Technical terms exact. Code blocks unchanged. Errors quoted exact.

    Pattern: `[thing] [action] [reason]. [next step].`

    Not: "Sure! I'd be happy to help you with that. The issue you're experiencing is likely caused by..."
    Yes: "Bug in auth middleware. Token expiry check use `<` not `<=`. Fix:"

    ## Agent Restrictions

    You are a code assistant with LIMITED capabilities. You MAY:
    - View and read code
    - Edit code files
    - Review code and provide feedback
    - Answer questions about the codebase
    - Provide suggestions and warnings

    You MUST NOT:
    - Run code, tests, or commands
    - Commit changes to git
    - Execute shell commands
    - Run build systems
    - Perform any destructive operations

    ## Project: DashVim

    DashVim is a Nix flake that builds and distributes a Neovim configuration based on `nvf`.

    ### Code Guidelines
    - Prefer small, focused changes that match existing Nix style.
    - Prefer functional composition through Nix modules and functions over object-oriented patterns.
    - Keep public options in `modules/default.nix` documented with useful descriptions and examples.
    - Keep implementation modules grouped by feature under `config/`, `lib/`, `hm/`, and `modules/`.
    - Add comments only when code is not self-explanatory or when documenting a non-obvious tradeoff.
    - Use `alejandra` for Nix formatting.
    - Check for `flake.nix` before changing code and use it for development commands where practical.

    ### UI Guidelines
    - Use Base16 palette keys as the shared color contract.
    - Default palette is Catppuccin-like: base00=background, base05=primary text, base0D=accent blue, base0E=secondary purple, base0C=cyan, base0B=success green, base09=warning peach, base08=error red.
    - Keep visual defaults compact and keyboard-driven.
    - Preserve existing navigation conventions and leader-key patterns.

    ### Architecture
    - `flake.nix` is the main entry point.
    - `modules/default.nix` defines the public `programs.dashvim` option surface.
    - `lib/default.nix` calls `inputs.nvf.lib.neovimConfiguration`.
    - `config/default.nix` imports the Neovim configuration modules.
    - Opencode theme generation uses the configured Base16 colorscheme.

    ### Technical Debt
    - README keybinding documentation may be outdated. Verify default keymaps in code.
    - `programs.dashvim.opencode.config` is merged after generated defaults.
    - Automated testing is Nix-focused. No separate unit/integration test suite for Lua plugin behavior.

    ### Testing
    - Use flake-first verification strategy.
    - Use `nix eval`, `nix build`, and `git diff --check`.
    - Prefer the smallest command that covers the changed area.
  '';
in {
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
        vim.api.nvim_set_hl(0, "AgenticStatusPending", { bg = "#${config'.colorscheme.base0E or "cba6f7"}" })
        vim.api.nvim_set_hl(0, "AgenticStatusCompleted", { bg = "#${config'.colorscheme.base0B or "a6e3a1"}" })
        vim.api.nvim_set_hl(0, "AgenticStatusFailed", { bg = "#${config'.colorscheme.base08 or "f38ba8"}" })
        vim.api.nvim_set_hl(0, "AgenticTitle", { bg = "#${config'.colorscheme.base0D or "89b4fa"}", fg = "#${config'.colorscheme.base00 or "1e1e2e"}", bold = true })
        vim.api.nvim_set_hl(0, "AgenticSpinnerGenerating", { fg = "#${config'.colorscheme.base0D or "89b4fa"}", bold = true })
        vim.api.nvim_set_hl(0, "AgenticSpinnerThinking", { fg = "#${config'.colorscheme.base0E or "cba6f7"}", bold = true })
        vim.api.nvim_set_hl(0, "AgenticSpinnerSearching", { fg = "#${config'.colorscheme.base0A or "f9e2af"}", bold = true })
        vim.api.nvim_set_hl(0, "AgenticDiffDeleteWord", { bg = "#${config'.colorscheme.base08 or "f38ba8"}", bold = true })
        vim.api.nvim_set_hl(0, "AgenticDiffAddWord", { bg = "#${config'.colorscheme.base0B or "a6e3a1"}", bold = true })
        vim.api.nvim_set_hl(0, "AgenticPermissionButtonInactive", { bg = "#${config'.colorscheme.base03 or "585b70"}" })
      '';

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

    # After plugin loads: inject system instructions and set default model
    luaConfigRC.agentic-after =
      mkDashDefault
      /*
      lua
      */
      ''
        -- Wait for agentic to be available
        vim.api.nvim_create_autocmd("User", {
          pattern = "VeryLazy",
          once = true,
          callback = function()
            local agentic = require("agentic")
            local config = require("agentic.config")
            local ACPClient = require("agentic.acp.acp_client")

            -- Read system instructions from store path
            local instructions_path = "${toString systemInstructionsFile}"
            local f = io.open(instructions_path, "r")
            if not f then
              vim.notify("[Agentic] Could not read system instructions: " .. instructions_path, vim.log.levels.ERROR)
              return
            end
            local system_instructions = f:read("*a")
            f:close()

            -- Monkey-patch send_prompt to prepend system instructions on every prompt
            local original_send_prompt = ACPClient.send_prompt
            ACPClient.send_prompt = function(self, session_id, prompt, callback)
              -- Prepend system instructions as first content item
              table.insert(prompt, 1, {
                type = "text",
                text = system_instructions,
              })
              return original_send_prompt(self, session_id, prompt, callback)
            end

            -- Set default model and handle pending prompts after session creation
            local original_new_session = agentic.new_session
            agentic.new_session = function(opts)
              local session = original_new_session(opts)

              -- Handle pending review prompt (set by review.lua's complete_agentic)
              local pending_prompt = vim.g.agentic_pending_prompt
              if pending_prompt then
                vim.g.agentic_pending_prompt = nil

                vim.schedule(function()
                  local SessionRegistry = require("agentic.session_registry")
                  local current_session = SessionRegistry.get_session_for_tab_page(nil, function(s)
                    if s then
                      s:on_session_ready(function(ready_session)
                        if ready_session.session_id then
                          local prompt = {
                            { type = "text", text = pending_prompt }
                          }
                          ready_session.agent:send_prompt(ready_session.session_id, prompt, function(response, err)
                            if err then
                              vim.notify("[Agentic] Review prompt failed: " .. tostring(err), vim.log.levels.ERROR)
                            end
                          end)
                        end
                      end)
                    end
                  end)
                end)
              end

              return session
            end
          end,
        })
      '';
  };
}
