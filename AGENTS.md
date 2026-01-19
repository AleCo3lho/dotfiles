# AGENTS.md for Dotfiles Repository

This repository contains configuration files for various development tools and applications. It's organized by tool/application with each directory containing its respective configuration.

## Build/Lint/Test Commands

### Neovim (nvim/)

- **Lint**: `cd nvim && stylua --check .`
- **Format**: `cd nvim && stylua .`
- **Syntax Check**: `cd nvim && nvim --headless -c 'luafile init.lua'`
- **Test**: No automated tests; verify by opening Neovim and testing features
- **Single Test**: N/A

### opencode/

- **Install**: `cd opencode && npm install` or `bun install`
- **Validate**: `cd opencode && node -e "require('./opencode.json')" && echo "JSON valid"`
- **Lint**: N/A (minimal Node.js package)

### Python configs (thefuck/)

- **Syntax Check**: `cd thefuck && python -m py_compile settings.py`
- **Lint**: N/A (if installed, could use `pylint` or `flake8`)

### TOML configs (aerospace/)

- **Validate**: `python3 -c "import tomllib; tomllib.load(open('aerospace/aerospace.toml'))"`
- **Lint**: N/A

### JSON configs (karabiner/)

- **Validate**: `python3 -m json.tool karabiner/karabiner.json > /dev/null && echo "Valid"`
- **Lint**: N/A

### General validation

- **Check all JSON**: `find . -name "*.json" ! -path "*/node_modules/*" ! -path "*/.git/*" -exec python3 -m json.tool {} > /dev/null \;`

## Code Style Guidelines

### Lua (nvim/)

- **Indentation**: 2 spaces (see nvim/stylua.toml)
- **Line width**: 120 characters
- **Naming**: snake_case for variables/functions
- **Imports**: Use `require("module")` at top of files
- **Types**: Dynamic typing; no static type annotations
- **Error Handling**: Use `pcall()` for protected calls in critical sections
- **Comments**: Use `--` for single-line comments
- **Structure**: Plugin configs return tables; use `opts = function(_, opts)` for modifications
- **Best Practices**: Follow LazyVim conventions; avoid global pollution; use local variables
- **Keybindings**: Define in keymaps.lua; use `<leader>` prefix for custom keymaps

### TOML (aerospace/)

- **Indentation**: 2 spaces
- **Comments**: `#` for single-line comments
- **Key Naming**: kebab-case for sections and keys
- **Strings**: Prefer double quotes; escape quotes when needed
- **Arrays**: Square brackets `[]`; items on separate lines for readability
- **Sections**: Use `[section]` for single-level, `[[array]]` for array-of-tables

### JSON (karabiner/, opencode/)

- **Indentation**: 2 spaces
- **Quotes**: Double quotes required for keys and strings
- **Trailing commas**: Not allowed (strict JSON)
- **Naming**: camelCase for keys (karabiner convention), kebab-case (opencode)
- **Comments**: Not allowed in JSON

### Shell Scripts (tmux/plugins/, crush/)

- **Shebang**: `#!/bin/bash` or `#!/bin/sh` at top
- **Indentation**: 2 spaces
- **Quoting**: Double-quote variable expansions to prevent word splitting
- **Error Handling**: `set -e` to exit on errors, `set -u` for undefined variables
- **Functions**: snake_case function names
- **Comments**: `#` for single-line comments

### Python (thefuck/settings.py)

- **Style**: PEP 8
- **Indentation**: 4 spaces
- **Naming**: snake_case for variables/functions, UPPER_CASE for constants
- **Comments**: `#` for single-line, docstrings for modules/functions
- **Imports**: At top, grouped in standard library, third-party, local

### Configuration Files (.conf, .ini)

- **Format**: Follow tool-specific conventions
- **Comments**: Typically `#` or `;` depending on tool
- **Sections**: `[section]` for .ini format
- **Key-Value**: `key = value` or `key: value` per tool convention

## File Organization

- Each tool has its own directory: `nvim/`, `aerospace/`, `karabiner/`, `thefuck/`, `btop/`, `tmux/`, `opencode/`, etc.
- Tool-specific documentation (if any) is in each directory's README.md
- Ignore patterns: `.DS_Store`, `*.log`, caches, temporary files (see .gitignore)

## Git Conventions

- Repository: git@github.com:AleCo3lho/dotfiles.git
- Branch: main
- Commit messages: Short, descriptive (see `git log` for examples)
- Never commit secrets or sensitive data

## Plugin/Package Managers

- **nvim**: lazy.nvim (auto-managed via `nvim/lua/config/lazy.lua`)
- **tmux**: TPM (Tmux Plugin Manager) in `tmux/plugins/`
- **opencode**: npm/bun package manager
- **Node.js**: npm (for opencode dependencies)

## Validation Strategy

Most configurations are validated by the applications that use them. When making changes:

1. Verify syntax/formatting using commands above
2. Test in actual environment (reload application or configuration)
3. For Neovim: `nvim --headless` check or manual testing
4. For others: Application will typically error on invalid config

## Notes

- No automated testing framework in this repo
- Manual testing required for most configuration changes
- tmux plugins are git submodules; update with `git submodule update --remote`
- Neovim has detailed AGENTS.md in `nvim/AGENTS.md` for specific guidelines
