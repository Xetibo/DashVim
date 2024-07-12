{
  pkgs,
  mkDashDefault,
  ...
}: {
  vim = {
    lazy.plugins = with pkgs.vimPlugins; {
      "debugmaster.nvim" = mkDashDefault {
        package = debugmaster-nvim;
        setupOpts = {};
      };
      "nvim-dap-virtual-text" = mkDashDefault {
        package = nvim-dap-virtual-text;
        setupModule = "nvim-dap-virtual-text";
        setupOpts = {};
      };
      # TODO required?
      # "nvim-dap-vscode-js" = {
      #   package = nvim-dap-vscode-js;
      #   setupModule = "nvim-dap-vscode-js";
      #   setupOpts = {};
      # };
      # "nvim-dap-python" = {
      #   package = nvim-dap-python;
      #   setupModule = "nvim-dap-python";
      #   setupOpts = {};
      # };
      # "nvim-dap-go" = {
      #   package = nvim-dap-go;
      #   setupModule = "nvim-dap-go";
      #   setupOpts = {};
      # };
    };
    debugger.nvim-dap = mkDashDefault {
      enable = true;
    };

    # --dap.configurations.cs = {
    # --  {
    # --    type = "coreclr",
    # --    name = "Debug .Net",
    # --    request = "launch",
    # --    program = function()
    # --        return vim.fn.input('Path to dll', vim.fn.getcwd() .. '/bin/Debug/', 'file')
    # --    end,
    # --  },
    # --}
    #
    # --dap.configurations.fsharp = {
    # --  {
    # --    type = "coreclr",
    # --    name = "Debug .Net",
    # --    request = "launch",
    # --    program = function()
    # --        return vim.fn.input('Path to dll', vim.fn.getcwd() .. '/bin/Debug/', 'file')
    # --    end,
    # --  },
    # --}
    #
    # --local rust_dap = vim.fn.getcwd()
    # --local filename = ""
    # --for w in rust_dap:gmatch("([^/]+)") do
    # --  filename = w
    # --end
    #
    # --dap.configurations.rust = {
    # --  {
    # --    type = "lldb",
    # --    request = "launch",
    # --    program = function()
    # --      return rust_dap .. "/target/debug/" .. filename
    # --    end,
    # --    --program = '$\{fileDirname\}/$\{fileBasenameNoExtension\}',
    # --    cwd = "$\{workspaceFolder\}",
    # --    stopOnEntry = true,
    # --    terminal = "integrated",
    # --  },
    # --}
    #
    # --dap.configurations.cpp = {
    # --  {
    # --    name = "debug cpp",
    # --    type = "lldb",
    # --    request = "launch",
    # --    program = function()
    # --      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/build/", "file")
    # --    end,
    # --    cwd = "$\{workspaceFolder\}",
    # --    stopOnEntry = true,
    # --    terminal = "integrated",
    # --  },
    # --}
    # --dap.configurations.c = dap.configurations.cpp
  };
}
