{pkgs, ...}: {
  extraPlugins = with pkgs.vimPlugins; [
    debugmaster-nvim
    nvim-dap-vscode-js
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
    dap-virtual-text = {
      enable = true;
    };
    dap = {
      adapters = {
        executables = {
          lldb = {
            command = "${pkgs.lldb_20}/bin/lldb-dap";
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
      };
    };
  };
  extraConfigLua = ''
    local dap = require('dap')

    require("dap").adapters["pwa-node"] = {
      type = "server",
      host = "localhost",
      port = "$\{port\}",
      executable = {
        command = "${pkgs.vscode-js-debug}/bin/js-debug",
        args = {"$\{port\}"},
      }
    }

    require("dap").adapters["pwa-chrome"] = {
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
        type = 'pwa-chrome',
        request = 'launch',
        name = 'Launch Current File (chrome)',
        cwd = "$\{workspaceFolder\}",
        args = { '$\{file\}' },
        sourceMaps = true,
        protocol = 'inspector',
      },
      {
        type = 'pwa-chrome',
        request = 'launch',
        name = 'Launch Current File (Typescript)',
        cwd = "$\{workspaceFolder\}",
        runtimeArgs = { '--loader=ts-node/esm' },
        program = "$\{file\}",
        runtimeExecutable = 'node',
        -- args = { '$\{file\}' },
        sourceMaps = true,
        protocol = 'inspector',
        outFiles = { "$\{workspaceFolder\}/**/**/*", "!**/node_modules/**" },
        skipFiles = { '<node_internals>/**', 'node_modules/**' },
        resolveSourceMapLocations = {
          "$\{workspaceFolder\}/**",
          "!**/node_modules/**",
        },
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

    local rust_dap = vim.fn.getcwd()
    local filename = ""
    for w in rust_dap:gmatch("([^/]+)") do
      filename = w
    end

    dap.configurations.rust = {
      {
        type = "lldb",
        request = "launch",
        program = function()
          return rust_dap .. "/target/debug/" .. filename
        end,
        --program = '$\{fileDirname\}/$\{fileBasenameNoExtension\}',
        cwd = "$\{workspaceFolder\}",
        stopOnEntry = true,
        terminal = "integrated",
      },
    }

    dap.configurations.cpp = {
      {
        name = "debug cpp",
        type = "lldb",
        request = "launch",
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/build/", "file")
        end,
        cwd = "$\{workspaceFolder\}",
        stopOnEntry = true,
        terminal = "integrated",
      },
    }
    dap.configurations.c = dap.configurations.cpp
  '';
}
