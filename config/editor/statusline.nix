{
  pkgs,
  lib,
  mkDashDefault,
  ...
}: {
  vim.extraPlugins = with pkgs.vimPlugins; {
    "nvim-web-devicons" = mkDashDefault {
      package = nvim-web-devicons;
    };
  };
  vim.lazy.plugins = with pkgs.vimPlugins; {
    "lualine.nvim" = mkDashDefault {
      package = lualine-nvim;
      setupModule = "lualine";
      setupOpts = {
        sections.lualine_a = [
          (lib.mkLuaInline ''{ "mode", fmt = function(mode) return vim.g.in_review_session and "REVIEW" or mode end }'')
        ];
        options = {
          theme = "base16";
          disabled_filetypes = {
            statusline = ["alpha" "dashboard"];
            winbar = ["alpha" "dashboard"];
          };
        };
      };
    };
    "barbar.nvim" = mkDashDefault {
      package = barbar-nvim;
      setupModule = "barbar";
      setupOpts = {
        auto_hide = 1;
      };
    };
  };
}
