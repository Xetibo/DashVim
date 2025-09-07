{
  lib,
  config',
  mkDashDefault,
  ...
}: {
  vim = lib.mkIf config'.useDefaultKeybinds {
    binds.whichKey.register =
      lib.attrsets.mapAttrs (_: mkDashDefault) {
        "<leader><b>" = "+Buffers";
        "<leader>t" = "+Neotest";
        "<leader>c" = "+Code";
        "<leader>cl" = "+Codelines";
        "<leader>g" = "+Git";
        "<leader>d" = "+Debug";
        "<leader>l" = "+Tools";
        "<leader>m" = "+Misc";
        "<leader>s" = "+Swap";
        "<leader>o" = "+Run Actions";
      }
      // {
        "<leader>a" = lib.mkIf config'.agent.enable "+CodeCompanion";
      };
    lsp.mappings = mkDashDefault {
      goToDefinition = "<leader>ca";
      goToDeclaration = "<leader>cA";
      goToType = "<leader>cd";
      hover = "<leader>ce";
      listWorkspaceSymbols = "<leader>cw";
      renameSymbol = "<leader>cr";
      openDiagnosticFloat = "<leader>cld";
      previousDiagnostic = "<leader>cp";
      nextDiagnostic = "<leader>cn";
    };
    telescope.mappings = mkDashDefault {
      lspReferences = "<leader>cs";
    };
    keymaps = [
      {
        mode = "n";
        key = "<leader>ccr";
        action = "<CMD>LspRestart <CR>";
        noremap = true;
        silent = true;
        desc = "Restart LSP";
      }
      {
        mode = "n";
        key = "<leader>cm";
        action = "<CMD>lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) <CR>";
        noremap = true;
        silent = true;
        desc = "Toggle inlay hints";
      }
      {
        mode = "n";
        key = "gx";
        action = ":silent execute '!$BROWSER ' . shellescape(expand('<cfile>'), 1)<CR>";
        noremap = true;
        silent = true;
        desc = "Execute in browser";
      }

      # nvim-colorizer:ColorizerToggle
      {
        mode = "n";
        key = "<leader>lc";
        action = "<CMD>ColorizerToggle<CR>";
        noremap = true;
        silent = true;
        desc = "Toggle colorizer";
      }

      # trouble
      {
        mode = "n";
        key = "<leader>ct";
        action = "<cmd>Trouble diagnostics toggle filter.buf=0<cr>";
        noremap = true;
        silent = true;
        desc = "Trouble";
      }

      # Overseer
      {
        mode = "n";
        key = "<leader>or";
        action = "<cmd>OverseerRun<cr>";
        noremap = true;
        silent = true;
        desc = "Run overseer picker";
      }

      # Keybind
      {
        mode = "n";
        key = "<leader>ms";
        action = "<cmd>lua require('spectre').toggle()<cr>";
        noremap = true;
        silent = true;
      }

      # movement
      {
        mode = "n";
        key = "j";
        action = "h";
        noremap = true;
        silent = true;
      }
      {
        mode = "n";
        key = "l";
        action = "k";
        noremap = true;
        silent = true;
      }
      {
        mode = "n";
        key = "k";
        action = "j";
        noremap = true;
        silent = true;
      }
      {
        mode = "n";
        key = ";";
        action = "l";
        noremap = true;
        silent = true;
      }
      {
        mode = "v";
        key = "j";
        action = "h";
        noremap = true;
        silent = true;
      }
      {
        mode = "v";
        key = "k";
        action = "j";
        noremap = true;
        silent = true;
      }
      {
        mode = "v";
        key = "l";
        action = "k";
        noremap = true;
        silent = true;
      }
      {
        mode = "v";
        key = ";";
        action = "l";
        noremap = true;
        silent = true;
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
        noremap = true;
        silent = true;
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
        noremap = true;
        silent = true;
        desc = "Flash";
      }
      {
        mode = [
          "n"
          "x"
          "o"
        ];
        key = "S";
        action = "<CMD>lua require('flash').treesitter()<CR>";
        noremap = true;
        silent = true;
        desc = "Flash Treesitter";
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
        noremap = true;
        silent = true;
      }
      {
        mode = [
          "n"
          "i"
          "n"
        ];
        key = "<F2>";
        action = ":BufferNext<CR>";
        noremap = true;
        silent = true;
      }

      # telescope
      {
        mode = "n";
        key = "<leader>gq";
        action = ''<CMD>lua require("telescope.builtin").git_commits()<CR>'';
        desc = "Commits";
      }
      {
        mode = "n";
        key = "<leader>gw";
        action = ''<CMD>lua require("telescope.builtin").git_bcommits()<CR>'';
        desc = "Commits in branch";
      }
      {
        mode = "n";
        key = "<leader>gb";
        action = ''<CMD>lua require("telescope.builtin").git_branches()<CR>'';
        desc = "Git branches";
      }
      {
        mode = "n";
        key = "<leader>gB";
        action = ":GitBlameToggle<CR>";
        desc = "Git Blame";
      }
      {
        mode = "n";
        key = "<leader>gs";
        action = ''<CMD>lua require("telescope.builtin").git_status()<CR>'';
        desc = "Git status";
      }
      {
        mode = "n";
        key = "<leader>gn";
        action = "<CMD>Neogit <CR>";
        desc = "Neogit";
      }
      {
        mode = "n";
        key = "<leader>gg";
        action = ''<CMD>lua require("telescope.builtin").git_status()<CR>'';
        desc = "Gitui";
      }
      {
        mode = "n";
        key = "<leader>fb";
        action = ''<CMD>lua require("telescope").extensions.file_browser.file_browser({})<CR>'';
        desc = "File Browser";
      }
      {
        mode = "n";
        key = "<leader>b";
        action = ''<CMD>lua require("telescope.builtin").buffers()<CR>'';
        desc = "Buffers";
      }
      {
        mode = "n";
        key = "<leader>ff";
        action = ''<CMD>lua require("telescope.builtin").find_files()<CR>'';
        desc = "Find Files";
      }
      {
        mode = "n";
        key = "<leader>fg";
        action = "<CMD>lua Live_grep_from_project_git_root()<CR>";
        desc = "Live Grep (root)";
      }
      {
        mode = "n";
        key = "<leader>fG";
        action = ''<CMD>lua require("telescope.builtin").live_grep()<CR>'';
        desc = "Live Grep (cwd)";
      }
      {
        mode = "n";
        key = "<leader>fh";
        action = ''<CMD>lua require("telescope.builtin").help_tags()<CR>'';
        desc = "Help";
      }
      {
        mode = "n";
        key = "<leader>fp";
        action = ''<CMD>lua require("telescope").extensions.project.project({})<CR>'';
        desc = "Projects";
      }
      {
        mode = "n";
        key = "<leader>z";
        action = ''<CMD>lua require("telescope").extensions.zoxide.list({})<CR>'';
        desc = "Zoxide";
      }
      {
        mode = "n";
        key = "<leader>/";
        action = ''<CMD>lua require("telescope.builtin").current_buffer_fuzzy_find({})<CR>'';
        desc = "search buffer";
      }

      # window movement
      {
        mode = "n";
        key = "<A-j>";
        action = "<CMD>wincmd h<CR>";
        noremap = true;
        silent = true;
      }
      {
        mode = "n";
        key = "<A-;>";
        action = "<CMD>wincmd l<CR>";
        noremap = true;
        silent = true;
      }
      {
        mode = "n";
        key = "<A-k>";
        action = "<CMD>wincmd j<CR>";
        noremap = true;
        silent = true;
      }
      {
        mode = "n";
        key = "<A-l>";
        action = "<CMD>wincmd k<CR>";
        noremap = true;
        silent = true;
      }
      {
        mode = "i";
        key = "<A-j>";
        action = "<CMD>wincmd h<CR>";
        noremap = true;
        silent = true;
      }
      {
        mode = "i";
        key = "<A-;>";
        action = "<CMD>wincmd l<CR>";
        noremap = true;
        silent = true;
      }
      {
        mode = "i";
        key = "<A-k>";
        action = "<CMD>wincmd j<CR>";
        noremap = true;
        silent = true;
      }
      {
        mode = "i";
        key = "<A-l>";
        action = "<CMD>wincmd k<CR>";
        noremap = true;
        silent = true;
      }

      # code action
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>cq";
        action = "<CMD>lua CodeAction()<CR>";
        noremap = true;
        silent = true;
        desc = "Code Action";
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>cQ";
        action = "<CMD>lua CodeRefactor()<CR>";
        noremap = true;
        silent = true;
        desc = "Code Refactor";
      }

      # Neotest
      {
        mode = "n";
        key = "<leader>tn";
        action = "<cmd>lua require('neotest').run.run()<cr>";
        noremap = true;
        silent = true;
        desc = "Run nearest test";
      }
      {
        mode = "n";
        key = "<leader>tf";
        action = "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<cr>";
        noremap = true;
        silent = true;
        desc = "Run this file";
      }
      {
        mode = "n";
        key = "<leader>tN";
        action = "<cmd>lua require('neotest').run.run({strategy = 'dap')<cr>";
        noremap = true;
        silent = true;
        desc = "Debug nearest test";
      }
      {
        mode = "n";
        key = "<leader>ts";
        action = "<cmd>lua require('neotest').run.stop()<cr>";
        noremap = true;
        silent = true;
        desc = "Stop neotest";
      }

      # git
      {
        mode = "n";
        key = "<leader>gh";
        action = ''<CMD>GH<CR>'';
        desc = "Github interaction";
      }
      {
        mode = "n";
        key = "<leader>ga";
        action = ''<CMD>AdoPure<CR>'';
        desc = "Azure interaction";
      }

      # ng.nvim
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>cgc";
        action = "<CMD>lua require('ng').goto_template_for_component()<CR>";
        noremap = true;
        silent = true;
        desc = "Angular goto template";
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>cgt";
        action = "<CMD>lua require('ng').goto_component_with_template_file()<CR>";
        noremap = true;
        silent = true;
        desc = "Angular goto component";
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>cgw";
        action = "<CMD>lua require('ng').get_template_tcb()<CR>";
        noremap = true;
        silent = true;
        desc = "Angular template?";
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
        desc = "File Tree";
        noremap = true;
        silent = true;
      }

      # lsp
      {
        mode = [
          "n"
          "i"
          "v"
        ];
        key = "<F4>";
        action = ''<CMD>lua require("conform").format({async = true})<CR>'';
        desc = "Format";
        silent = true;
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>cs";
        action = ''<CMD>lua require("telescope.builtin").lsp_references()<CR>'';
        desc = "Goto References";
        silent = true;
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>fld";
        action = ''<CMD>lua require("telescope.builtin").lsp_type_definitions()<CR>'';
        desc = "Find LSP Type Definitions";
        silent = true;
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>flw";
        action = ''<CMD>lua require("telescope.builtin").lsp_workspace_symbols()<CR>'';
        desc = "Find LSP Workspace symbols";
        silent = true;
      }
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>flw";
        action = ''<CMD>lua require("telescope.builtin").lsp_document_symbols()<CR>'';
        desc = "Find LSP Document symbols";
        silent = true;
      }

      # DAP
      {
        mode = "n";
        key = "<leader>db";
        action = ''<CMD>lua require("dap").toggle_breakpoint()<CR>'';
        desc = "Toggle Breakpoint";
      }
      {
        mode = "n";
        key = "<leader>do";
        action = ''<CMD>lua require("dap").step_over()<CR>'';
        desc = "Step Over";
      }
      {
        mode = "n";
        key = "<leader>di";
        action = ''<CMD>lua require("dap").step_into()<CR>'';
        desc = "Step Into";
      }
      {
        mode = "n";
        key = "<leader>dc";
        action = "<CMD>lua DebugAction()<CR>";
        desc = "Continue";
      }
      {
        mode = "n";
        key = "<leader>du";
        action = ''<CMD>lua require("debugmaster").mode.toggle()<CR>'';
        desc = "Toggle DAP UI";
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
        desc = "Scroll Up";
        silent = true;
      }
      {
        mode = [
          "n"
          "i"
          "v"
        ];
        key = "<C-k>";
        action = "<CMD>lua require('neoscroll').ctrl_d({ duration = 250 })<CR>";
        desc = "Scroll Down";
        silent = true;
      }

      # Custom Commands
      {
        mode = "n";
        key = "by";
        action = ":BetterYank<CR>";
        desc = "BetterYank";
        silent = true;
      }
      {
        mode = "n";
        key = "bd";
        action = ":BetterDelete<CR>";
        desc = "BetterDelete";
        silent = true;
      }

      # Yazi
      {
        mode = "n";
        key = "<leader>y";
        action = "<CMD>Yazi toggle<CR>";
        desc = "Yazi toggle";
        silent = true;
      }

      # Patterns
      {
        mode = "n";
        key = "<leader>mph";
        action = "<CMD>Patterns hover<CR>";
        desc = "Patterns hover";
        silent = true;
      }
      {
        mode = "n";
        key = "<leader>mpe";
        action = "<CMD>Patterns<CR>";
        desc = "Patterns";
        silent = true;
      }

      # Multicursor
      {
        mode = "n";
        key = "<leader>ma";
        action = "<CMD>lua require('multicursor-nvim').matchAddCursor(1)<CR>";
        desc = "Multicursor add match";
        silent = true;
      }
      {
        mode = "n";
        key = "<leader>ml";
        action = "<CMD>lua require('multicursor-nvim').lineAddCursor(1)<CR>";
        desc = "Multicursor add line";
        silent = true;
      }
      {
        mode = "n";
        key = "<leader>md";
        action = "<CMD>lua require('multicursor-nvim').clearCursors()<CR>";
        desc = "Multicursor clear";
        silent = true;
      }

      # Codecompanion
      (lib.mkIf config'.agent.enable {
        mode = "";
        key = "<leader>ac";
        action = ''<CMD>CodeCompanionChat<CR>'';
        desc = "CodeCompanion chat";
      })
      (lib.mkIf config'.agent.enable {
        mode = "";
        key = "<leader>aa";
        action = ''<CMD>CodeCompanionActions<CR>'';
        desc = "CodeCompanion actions";
      })
    ];
  };
}
