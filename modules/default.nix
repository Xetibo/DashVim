{ lib, ... }: {
  options.programs.dashvim = {
    colorscheme = lib.mkOption {
      type = lib.types.attrs;
      default = {
        catppuccin = {
          enable = true;
        };
      };
      defaultText = ''
        The colorscheme to be used.
      '';
    };
  };
}
