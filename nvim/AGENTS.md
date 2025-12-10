# AGENTS.md for Neovim LazyVim Config

## Build/Lint/Test Commands

- **Lint**: `stylua --check .` (check formatting with stylua)
- **Format**: `stylua .` (format code with stylua)
- **Syntax Check**: `nvim --headless -c 'luafile init.lua'` (load config to check for errors)
- **Test**: No automated tests; manually verify config by opening Neovim and testing features
- **Single Test**: N/A (no test framework)

## Code Style Guidelines

- **Language**: Lua
- **Formatting**: 2 spaces indent, 120 column width (via stylua.toml)
- **Naming**: snake_case for variables/functions, camelCase for some plugin options
- **Imports**: Use `require("module")` at top of files
- **Types**: Dynamic typing; no static type annotations
- **Error Handling**: Use `pcall()` for protected calls in critical sections
- **Comments**: Use `--` for single-line comments; keep descriptive but concise
- **Structure**: Plugin configs return tables; use `opts = function(_, opts)` for modifications
- **Best Practices**: Follow LazyVim conventions; avoid global pollution; use local variables
