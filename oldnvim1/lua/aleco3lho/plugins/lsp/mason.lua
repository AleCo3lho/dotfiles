return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		-- import mason
		local mason = require("mason")

		-- import mason-lspconfig
		local mason_lspconfig = require("mason-lspconfig")

		local mason_tool_installer = require("mason-tool-installer")

		-- enable mason and configure icons
		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		mason_lspconfig.setup({
			automatic_installation = true,
			-- list of servers for mason to install
			ensure_installed = {
				"htmx",
				"tailwindcss",
				"templ",
				"yamlls",
				"taplo",
				"sqlls",
				"marksman",
				"autotools_ls",
				"helm_ls",
				"gopls",
				"docker_compose_language_service",
				"dockerls",
				"bashls",
				"ansiblels",
				"html",
				"lua_ls",
				"emmet_ls",
				"pyright",
				"terraformls",
			},
		})

		mason_tool_installer.setup({
			ensure_installed = {
				"hclfmt",
				"markdownlint",
				"prettier", -- prettier formatter
				"stylua", -- lua formatter
				"isort", -- python formatter
				"black", -- python formatter
				"eslint_d",
				"yamllint",
			},
		})
	end,
}
