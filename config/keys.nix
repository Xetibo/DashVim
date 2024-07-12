{
  # which key topics
  plugins.which-key = {
    enable = true;
    registrations = {
      "g" = "+goto";
      "gz" = "+surround";
      "]" = "+next";
      "[" = "+prev";
      "<leader><tab>" = "+tabs";
      "<leader>b" = "+buffer";
      "<leader>c" = "+code";
      "<leader>cl" = "+codelines";
      "<leader>f" = "+file/find";
      "<leader>g" = "+git";
      "<leader>gh" = "+hunks";
      "<leader>q" = "+quit/session";
      "<leader>s" = "+search";
      "<leader>u" = "+ui";
      "<leader>w" = "+windows";
      "<leader>x" = "+diagnostics/quickfix";
      "<leader>h" = "+harpoon";
      "<leader>d" = "+DAP";
    };
  };
  keymaps = [
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

    # telescope
    {
      mode = "n";
      key = "<leader>gq";
      action = ''require("telescope.builtin").git_commits()'';
      options = { desc = "Commits"; };
    }
    {
      mode = "n";
      key = "<leader>gw";
      action = ''require("telescope.builtin").git_bcommits()'';
      options = { desc = "Commits in branch"; };
    }
    {
      mode = "n";
      key = "<leader>gb";
      action = ''require("telescope.builtin").git_status()'';
      options = { desc = "Git status"; };
    }
    {
      mode = "n";
      key = "<leader>gs";
      action = ''require("telescope.builtin").git_stash()'';
      options = { desc = "Git stash"; };
    }
    # {
    #   mode = "n";
    #   key = "<leader>gg";
    #   action = ''require("telescope.builtin").git_status()'';
    #   options = { desc = "Gitui"; };
    # }
    # {
    #   mode = "n";
    #   key = "<leader>gg";
    #   action = ''require("telescope.builtin").git_status()'';
    #   options = { desc = "Gitui"; };
    # }
    {
      mode = "n";
      key = "<leader>fb";
      action = ''require("telescope").extensions.file_browser.file_browser({})'';
      options = { desc = "File Browser"; };
    }
    {
      mode = "n";
      key = "<leader>ff";
      action = ''require("telescope.builtin").find_files()'';
      options = { desc = "Find Files"; };
    }
    {
      mode = "n";
      key = "<leader>fg";
      action = ''Live_grep_from_project_git_root()'';
      options = { desc = "Live Grep (root)"; };
    }
    {
      mode = "n";
      key = "<leader>fG";
      action = ''require("telescope.builtin").live_grep()'';
      options = { desc = "Live Grep (cwd)"; };
    }
    {
      mode = "n";
      key = "<leader>fh";
      action = ''require("telescope.builtin").help_tags()'';
      options = { desc = "Help"; };
    }
    {
      mode = "n";
      key = "<leader>fp";
      action = ''require("telescope").extensions.project.project({})'';
      options = { desc = "Projects"; };
    }
    {
      mode = "n";
      key = "<leader>z";
      action = ''require("telescope").extensions.zoxide.list({})'';
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
      action = '':Neotree toggle focus <CR>'';
      options = { desc = "File Tree"; noremap = true; silent = true; };
    }

    # lsp
    # {
    #   mode = ["n" "v"];
    #   key = "<F4>";
    #   action = '''';
    #   options = { desc = "Format"; };
    # }

    # neoscroll
    {
      mode = "n";
      key = "<A-l>";
      action = ''<CMD>-vim.wo.scroll true 250<CR>'';
      options = { desc = "Scroll Up"; silent = true; };
    }
    {
      mode = "n";
      key = "<A-k>";
      action = ''<CMD>vim.wo.scroll true 250<CR>'';
      options = { desc = "Scroll Down"; silent = true; };
    }

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
  '';
}
