{
  plugins = {
    gitblame = {
      enable = true;
    };
    gitgutter = {
      enable = false;
      settings = {
        sign_added = "|";
        sign_modified = "|";
        sign_removed = "|";
      };
    };
    gitignore = {
      enable = true;
    };
    gitlinker = {
      enable = true;
    };
    gitsigns = {
      enable = true;
      settings = {
        signs = {
          added = {
            text = "";
          };
          changedelete = {
            text = "󰝤";
          };
          delete = {
            text = "";
          };
          topdelete = {
            text = "";
          };
        };
      };
    };
  };
}
