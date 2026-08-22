-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local go_group = vim.api.nvim_create_augroup("ret2hell-go-keymaps", { clear = true })

local function go_term(cmd)
	return function()
		Snacks.terminal(cmd, { cwd = LazyVim.root() })
	end
end

vim.api.nvim_create_autocmd("FileType", {
	group = go_group,
	pattern = { "go", "gomod", "gowork", "gotmpl" },
	callback = function(args)
		local function map(lhs, rhs, desc)
			vim.keymap.set("n", lhs, rhs, { buffer = args.buf, desc = desc })
		end

		map("<leader>cb", go_term({ "go", "build", "./..." }), "Go Build")
		map("<leader>ct", go_term({ "go", "mod", "tidy" }), "Go Mod Tidy")
	end,
})
