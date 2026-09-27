-- Resolve the machine profile first: it sets vim.g.dotfiles_profile, which
-- plugin specs read while lazy.nvim builds its spec below.
local profile = require("config.profile")

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

profile.apply()
