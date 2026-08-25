{
  pkgs,
  lib,
  mkDashDefault,
  ...
}: let
  # Instruction sources shared with the opencode integration (hm/opencode.nix
  # deploys the same files to ~/.opencode). Bundling them here gives avante
  # the same always-on context: global AGENTS.md + every repo skill.
  skillFiles =
    lib.filter (p: builtins.pathExists p)
    (map (name: ../../.opencode/skills + "/${name}/SKILL.md")
      (lib.attrNames (lib.filterAttrs (_: type: type == "directory") (builtins.readDir ../../.opencode/skills))));

  instructionSources = [../../AGENTS.md] ++ skillFiles;

  # avante loads `<mode>.avanterules` from rules.global_dir into its agentic
  # system prompt (path.lua find_rules), so this file is injected on every
  # request in the default (agentic) mode.
  globalInstructions = pkgs.runCommand "avante-dashvim-rules" {} ''
    mkdir -p $out
    : > $out/agentic.avanterules
    ${lib.concatMapStrings (src: ''
        echo "# Instructions from ${src}" >> $out/agentic.avanterules
        cat ${src} >> $out/agentic.avanterules
        echo >> $out/agentic.avanterules
      '')
      instructionSources}
  '';
in {
  vim = {
    # Runtime deps required by avante.nvim (plenary is commonly pulled in by
    # other plugins, but declare explicitly so avante works standalone).
    startPlugins = with pkgs.vimPlugins; [
      plenary-nvim
      nui-nvim
    ];

    # Lazy-loaded on its commands only: never loads at startup, so no
    # API-key prompt or startup cost unless the user invokes Avante.
    lazy.plugins."avante.nvim" = mkDashDefault {
      package = pkgs.vimPlugins.avante-nvim;
      setupModule = "avante";
      setupOpts = {
        provider = "copilot";
        providers.copilot = {
          model = "gpt-5.6-terra";
          context_window = 1048576;
          use_response_api = true;
          extra_request_body.max_tokens = 128000;
        };
        # Auth reuses ~/.config/github-copilot/{hosts,apps}.json written by
        # copilot.lua/copilot.vim — no extra plugin needed.
        rules = {
          global_dir = toString globalInstructions;
        };
      };
      cmd = [
        "AvanteAsk"
        "AvanteChat"
        "AvanteChatNew"
        "AvanteToggle"
        "AvanteClear"
        "AvanteFocus"
        "AvanteRefresh"
        "AvanteStop"
        "AvanteEdit"
        "AvanteShowRepoMap"
        "AvanteSelectModel"
        "AvanteSelectHistory"
        "AvanteSwitchProvider"
      ];
    };
  };
}
