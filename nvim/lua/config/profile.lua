-- Per-machine profile resolution.
--
-- The profile name lives in ~/.config/.profile (gitignored), so each machine
-- selects its own without the repo tracking which machine is which.
--
-- Two extension points:
--   * vim.g.dotfiles_profile is set before lazy.nvim loads, so plugin specs in
--     lua/plugins/ can gate themselves with, e.g.:
--         enabled = vim.g.dotfiles_profile ~= "work-secondary"
--   * lua/config/profiles/<name>.lua is loaded after lazy.nvim, for options and
--     keymaps that differ per machine.

local M = {}

local function read_profile()
  local f = io.open(vim.fn.expand("~/.config/.profile"), "r")
  if not f then
    return "main"
  end
  local name = f:read("l") or ""
  f:close()
  name = name:gsub("%s+", "")
  if name == "" then
    return "main"
  end
  return name
end

M.name = read_profile()
vim.g.dotfiles_profile = M.name

-- Loaded after lazy.nvim so profile settings can override plugin defaults.
function M.apply()
  pcall(require, "config.profiles." .. M.name)
  -- Machine-local overrides, never committed. Loaded last so it wins.
  pcall(require, "config.local")
end

return M
