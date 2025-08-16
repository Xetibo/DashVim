{
  config',
  pkgs,
  lib,
  ...
}: {
  plugins = {
    nix.enable = true;
    neotest = {
      enable = true;
      settings = {
        output = {
          enabled = true;
          open_on_run = true;
        };
        output_panel = {
          enabled = true;
          open = "botright split | resize 15";
        };
        status = {
          enabled = true;
          signs = true;
        };

        icons = {
          child_indent = "│";
          child_prefix = "├";
          collapsed = "─";
          expanded = "╮";
          failed = "";
          final_child_indent = " ";
          final_child_prefix = "╰";
          non_collapsible = "─";
          passed = "";
          running = "";
          running_animated = [
            "/"
            "|"
            "\\"
            "-"
            "/"
            "|"
            "\\"
            "-"
          ];
          skipped = "";
          unknown = "";
          watching = "";
        };
      };
      adapters = {
        dotnet.enable = true;
        elixir.enable = true;
        go.enable = true;
        gradle.enable = true;
        rust.enable = true;
        python.enable = true;
        zig.enable = true;
        # playwright.enable = true;
        haskell.enable = true;
        java.enable = true;
        bash.enable = true;
        dart.enable = true;
        deno.enable = true;
        vitest.enable = true;
      };
    };
    lsp-format = {
      lazyLoad.settings.event = "BufEnter";
      enable = true;
    };
    lsp-status = {
      # lazy load issues due to lualine
      enable = true;
    };
    lsp = {
      lazyLoad.settings.event = "BufEnter";
      enable = true;
      # these can be turned on via toggle
      inlayHints = false;
      preConfig =
        # lua
        ''
          local border = {
                {"🭽", "FloatBorder"},
                {"▔", "FloatBorder"},
                {"🭾", "FloatBorder"},
                {"▕", "FloatBorder"},
                {"🭿", "FloatBorder"},
                {"▁", "FloatBorder"},
                {"🭼", "FloatBorder"},
                {"▏", "FloatBorder"},
          }
          local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
          function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
            opts = opts or {}
            opts.border = border
            return orig_util_open_floating_preview(contents, syntax, opts, ...)
          end
        '';
      servers =
        {
          ltex_plus = {
            # needed as its missing in nixvim right now
            # TODO remove when available
            package = lib.mkForce pkgs.ltex-ls-plus;
          };
        }
        // config'.lsp.lspServers;
    };
  };
  extraConfigLua = ''
    local_border = "rounded"
  '';
}
