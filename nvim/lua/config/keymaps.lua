-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local keymap = vim.keymap -- for conciseness

keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- Opencode shortcuts with leader
keymap.set("n", "<leader>oa", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask opencode" })
keymap.set("n", "<leader>ox", function() require("opencode").select() end, { desc = "Execute opencode action" })
keymap.set("n", "<leader>ot", function() require("opencode").toggle() end, { desc = "Toggle opencode" })

-- Remote file access with netrw
keymap.set("n", "<leader>er", function()
  local url = vim.fn.input("SCP URL: ", "scp://")
  vim.cmd("Explore " .. url)
end, { desc = "Browse remote files via SCP" })
