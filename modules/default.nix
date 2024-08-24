{ lib, ... }: {
  options.programs.dashvim = {
    colorscheme = lib.mkOption {
      default = "catppuccin-mocha";
      example = {
        # custom tokyo night
        base00 = "1A1B26";
        # base01 = "16161E";
        # base01 = "15161e";
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
        # base0D = "2AC3DE";
        # base0D = "A9B1D6";
        # base0D = "62A0EA";
        # base0D = "779EF1";
        base0D = "366fea";
        base0E = "BB9AF7";
        base0F = "F7768E";
      };
      type = with lib.types; oneOf [ str attrs path ];
      description = ''
        Base16 colorscheme.
        Can be an attribute set with base00 to base0F,
        a string that leads to a yaml file in base16-schemes path,
        or a path to a custom yaml file.
      '';
    };

    default_keymaps = lib.mkOption {
      default = true;
      example = false;
      type = lib.types.bool;
      description = ''
        Enables the default keybinds for DashVim.
        Keep in mind that regular keymaps from plugin defaults and Neovim are still active.
      '';
    };

    keymaps = lib.mkOption {
      default = { };
      example = {
        keymaps = [
          # cursed movement
          {
            mode = "n";
            key = "j";
            action = "h";
            options = {
              noremap = true;
              silent = true;
            };
          }
        ];
      };
      description = ''
        A set of NixVim modules which will be used either alone or in combination with the default keybinds.
      '';
    };
  };
}
