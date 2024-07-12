{
  lib,
  nvf,
  ...
}: let
  opts = {
    tabstop = 4;
    shiftwidth = 4;
    expandtab = true;
  };
  optsSmall = {
    tabstop = 2;
    shiftwidth = 2;
    expandtab = true;
  };
  mkVimOpt = attrs: lib.attrsets.mapAttrs' (name: value: lib.attrsets.nameValuePair "  vim.bo.${name}" value) attrs;
  files = lib.attrsets.mapAttrsToList (name: value: {inherit name value;}) {
    fsharp = {
      opts = mkVimOpt opts;
      types = ["fs"];
    };
    css = {
      opts = mkVimOpt optsSmall;
      types = ["css" "scss"];
    };
    nix = {
      opts = mkVimOpt optsSmall;
      types = ["nix"];
    };
    typescript = {
      opts = mkVimOpt optsSmall;
      types = ["ts" "js" "mts"];
    };
  };

  mkEntry = name: value: "${name} = ${builtins.toString (nvf.lib.nvim.lua.toLuaObject value)}";
  mkCmd = file: {
    desc = "File Plugin ${file.name}";
    event = ["FileType"];
    group = "filetypes";
    pattern = file.value.types;
    callback =
      lib.generators.mkLuaInline
      /*
      lua
      */
      ''
        function()
        ${lib.strings.concatStringsSep "\n" (lib.mapAttrsToList mkEntry file.value.opts)}
        end
      '';
  };
in {
  vim.autocmds = lib.map mkCmd files;
}
