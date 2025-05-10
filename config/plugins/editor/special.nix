let
  opts = {
    shiftwidth = 4;
    tabstop = 4;
    expandtab = true;
  };
in {
  files = {
    "ftplugin/fsharp.lua" = {
      inherit opts;
    };
    "ftplugin/css.lua" = {
      inherit opts;
    };
    "ftplugin/scss.lua" = {
      inherit opts;
    };
    "ftplugin/javascript.lua" = {
      inherit opts;
    };
    "ftplugin/typescript.lua" = {
      inherit opts;
    };
  };
}
