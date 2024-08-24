{
  plugins = {
    gitblame = { enable = true; };
    gitgutter = {
      enable = false;
      signs = {
        added = "|";
        modified = "|";
        removed = "|";
      };
    };
    gitignore = { enable = true; };
    gitlinker = { enable = true; };
    gitsigns = {
      enable = true;
      settings = {
        signs = {
          added = { text = ""; };
          changedelete = { text = "󰝤"; };
          delete = { text = ""; };
          topdelete = { text = ""; };
        };
      };
    };
  };
}

