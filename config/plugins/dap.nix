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
            # command = "${pkgs.vscode-extensions.vadimcn.vscode-lldb.adapter}";
            command = "${pkgs.lldb_17}/bin/lldb-vscode";
          };
        };
      };
      configurations = {
        java = [{
          name = "Debug Java";
          request = "launch";
          type = "java";
        }];
        # rust = [{
        #   name = "Debug Rust";
        #   request = "launch";
        #   type = "codelldb";
        #   program = ''function()
        #     return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        #   end'';
        #   # cwd = ''${workspaceFolder}'';
        # }];
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
      };
    };
  };
  extraConfigLua = ''
    require('dap').listeners.after.event_initialized['dapui_config'] = require('dapui').open
    require('dap').listeners.before.event_terminated['dapui_config'] = require('dapui').close
    require('dap').listeners.before.event_exited['dapui_config'] = require('dapui').close

    local rust_dap = Get_git_root().cwd
    local filename = ""
    for w in rust_dap:gmatch("([^/]+)") do
      filename = w
    end
    require('dap').configurations.rust = {
      	{
      		name = 'Launch',
      		type = 'codelldb',
      		request = 'launch',
      		program = function()
            return rust_dap .. "/target/debug/" .. filename
      		end,
      		cwd = "''${workspaceFolder}",
      		stopOnEntry = false,
      		args = {},
      	},
    }
  '';
}
