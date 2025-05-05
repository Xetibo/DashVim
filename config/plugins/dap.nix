{pkgs, ...}: {
  extraPlugins = with pkgs.vimPlugins; [
    nvim-dap-ui
    nvim-dap-virtual-text
    nvim-dap-python
    nvim-dap-go
    telescope-dap-nvim
  ];
  extraPackages = with pkgs; [vscode-extensions.vadimcn.vscode-lldb.adapter];
  plugins = {
    dap-python = {
      enable = true;
    };
    dap-ui = {
      enable = true;
      settings = {
        floating = {
          mappings = {
            close = [
              "<ESC>"
              "q"
            ];
          };
          border = "rounded";
        };
      };
    };
    dap-virtual-text = {
      enable = true;
    };
    dap = {
      adapters = {
        executables = {
          codelldb = {
            command = "${pkgs.lldb_17}/bin/lldb-vscode";
          };
          coreclr = {
            command = "${pkgs.netcoredbg}/bin/netcoredbg";
            args = ["--interpreter=vscode"];
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
        java = [
          {
            name = "Debug Java";
            request = "launch";
            type = "java";
          }
        ];
        go = [
          {
            name = "Debug Go";
            request = "launch";
            type = "delve";
          }
        ];
        cpp = [
          {
            name = "Debug CPP";
            request = "launch";
            type = "codelldb";
          }
        ];
        c = [
          {
            name = "Debug C";
            request = "launch";
            type = "codelldb";
          }
        ];
      };
    };
  };
  extraConfigLua = ''
    local dap = require('dap')

    dap.adapters["chrome"] = {
      type = "server",
      host = "localhost",
      port = "$\{port\}",
      executable = {
        command = "${pkgs.vscode-js-debug}/bin/js-debug",
        args = {"$\{port\}"},
      }
    }

    dap.configurations.typescript = {
      {
        type = "chrome",
        request = "launch",
        name = "Launch chrome",
        url = "http://localhost:4200",
        webRoot = "$\{workspaceFolder\}",
        sourceMaps = true,
      },
    }
    dap.configurations.javascript = dap.configurations.typescript

    dap.configurations.cs = {
      {
        type = "coreclr",
        name = "Debug .Net",
        request = "launch",
        program = function()
            return vim.fn.input('Path to dll', vim.fn.getcwd() .. '/bin/Debug/', 'file')
        end,
      },
    }

    dap.configurations.fsharp = {
      {
        type = "coreclr",
        name = "Debug .Net",
        request = "launch",
        program = function()
            return vim.fn.input('Path to dll', vim.fn.getcwd() .. '/bin/Debug/', 'file')
        end,
      },
    }

    dap.listeners.after.event_initialized['dapui_config'] = require('dapui').open
    dap.listeners.before.event_terminated['dapui_config'] = require('dapui').close
    dap.listeners.before.event_exited['dapui_config'] = require('dapui').close
  '';
}
