return {
	"nvim-treesitter/nvim-treesitter",
	event = { "BufReadPre", "BufNewFile" },
	build = ":TSUpdate",
	dependencies = {
		"windwp/nvim-ts-autotag",
	},
	config = function()
		-- import nvim-treesitter plugin
		local treesitter = require("nvim-treesitter.configs")

		-- configure treesitter
		treesitter.setup({ -- enable syntax highlighting
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
			-- enable indentation
			indent = { enable = true },
			-- enable autotagging (w/ nvim-ts-autotag plugin)
			autotag = {
				enable = true,
			},
			-- ensure these language parsers are installed
			ensure_installed = {
				"json",
				"templ",
				"javascript",
				"typescript",
				"tsx",
				"yaml",
				"html",
				"helm",
				"markdown",
				"markdown_inline",
				"bash",
				"lua",
				"vim",
				"dockerfile",
				"go",
				"gomod",
				"gitignore",
				"bash",
				"query",
				"vimdoc",
				"hcl",
				"ssh_config",
				"sql",
				"toml",
				"terraform",
				"regex",
				"css",
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-a>",
					node_incremental = "<C-a>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},
		})
	end,
}
