let
  opts = {
    shiftwidth = 4;
    tabstop = 4;
    expandtab = true;
  };
  optsSmall = {
    shiftwidth = 2;
    tabstop = 2;
    expandtab = true;
  };
in {
  files = {
    "ftplugin/fsharp.lua" = {
      opts = opts;
    };
    "ftplugin/css.lua" = {
      opts = optsSmall;
    };
    "ftplugin/scss.lua" = {
      opts = optsSmall;
    };
    "ftplugin/javascript.lua" = {
      opts = optsSmall;
    };
    "ftplugin/typescript.lua" = {
      opts = optsSmall;
    };
  };
}
