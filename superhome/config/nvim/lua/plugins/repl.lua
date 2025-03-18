-- useful:
-- `vim.inspect( some_table )`
-- `vim.tbl_deep_extend("force", {}, defaults, overrides)`
-- `vim.list_extend(lhs, rhs)`
return {
	"ii14/neorepl.nvim",
	config = function()
		vim.keymap.set("n", "<Leader>z", function()
			-- get current buffer and window
			local buf = vim.api.nvim_get_current_buf()
			local win = vim.api.nvim_get_current_win()
			-- create a new split for the repl
			vim.cmd("split")
			-- spawn repl and set the context to our buffer
			require("neorepl").new({
				lang = "vim",
				buffer = buf,
				window = win,
			})
			-- resize repl window and make it fixed height
			vim.cmd("resize 10 | setl winfixheight")
		end)
	end,
}
