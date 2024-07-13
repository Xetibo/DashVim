{ pkgs, ... }: {
  extraPlugins = with pkgs.vimPlugins; [
    nvim-dap-ui
    nvim-dap-virtual-text
    nvim-dap-python
    nvim-dap-go
    telescope-dap-nvim
  ];
  plugins = {
    dap = {
      #
      #   # https://github.com/AstroNvim/AstroNvim/blob/v4.7.7/lua/astronvim/plugins/configs/nvim-dap-ui.lua
      #   # https://github.com/AstroNvim/AstroNvim/blob/v4.7.7/lua/astronvim/plugins/dap.lua#L37
      #   config = ''
      #     local dap, dapui = require "dap", require "dapui"
      #
      #     dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      #     dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      #     dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
      #
      #     dapui.setup({ floating = { border = "rounded" } })
      #   '';
      # };
      extensions = {
        dap-python = {
          enable = true;
        };
        dap-ui = {
          enable = true;
          floating.mappings = {
            close = [ "<ESC>" "q" ];
          };
        };
        dap-virtual-text = {
          enable = true;
        };
      };
      adapters = {
        executables = {
          lldb = {
            command = "${pkgs.lldb_18}/bin/lldb-vscode";
          };
        };
      };
    };
  };
}
