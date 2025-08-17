{pkgs, ...}: {
  vim.lazy.plugins = with pkgs.vimPlugins; {
    "debugmaster.nvim" = {
      package = debugmaster-nvim;
      setupOpts = {};
    };
    "nvim-dap-virtual-text" = {
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
  vim.debugger.nvim-dap = {
    enable = true;
  };
}
