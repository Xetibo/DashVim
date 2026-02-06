function SetupLineage()
	local lineage = require("gitlineage")
	lineage.setup({
		split = "auto",
		keymap = nil,
		keys = {
			close = "q",
			next_commit = "<leader>cn",
			prev_commit = "<leader>cp",
			yank_commit = "<leader>cy",
			open_diff = "<CR>",
		},
	})
	lineage.show_history()
end

vim.api.nvim_create_user_command("SetupLineage", SetupLineage, {})
