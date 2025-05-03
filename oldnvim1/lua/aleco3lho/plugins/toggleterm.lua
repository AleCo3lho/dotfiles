return {
	"akinsho/toggleterm.nvim",
	version = "*",
	config = function()
		local toggleterm = require("toggleterm")

		local keymap = vim.keymap -- for conciseness

		keymap.set("n", "<C-t>", function()
			toggleterm.toggle()
		end, { desc = "Open terminal" })

		keymap.set("t", "<C-t>", function()
			toggleterm.toggle()
		end, { desc = "Close terminal" })

		toggleterm.setup()
	end,
}
