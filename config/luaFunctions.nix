{
  isAngular =
    /*
    lua
    */
    ''
      local function is_angular_project(root_dir)
        if root_dir == nil then
          return false
        end
        local util = require("lspconfig.util")
        local ang = util.path.exists(util.path.join(root_dir, "angular.json"));
        local angTemp = util.path.exists(util.path.join(root_dir, "angular-template.json"));
        local isAngular = ang or angTemp
        return isAngular
      end
    '';
}
