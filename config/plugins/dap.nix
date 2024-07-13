{ pkgs, ... }: {
  extraPlugins = with pkgs.vimPlugins; [
    nvim-dap-ui
    nvim-dap-virtual-text
    nvim-dap-python
    nvim-dap-go
    telescope-dap-nvim
  ];
  extraPackages = with pkgs; [
    vscode-extensions.vadimcn.vscode-lldb.adapter
  ];
  plugins = {
    dap = {
      extensions = {
        dap-python = {
          enable = true;
        };
        dap-ui = {
          enable = true;
          floating.mappings = {
            close = [ "<ESC>" "q" ];
          };
          extraOptions = {
            floating = {
              border = "rounded";
            };
          };
        };
        dap-virtual-text = {
          enable = true;
        };
      };
      adapters = {
        executables = {
          codelldb = {
            command = "${pkgs.lldb_17}/bin/lldb-vscode";
          };
          netcoredbg = {
            command = "${pkgs.netcoredbg}/bin/netcoredbg";
            args = [ "--interpreter=vscode" ];
          };
          java = {
            command = "${pkgs.vscode-extensions.vscjava.vscode-java-debug}/bin/java-debug-adapter";
          };
          delve = {
            command = "${pkgs.delve}/bin/delve";
          };
        };
      };
      configurations = {
        java = [{
          name = "Debug Java";
          request = "launch";
          type = "java";
        }];
        go = [{
          name = "Debug Go";
          request = "launch";
          type = "delve";
        }];
        cpp = [{
          name = "Debug CPP";
          request = "launch";
          type = "codelldb";
        }];
        c = [{
          name = "Debug C";
          request = "launch";
          type = "codelldb";
        }];
        cs = [{
          name = "Debug C#";
          request = "launch";
          type = "netcoredbg";
        }];
      };
    };
  };
  extraConfigLua = ''
    require('dap').listeners.after.event_initialized['dapui_config'] = require('dapui').open
    require('dap').listeners.before.event_terminated['dapui_config'] = require('dapui').close
    require('dap').listeners.before.event_exited['dapui_config'] = require('dapui').close
  '';
}
