return {
	"dmtrKovalenko/fff.nvim",
	build = function()
		require("fff.download").download_or_build_binary()
	end,
	lazy = false,
	keys = {
		{ "<leader><space>", function() require("fff").find_files() end, desc = "Find Files (FFF)" },
		{ "<leader>ff", function() require("fff").find_files() end, desc = "Find Files (FFF)" },
		{ "<leader>fF", function() require("fff").find_files_in_dir(vim.fn.getcwd()) end, desc = "Find Files (cwd, FFF)" },
		{ "<leader>sg", function() require("fff").live_grep() end, desc = "Grep (FFF)" },
		{
			"<leader>sw",
			function()
				require("fff").live_grep({ query = vim.fn.expand("<cword>") })
			end,
			desc = "Word (FFF)",
		},
		{
			"<leader>sG",
			function()
				require("fff").live_grep({ grep = { modes = { "fuzzy", "plain" } } })
			end,
			desc = "Fuzzy Grep (FFF)",
		},
	},
	opts = {
		lazy_sync = true,
		prompt_vim_mode = true,
		layout = {
			prompt_position = "top",
			preview_position = "right",
		},
		preview = {
			line_numbers = true,
		},
	},
}
