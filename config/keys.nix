{ config', lib, ... }: lib.mkIf config'.default_keymaps {
  # which key topics
  plugins.lsp = {
    keymaps = {
      silent = true;
      lspBuf = {
        "<leader>ca" = {
          action = "definition";
          desc = "Goto Definition";
        };
        "<leader>cA" = {
          action = "declaration";
          desc = "Goto Declaration";
        };
        "<leader>cf" = {
          action = "implementation";
          desc = "Goto Implementation";
        };
        "<leader>cd" = {
          action = "type_definition";
          desc = "Type Definition";
        };
        "<leader>ce" = {
          action = "hover";
          desc = "Hover";
        };
        "<leader>cw" = {
          action = "workspace_symbol";
          desc = "Workspace Symbol";
        };
        "<leader>cr" = {
          action = "rename";
          desc = "Rename";
        };
      };
      diagnostic = {
        "<leader>cld" = {
          action = "open_float";
          desc = "Line Diagnostics";
        };
        "<leader>cn" = {
          action = "goto_next";
          desc = "Next Diagnostic";
        };
        "<leader>cp" = {
          action = "goto_prev";
          desc = "Previous Diagnostic";
        };
      };
    };
  };
  plugins.which-key = {
    enable = true;
    settings.spec = [
      {
        __unkeyed-1 = "]";
        desc = "+next";
      }
      {
        __unkeyed-1 = "[";
        desc = "+prev";
      }
      {
        __unkeyed-1 = "<leader><tab>";
        desc = "+tabs";
      }
      {
        # "<leader>b" = "+buffer";
        __unkeyed-1 = "<leader>c";
        desc = "+code";
      }
      {
        __unkeyed-1 = "<leader>cl";
        desc = "+codelines";
      }
      {
        __unkeyed-1 = "<leader>f";
        desc = "+file/find";
      }
      {
        __unkeyed-1 = "<leader>g";
        desc = "+git";
      }
      {
        __unkeyed-1 = "<leader>x";
        desc = "+diagnostics/quickfix";
      }
      {
        __unkeyed-1 = "<leader>d";
        desc = "+debug";
      }
    ];
  };
  # "g" = "+goto";
  # "gz" = "+surround";
  # "<leader>gh" = "+hunks";
  # "<leader>q" = "+quit/session";
  # "<leader>s" = "+search";
  # "<leader>u" = "+ui";
  # "<leader>w" = "+windows";
  # "<leader>h" = "+harpoon";
  keymaps = [
    {
      mode = "n";
      key = "<leader>cll";
      action = "<CMD>lua require('lsp_lines').toggle() <CR>";
      options =
        {
          noremap = true;
          silent = true;
          desc = "Toggle lsp lines";
        };
    }
    {
      mode = "n";
      key = "<leader>ccr";
      action = "<CMD>LspRestart <CR>";
      options =
        {
          noremap = true;
          silent = true;
          desc = "Restart LSP";
        };
    }
    {
      mode = "n";
      key = "<leader>cm";
      action = "<CMD>lua lsp.inlay_hint.enable(0, not lsp.inlay_hint.is_enabled()) <CR>";
      options = { noremap = true; silent = true; };
    }
    {
      mode = "n";
      key = "gx";
      action = ":silent execute '!$BROWSER ' . shellescape(expand('<cfile>'), 1)<CR>";
      options = { noremap = true; silent = true; };
    }

    # trouble 
    {
      mode = "n";
      key = "<leader>t";
      action = "<cmd>Trouble diagnostics toggle filter.buf=0<cr>";
      options =
        {
          noremap = true;
          silent = true;
          desc = "Trouble";
        };
    }


    # movement
    {
      mode = "n";
      key = "j";
      action = "h";
      options = { noremap = true; silent = true; };
    }
    {
      mode = "n";
      key = "l";
      action = "k";
      options = { noremap = true; silent = true; };
    }
    {
      mode = "n";
      key = "k";
      action = "j";
      options = { noremap = true; silent = true; };
    }
    {
      mode = "n";
      key = ";";
      action = "l";
      options = { noremap = true; silent = true; };
    }
    {
      mode = "v";
      key = "j";
      action = "h";
      options = { noremap = true; silent = true; };
    }
    {
      mode = "v";
      key = "k";
      action = "j";
      options = { noremap = true; silent = true; };
    }
    {
      mode = "v";
      key = "l";
      action = "k";
      options = { noremap = true; silent = true; };
    }
    {
      mode = "v";
      key = ";";
      action = "l";
      options = { noremap = true; silent = true; };
    }

    # terminal
    {
      mode = [ "t" "n" "i" "v" ];
      key = "<C-t>";
      action = "<CMD>lua require('toggleterm').toggle() <CR>";
      options = { noremap = true; silent = true; };
    }

    # flash
    {
      mode = [ "n" "x" "o" ];
      key = "s";
      action = "<CMD>lua require('flash').jump()<CR>";
      options = { noremap = true; silent = true; desc = "Flash"; };
    }
    {
      mode = [ "n" "x" "o" ];
      key = "S";
      action = "<CMD>lua require('flash').treesitter()<CR>";
      options = { noremap = true; silent = true; desc = "Flash Treesitter"; };
    }


    # bufferline
    {
      mode = [ "n" "i" "n" ];
      key = "<F1>";
      action = ":BufferPrevious<CR>";
      options = { noremap = true; silent = true; };
    }
    {
      mode = [ "n" "i" "n" ];
      key = "<F2>";
      action = ":BufferNext<CR>";
      options = { noremap = true; silent = true; };
    }

    # telescope
    {
      mode = "n";
      key = "<leader>gq";
      action = ''<CMD>lua require("telescope.builtin").git_commits()<CR>'';
      options = { desc = "Commits"; };
    }
    {
      mode = "n";
      key = "<leader>gw";
      action = ''<CMD>lua require("telescope.builtin").git_bcommits()<CR>'';
      options = { desc = "Commits in branch"; };
    }
    {
      mode = "n";
      key = "<leader>gb";
      action = ''<CMD>lua require("telescope.builtin").git_branches()<CR>'';
      options = { desc = "Git status"; };
    }
    {
      mode = "n";
      key = "<leader>gB";
      action = '':GitBlameToggle<CR>'';
      options = { desc = "Git Blame"; };
    }
    {
      mode = "n";
      key = "<leader>gs";
      action = ''<CMD>lua require("telescope.builtin").git_status()<CR>'';
      options = { desc = "Git stash"; };
    }
    {
      mode = "n";
      key = "<leader>gn";
      action = ''<CMD>lua require('neogit').neogit.open()<CR>'';
      options = { desc = "Neogit"; };
    }
    {
      mode = "n";
      key = "<leader>gg";
      action = ''<CMD>lua require("telescope.builtin").git_status()<CR>'';
      options = { desc = "Gitui"; };
    }
    {
      mode = "n";
      key = "<leader>fb";
      action = ''<CMD>lua require("telescope").extensions.file_browser.file_browser({})<CR>'';
      options = { desc = "File Browser"; };
    }
    {
      mode = "n";
      key = "<leader>ff";
      action = ''<CMD>lua require("telescope.builtin").find_files()<CR>'';
      options = { desc = "Find Files"; };
    }
    {
      mode = "n";
      key = "<leader>fg";
      action = ''<CMD>lua Live_grep_from_project_git_root()<CR>'';
      options = { desc = "Live Grep (root)"; };
    }
    {
      mode = "n";
      key = "<leader>fG";
      action = ''<CMD>lua require("telescope.builtin").live_grep()<CR>'';
      options = { desc = "Live Grep (cwd)"; };
    }
    {
      mode = "n";
      key = "<leader>fh";
      action = ''<CMD>lua require("telescope.builtin").help_tags()<CR>'';
      options = { desc = "Help"; };
    }
    {
      mode = "n";
      key = "<leader>fp";
      action = ''<CMD>lua require("telescope").extensions.project.project({})<CR>'';
      options = { desc = "Projects"; };
    }
    {
      mode = "n";
      key = "<leader>z";
      action = ''<CMD>lua require("telescope").extensions.zoxide.list({})<CR>'';
      options = { desc = "Zoxide"; };
    }

    # window movement
    {
      mode = "n";
      key = "<A-j>";
      action = ''<CMD>wincmd h<CR>'';
      options = { noremap = true; silent = true; };
    }
    {
      mode = "n";
      key = "<A-;>";
      action = ''<CMD>wincmd l<CR>'';
      options = { noremap = true; silent = true; };
    }
    {
      mode = "n";
      key = "<A-t>";
      action = ''<CMD>wincmd j<CR>'';
      options = { noremap = true; silent = true; };
    }
    {
      mode = "i";
      key = "<A-j>";
      action = ''<CMD>wincmd h<CR>'';
      options = { noremap = true; silent = true; };
    }
    {
      mode = "i";
      key = "<A-;>";
      action = ''<CMD>wincmd l<CR>'';
      options = { noremap = true; silent = true; };
    }
    {
      mode = "i";
      key = "<A-k>";
      action = ''<CMD>wincmd j<CR>'';
      options = { noremap = true; silent = true; };
    }

    # code action
    {
      mode = [ "n" "v" ];
      key = "<leader>cq";
      action = ''<CMD>lua codeAction()<CR>'';
      options = { noremap = true; silent = true; desc = "Code Action"; };
    }
    {
      mode = [ "n" "v" ];
      key = "<leader>cQ";
      action = ''<CMD>lua codeRefactor()<CR>'';
      options = { noremap = true; silent = true; desc = "Code Refactor"; };
    }


    # window movement
    {
      mode = [ "n" "i" "v" ];
      key = "<C-=>>";
      action = ''change_scale_factor(1.25)'';
    }
    {
      mode = [ "n" "i" "v" ];
      key = "<C-->";
      action = ''change_scale_factor(1 / 1.25)'';
    }

    # window movement
    {
      mode = [ "n" "i" "v" ];
      key = "<A-f>";
      action = '':Neotree toggle focus right reveal_force_cwd=true<CR>'';
      options = { desc = "File Tree"; noremap = true; silent = true; };
    }

    # lsp
    {
      mode = [ "n" "i" "v" ];
      key = "<F4>";
      action = ''<CMD>lua require("conform").format({async = true, lsp_format = "prefer"})<CR>'';
      options = { desc = "Format"; silent = true; };
    }
    {
      mode = [ "n" "v" ];
      key = "<leader>cs";
      action = ''<CMD>lua require("telescope.builtin").lsp_references()<CR>'';
      options = { desc = "Goto References"; silent = true; };
    }

    # DAP
    {
      mode = "n";
      key = "<leader>db";
      action = ''<CMD>lua require("dap").toggle_breakpoint()<CR>'';
      options = { desc = "Toggle Breakpoint"; };
    }
    {
      mode = "n";
      key = "<leader>do";
      action = ''<CMD>lua require("dap").step_over()<CR>'';
      options = { desc = "Step Over"; };
    }
    {
      mode = "n";
      key = "<leader>di";
      action = ''<CMD>lua require("dap").step_into()<CR>'';
      options = { desc = "Step Into"; };
    }
    {
      mode = "n";
      key = "<leader>dc";
      action = ''<CMD>lua debugAction()<CR>'';
      options = { desc = "Continue"; };
    }
    {
      mode = "n";
      key = "<leader>du";
      action = ''<CMD>lua require("dapui").toggle()<CR>'';
      options = { desc = "Toggle DAP UI"; };
    }
    {
      mode = "n";
      key = "<leader>de";
      action = ''<CMD>lua require("dapui").eval()<CR>'';
      options = { desc = "DAP Eval"; };
    }

    # neoscroll
    {
      mode = [ "n" "i" "v" ];
      key = "<A-l>";
      action = ''<CMD>lua require('neoscroll').ctrl_u({ duration = 250 })<CR>'';
      options = { desc = "Scroll Up"; silent = true; };
    }
    {
      mode = [ "n" "i" "v" ];
      key = "<A-k>";
      action = ''<CMD>lua require('neoscroll').ctrl_d({ duration = 250 })<CR>'';
      options = { desc = "Scroll Down"; silent = true; };
    }
    # {
    #   mode = [ "n" "i" "v" ];
    #   key = "<A-;>";
    #   action = ''<S-$>'';
    #   options = { desc = "Scroll Rigth"; silent = true; };
    # }
    # {
    #   mode = [ "n" "i" "v" ];
    #   key = "<A-j>";
    #   action = ''<S-0>'';
    #   options = { desc = "Scroll Left"; silent = true; };
    # }

    # Custom Commands
    {
      mode = "n";
      key = "by";
      action = '':BetterYank<CR>'';
      options = { desc = "BetterYank"; silent = true; };
    }
    {
      mode = "n";
      key = "bd";
      action = '':BetterDelete<CR>'';
      options = { desc = "BetterDelete"; silent = true; };
    }
  ];
  extraConfigLua = ''
    -- better yank
    function Better_yank(opts)
    	local current_line = unpack(vim.api.nvim_win_get_cursor(0))
    	vim.api.nvim_command(current_line .. "," .. (opts.count - (current_line - 1)) .. "y")
    end
    vim.api.nvim_create_user_command("BetterYank", Better_yank, { count = 1 })

    -- better delete
    function Better_delete(opts)
    	local current_line = unpack(vim.api.nvim_win_get_cursor(0))
    	vim.api.nvim_command(current_line .. "," .. (opts.count - (current_line - 1)) .. "d")
    end
    vim.api.nvim_create_user_command("BetterDelete", Better_delete, { count = 1 })

    function Get_git_root()
    	local opts = {}
    	local function is_git_repo()
    		vim.fn.system("git rev-parse --is-inside-work-tree")
    		return vim.v.shell_error == 0
    	end
    	if is_git_repo() then
    		local dot_git_path = vim.fn.finddir(".git", ".;")
    		local root = vim.fn.fnamemodify(dot_git_path, ":h")
    		opts = {
    			cwd = root,
    		}
    	end
    	return opts
    end

    function Live_grep_from_project_git_root()
    	local opts = Get_git_root()
    	require("telescope.builtin").live_grep(opts)
    end

    local change_scale_factor = function(delta)
    	vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
    end

    function debugAction()
      if vim.bo.filetype == "rust" then
        vim.cmd.RustLsp("debuggables")
      else
        require("dap").continue()
      end
    end

    function codeAction()
      if vim.bo.filetype == "rust" then
        vim.cmd.RustLsp('codeAction')
      else 
        vim.lsp.buf.code_action({
            context = {
              only = {
                "quickfix",
                "quickfix.ltex",
                "source",
                "source.fixAll",
                "source.organizeImports",
                "",
              },
            },
          })
      end 
    end
    function codeRefactor()
      vim.lsp.buf.code_action({
        context = {
          only = {
            "refactor",
            "refactor.inline",
            "refactor.extract",
            "refactor.rewrite",
          },
        },
      })
    end
  '';
}
