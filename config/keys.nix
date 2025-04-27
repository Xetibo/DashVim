{
  config',
  lib,
  ...
}:
lib.mkIf config'.useDefaultKeybinds {
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
        __unkeyed-1 = "<leader><b>";
        desc = "+buffers";
      }
      {
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
        __unkeyed-1 = "<leader>d";
        desc = "+debug";
      }
      {
        __unkeyed-1 = "<leader>l";
        desc = "+misc";
      }
      {
        __unkeyed-1 = "<leader>m";
        desc = "+MultiCursor";
      }
      {
        __unkeyed-1 = "<leader>s";
        desc = "+Swap";
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
      key = "<leader>ccr";
      action = "<CMD>LspRestart <CR>";
      options = {
        noremap = true;
        silent = true;
        desc = "Restart LSP";
      };
    }
    {
      mode = "n";
      key = "<leader>cm";
      action = "<CMD>lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) <CR>";
      options = {
        noremap = true;
        silent = true;
        desc = "Toggle inlay hints";
      };
    }
    {
      mode = "n";
      key = "gx";
      action = ":silent execute '!$BROWSER ' . shellescape(expand('<cfile>'), 1)<CR>";
      options = {
        noremap = true;
        silent = true;
        desc = "Execute in browser";
      };
    }

    # nvim-colorizer:ColorizerToggle
    {
      mode = "n";
      key = "<leader>lc";
      action = "<CMD>ColorizerToggle<CR>";
      options = {
        noremap = true;
        silent = true;
        desc = "Toggle colorizer";
      };
    }

    # trouble
    {
      mode = "n";
      key = "<leader>ct";
      action = "<cmd>Trouble diagnostics toggle filter.buf=0<cr>";
      options = {
        noremap = true;
        silent = true;
        desc = "Trouble";
      };
    }

    # Neotest
    {
      mode = "n";
      key = "<leader>tn";
      action = "<cmd>lua require('neotest').run.run()<cr>";
      options = {
        noremap = true;
        silent = true;
        desc = "Run nearest test";
      };
    }
    {
      mode = "n";
      key = "<leader>tf";
      action = "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<cr>";
      options = {
        noremap = true;
        silent = true;
        desc = "Run this file";
      };
    }
    {
      mode = "n";
      key = "<leader>tN";
      action = "<cmd>lua require('neotest').run.run({strategy = 'dap')<cr>";
      options = {
        noremap = true;
        silent = true;
        desc = "Debug nearest test";
      };
    }
    {
      mode = "n";
      key = "<leader>ts";
      action = "<cmd>lua require('neotest').run.stop()<cr>";
      options = {
        noremap = true;
        silent = true;
        desc = "Stop neotest";
      };
    }

    # movement
    {
      mode = "n";
      key = "j";
      action = "h";
      options = {
        noremap = true;
        silent = true;
      };
    }
    {
      mode = "n";
      key = "l";
      action = "k";
      options = {
        noremap = true;
        silent = true;
      };
    }
    {
      mode = "n";
      key = "k";
      action = "j";
      options = {
        noremap = true;
        silent = true;
      };
    }
    {
      mode = "n";
      key = ";";
      action = "l";
      options = {
        noremap = true;
        silent = true;
      };
    }
    {
      mode = "v";
      key = "j";
      action = "h";
      options = {
        noremap = true;
        silent = true;
      };
    }
    {
      mode = "v";
      key = "k";
      action = "j";
      options = {
        noremap = true;
        silent = true;
      };
    }
    {
      mode = "v";
      key = "l";
      action = "k";
      options = {
        noremap = true;
        silent = true;
      };
    }
    {
      mode = "v";
      key = ";";
      action = "l";
      options = {
        noremap = true;
        silent = true;
      };
    }

    # terminal
    {
      mode = [
        "t"
        "n"
        "i"
        "v"
      ];
      key = "<C-t>";
      action = "<CMD>lua require('toggleterm').toggle() <CR>";
      options = {
        noremap = true;
        silent = true;
      };
    }

    # flash
    {
      mode = [
        "n"
        "x"
        "o"
      ];
      key = "s";
      action = "<CMD>lua require('flash').jump()<CR>";
      options = {
        noremap = true;
        silent = true;
        desc = "Flash";
      };
    }
    {
      mode = [
        "n"
        "x"
        "o"
      ];
      key = "S";
      action = "<CMD>lua require('flash').treesitter()<CR>";
      options = {
        noremap = true;
        silent = true;
        desc = "Flash Treesitter";
      };
    }

    # bufferline
    {
      mode = [
        "n"
        "i"
        "n"
      ];
      key = "<F1>";
      action = ":BufferPrevious<CR>";
      options = {
        noremap = true;
        silent = true;
      };
    }
    {
      mode = [
        "n"
        "i"
        "n"
      ];
      key = "<F2>";
      action = ":BufferNext<CR>";
      options = {
        noremap = true;
        silent = true;
      };
    }

    # telescope
    {
      mode = "n";
      key = "<leader>gq";
      action = ''<CMD>lua require("telescope.builtin").git_commits()<CR>'';
      options = {
        desc = "Commits";
      };
    }
    {
      mode = "n";
      key = "<leader>gw";
      action = ''<CMD>lua require("telescope.builtin").git_bcommits()<CR>'';
      options = {
        desc = "Commits in branch";
      };
    }
    {
      mode = "n";
      key = "<leader>gb";
      action = ''<CMD>lua require("telescope.builtin").git_branches()<CR>'';
      options = {
        desc = "Git branches";
      };
    }
    {
      mode = "n";
      key = "<leader>gB";
      action = ":GitBlameToggle<CR>";
      options = {
        desc = "Git Blame";
      };
    }
    {
      mode = "n";
      key = "<leader>gs";
      action = ''<CMD>lua require("telescope.builtin").git_status()<CR>'';
      options = {
        desc = "Git status";
      };
    }
    {
      mode = "n";
      key = "<leader>gn";
      action = "<CMD>Neogit <CR>";
      options = {
        desc = "Neogit";
      };
    }
    {
      mode = "n";
      key = "<leader>gd";
      action = "<CMD>Neogit diff<CR>";
      options = {
        desc = "Neogit diff";
      };
    }
    {
      mode = "n";
      key = "<leader>fb";
      action = ''<CMD>lua require("telescope").extensions.file_browser.file_browser({})<CR>'';
      options = {
        desc = "File Browser";
      };
    }
    {
      mode = "n";
      key = "<leader>b";
      action = ''<CMD>lua require("telescope.builtin").buffers()<CR>'';
      options = {
        desc = "Buffers";
      };
    }
    {
      mode = "n";
      key = "<leader>ff";
      action = ''<CMD>lua require("telescope.builtin").find_files()<CR>'';
      options = {
        desc = "Find Files";
      };
    }
    {
      mode = "n";
      key = "<leader>fg";
      action = "<CMD>lua Live_grep_from_project_git_root()<CR>";
      options = {
        desc = "Live Grep (root)";
      };
    }
    {
      mode = "n";
      key = "<leader>fG";
      action = ''<CMD>lua require("telescope.builtin").live_grep()<CR>'';
      options = {
        desc = "Live Grep (cwd)";
      };
    }
    {
      mode = "n";
      key = "<leader>fh";
      action = ''<CMD>lua require("telescope.builtin").help_tags()<CR>'';
      options = {
        desc = "Help";
      };
    }
    {
      mode = "n";
      key = "<leader>fp";
      action = ''<CMD>lua require("telescope").extensions.project.project({})<CR>'';
      options = {
        desc = "Projects";
      };
    }
    {
      mode = "n";
      key = "<leader>z";
      action = ''<CMD>lua require("telescope").extensions.zoxide.list({})<CR>'';
      options = {
        desc = " Zoxide";
      };
    }
    {
      mode = "n";
      key = "<leader>y";
      action = ''<CMD>lua require('yazi').yazi()<CR>'';
      options = {
        desc = " Yazi";
      };
    }
    {
      mode = "";
      key = "<leader>/";
      action = ''<CMD>lua require("telescope.builtin").current_buffer_fuzzy_find({})<CR>'';
      options = {
        desc = "search buffer";
      };
    }

    # clasp
    # TODO enable when no longer broken
    #{
    #  mode = [
    #    "n"
    #    "i"
    #  ];
    #  key = "<C-n>";
    #  action =
    #    /*
    #    lua
    #    */
    #    ''
    #      <CMD>lua
    #        local clasp = require('clasp')
    #        clasp.setup()
    #        clasp.wrap('next')
    #      <CR>'';
    #  options = {
    #    noremap = true;
    #    silent = true;
    #    desc = "wraps next token";
    #  };
    #}
    #{
    #  mode = [
    #    "n"
    #    "i"
    #  ];
    #  key = "<C-m>";
    #  action =
    #    /*
    #    lua
    #    */
    #    ''
    #      <CMD>lua
    #        local clasp = require('clasp')
    #        clasp.setup()
    #        clasp.wrap('prev')
    #      <CR>'';
    #  options = {
    #    noremap = true;
    #    silent = true;
    #    desc = "wraps previous token";
    #  };
    #}

    # window movement
    {
      mode = "n";
      key = "<A-j>";
      action = "<CMD>wincmd h<CR>";
      options = {
        noremap = true;
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<A-;>";
      action = "<CMD>wincmd l<CR>";
      options = {
        noremap = true;
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<A-k>";
      action = "<CMD>wincmd j<CR>";
      options = {
        noremap = true;
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<A-l>";
      action = "<CMD>wincmd k<CR>";
      options = {
        noremap = true;
        silent = true;
      };
    }
    {
      mode = "i";
      key = "<A-j>";
      action = "<CMD>wincmd h<CR>";
      options = {
        noremap = true;
        silent = true;
      };
    }
    {
      mode = "i";
      key = "<A-;>";
      action = "<CMD>wincmd l<CR>";
      options = {
        noremap = true;
        silent = true;
      };
    }
    {
      mode = "i";
      key = "<A-k>";
      action = "<CMD>wincmd j<CR>";
      options = {
        noremap = true;
        silent = true;
      };
    }
    {
      mode = "i";
      key = "<A-l>";
      action = "<CMD>wincmd k<CR>";
      options = {
        noremap = true;
        silent = true;
      };
    }

    # code action
    {
      mode = [
        "n"
        "v"
      ];
      key = "<leader>cq";
      action = "<CMD>lua codeAction()<CR>";
      options = {
        noremap = true;
        silent = true;
        desc = "Code Action";
      };
    }
    {
      mode = [
        "n"
        "v"
      ];
      key = "<leader>cQ";
      action = "<CMD>lua codeRefactor()<CR>";
      options = {
        noremap = true;
        silent = true;
        desc = "Code Refactor";
      };
    }

    # Pattern.nvim
    {
      mode = [
        "n"
        "v"
      ];
      key = "<leader>p";
      action = "<CMD>Pattern()<CR>";
      options = {
        noremap = true;
        silent = true;
        desc = "Regex inspector";
      };
    }

    # Multicursor.nvim
    {
      mode = [
        "n"
        "v"
        "x"
      ];
      key = "<leader>mc";
      action =
        /*
        lua
        */
        ''
          <CMD> lua
          local mc = require('multicursor-nvim')
          function()
              if not mc.cursorsEnabled() then
                  mc.enableCursors()
              elseif mc.hasCursors() then
                  mc.clearCursors()
          end
          <CR>
        '';
      options = {
        noremap = true;
        silent = true;
        desc = "Clear all cursors";
      };
    }
    {
      mode = [
        "n"
        "v"
        "x"
      ];
      key = "<leader>mn";
      action = "<CMD> lua require('multicursor-nvim').matchSkipCursor(1)<CR>";
      options = {
        noremap = true;
        silent = true;
        desc = "Multicursor Skip 1";
      };
    }
    {
      mode = [
        "n"
        "v"
        "x"
      ];
      key = "<leader>mb";
      action = "<CMD> lua require('multicursor-nvim').restoreCursors<CR>";
      options = {
        noremap = true;
        silent = true;
        desc = "Restore cursors";
      };
    }
    {
      mode = [
        "n"
        "v"
        "x"
      ];
      key = "<leader>mn";
      action = "<CMD> lua require('multicursor-nvim').matchAddCursor(1)<CR>";
      options = {
        noremap = true;
        silent = true;
        desc = "Multicursor Add 1";
      };
    }
    {
      mode = [
        "n"
        "v"
        "x"
      ];
      key = "<leader>mo";
      action = "<CMD> lua require('multicursor-nvim').matchSkipCursor(-1)<CR>";
      options = {
        noremap = true;
        silent = true;
        desc = "Multicursor Skip -1";
      };
    }
    {
      mode = [
        "n"
        "v"
        "x"
      ];
      key = "<leader>mp";
      action = "<CMD> lua require('multicursor-nvim').matchAddCursor(-1)<CR>";
      options = {
        noremap = true;
        silent = true;
        desc = "Multicursor Add -1";
      };
    }

    # ng.nvim
    {
      mode = [
        "n"
        "v"
      ];
      key = "<leader>cgc";
      action = "<CMD>lua require('ng').goto_template_for_component()<CR>";
      options = {
        noremap = true;
        silent = true;
        desc = "Angular goto template";
      };
    }
    {
      mode = [
        "n"
        "v"
      ];
      key = "<leader>cgt";
      action = "<CMD>lua require('ng').goto_component_with_template_file()<CR>";
      options = {
        noremap = true;
        silent = true;
        desc = "Angular goto component";
      };
    }
    {
      mode = [
        "n"
        "v"
      ];
      key = "<leader>cgw";
      action = "<CMD>lua require('ng').get_template_tcb()<CR>";
      options = {
        noremap = true;
        silent = true;
        desc = "Angular template";
      };
    }

    # window movement
    {
      mode = [
        "n"
        "i"
        "v"
      ];
      key = "<C-=>>";
      action = "change_scale_factor(1.25)";
    }
    {
      mode = [
        "n"
        "i"
        "v"
      ];
      key = "<C-->";
      action = "change_scale_factor(1 / 1.25)";
    }

    # window movement
    {
      mode = [
        "n"
        "i"
        "v"
      ];
      key = "<A-f>";
      action = ":Neotree toggle focus right reveal_force_cwd=true<CR>";
      options = {
        desc = "File Tree";
        noremap = true;
        silent = true;
      };
    }

    # lsp
    {
      mode = [
        "n"
        "i"
        "v"
      ];
      key = "<F4>";
      action = ''<CMD>lua require("conform").format({async = true, lsp_format = "prefer"})<CR>'';
      options = {
        desc = "Format";
        silent = true;
      };
    }
    {
      mode = [
        "n"
        "v"
      ];
      key = "<leader>cs";
      action = ''<CMD>lua require("telescope.builtin").lsp_references()<CR>'';
      options = {
        desc = "Goto References";
        silent = true;
      };
    }
    {
      mode = [
        "n"
        "v"
      ];
      key = "<leader>fld";
      action = ''<CMD>lua require("telescope.builtin").lsp_type_definitions()<CR>'';
      options = {
        desc = "Find LSP Type Definitions";
        silent = true;
      };
    }
    {
      mode = [
        "n"
        "v"
      ];
      key = "<leader>flw";
      action = ''<CMD>lua require("telescope.builtin").lsp_workspace_symbols()<CR>'';
      options = {
        desc = "Find LSP Workspace symbols";
        silent = true;
      };
    }
    {
      mode = [
        "n"
        "v"
      ];
      key = "<leader>flw";
      action = ''<CMD>lua require("telescope.builtin").lsp_document_symbols()<CR>'';
      options = {
        desc = "Find LSP Document symbols";
        silent = true;
      };
    }

    # DAP
    {
      mode = "n";
      key = "<leader>db";
      action = ''<CMD>lua require("dap").toggle_breakpoint()<CR>'';
      options = {
        desc = "Toggle Breakpoint";
      };
    }
    {
      mode = "n";
      key = "<leader>do";
      action = ''<CMD>lua require("dap").step_over()<CR>'';
      options = {
        desc = "Step Over";
      };
    }
    {
      mode = "n";
      key = "<leader>di";
      action = ''<CMD>lua require("dap").step_into()<CR>'';
      options = {
        desc = "Step Into";
      };
    }
    {
      mode = "n";
      key = "<leader>dc";
      action = "<CMD>lua debugAction()<CR>";
      options = {
        desc = "Continue";
      };
    }
    {
      mode = "n";
      key = "<leader>du";
      action = ''<CMD>lua require("dapui").toggle()<CR>'';
      options = {
        desc = "Toggle DAP UI";
      };
    }
    {
      mode = "n";
      key = "<leader>de";
      action = ''<CMD>lua require("dapui").eval()<CR>'';
      options = {
        desc = "DAP Eval";
      };
    }

    # neoscroll
    {
      mode = [
        "n"
        "i"
        "v"
      ];
      key = "<C-l>";
      action = "<CMD>lua require('neoscroll').ctrl_u({ duration = 250 })<CR>";
      options = {
        desc = "Scroll Up";
        silent = true;
      };
    }
    {
      mode = [
        "n"
        "i"
        "v"
      ];
      key = "<C-k>";
      action = "<CMD>lua require('neoscroll').ctrl_d({ duration = 250 })<CR>";
      options = {
        desc = "Scroll Down";
        silent = true;
      };
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
      action = ":BetterYank<CR>";
      options = {
        desc = "BetterYank";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "bd";
      action = ":BetterDelete<CR>";
      options = {
        desc = "BetterDelete";
        silent = true;
      };
    }
  ];
  extraConfigLuaPre = ''
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
      --if vim.bo.filetype == "rust" then
      --  vim.cmd.RustLsp("debuggables")
      --else
        require("dap").continue()
      --end
    end

    function codeAction()
      --if vim.bo.filetype == "rust" then
      --  vim.cmd.RustLsp('codeAction')
      --else
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
      --end
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


    vim.g.neovide_scale_factor = 1.0
    local change_scale_factor = function(delta)
      vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
    end
    vim.keymap.set("n", "<C-=>", function()
      change_scale_factor(1.25)
    end)
    vim.keymap.set("n", "<C-->", function()
      change_scale_factor(1/1.25)
    end)
  '';
}
