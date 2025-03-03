{
  inputs,
  system,
  ...
}: let
  # TODO revert to nixpkgs when fixed
  blinkPkg = inputs.blink.packages.${system}.default;
in {
  plugins.blink-cmp = {
    package = blinkPkg;
    enable = true;
    # broken right now
    #lazyLoad.settings.event = "VimEnter";
    settings = {
      fuzzy = {
        implementation = "prefer_rust";
        prebuilt_binaries = {
          download = false;
        };
      };
      keymap = {
        "<C-space>" = [
          "show"
          "fallback"
        ];
        "<C-e>" = [
          "hide"
          "fallback"
        ];
        "<Enter>" = [
          "accept"
          "fallback"
        ];
        "<S-Tab>" = [
          "select_prev"
          "fallback"
        ];
        "<Tab>" = [
          "select_next"
          "fallback"
        ];
        "<C-b>" = [
          "scroll_documentation_up"
          "fallback"
        ];
        "<C-f>" = [
          "scroll_documentation_down"
          "fallback"
        ];
      };
      cmdline = {
        keymap = {
          "<S-Tab>" = [
            "select_prev"
          ];
          "<Enter>" = [
            "fallback"
          ];
          "<C-Enter>" = [
            "accept"
            "fallback"
          ];
        };
      };
      appearance = {
        use_nvim_cmp_as_default = true;
      };
      completion = {
        accept = {
          auto_brackets = {
            enabled = true;
          };
        };
        list.selection = {
          preselect = false;
          auto_insert = false;
        };
        menu = {
          border = "rounded";
          winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None";
        };
        documentation = {
          auto_show = true;
          window = {
            border = "rounded";
            winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None";
          };
        };
        ghost_text = {
          enabled = true;
        };
      };
      signature = {
        window = {
          border = "rounded";
          winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None";
        };
      };
      sources = {
        default = [
          "lsp"
          "path"
          "buffer"
        ];
        providers = {
          lsp = {
            module = "blink.cmp.sources.lsp";
            name = "lsp";
            enabled = true;
          };
          path = {
            module = "blink.cmp.sources.path";
            name = "path";
            min_keyword_length = 3;
            enabled = true;
            score_offset = -10;
          };
          buffer = {
            module = "blink.cmp.sources.buffer";
            name = "buffer";
            min_keyword_length = 5;
            fallback_for = {};
            enabled = true;
            score_offset = -10;
          };
        };
      };
    };
  };
}
