version = "1.0.0"

-- config nvim-ctrl
local home = os.getenv("HOME")
package.path = home .. "/.config/xplr/plugins/?/init.lua;" .. home .. "/.config/xplr/plugins/?.lua;" .. package.path
require("nvim-ctrl").setup({
	bin = "nvim-ctrl",
	mode = "default",
	keys = {
		["ctrl-e"] = "tabedit",
		["e"] = "e",
	},
})

-- material-landscape-theme
require("material-landscape2").setup({
	keep_default_layout = true,
})

require("web-devicons").setup()

xplr.config.node_types.extension["lua"].meta.icon = xplr.util.paint("", { fg = { Indexed = 74 } })
