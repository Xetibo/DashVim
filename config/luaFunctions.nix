{
  isAngular =
    /*
    lua
    */
    ''
      local function is_angular_project(root_dir)
        local function exists(name)
           local f=io.open(name,"r")
           if f~=nil then io.close(f) return true else return false end
        end
        local function join(path, file)
            return path .. "/" .. file
        end
        if root_dir == nil then
          return false
        end
        local ang = exists(join(root_dir, "angular.json"));
        local angTemp = exists(join(root_dir, "angular-template.json"));
        local isAngular = ang or angTemp
        return isAngular
      end
    '';
}
