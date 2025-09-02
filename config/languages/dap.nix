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
  };
}
