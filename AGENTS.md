# AGENTS.md for Dotfiles Repository

This repository contains configuration files for various development tools and applications. It's organized by tool/application with each directory containing its respective configuration.

The repo is shared across machines that want different subsets of it. A **profile**
(`profiles/*.conf`, selected by the gitignored `~/.config/.profile`) controls which
Homebrew bundles install, which bootstrap steps run, which directories are checked
out, and which per-machine config variants activate. See `README.md` for the full
model before changing anything under `profiles/`, `brew/`, `lib/`, or
`aerospace/hosts/`.

**This repository is public.** Machine-specific or work-confidential values go in
gitignored files (`zsh/local.zsh`, `nvim/lua/config/local.lua`, `.secrets`), never
in a committed profile fragment.

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

- **Validate**: `for f in aerospace/hosts/*.toml; do python3 -c "import tomllib,sys; tomllib.load(open(sys.argv[1],'rb'))" "$f"; done`
- **Lint**: N/A
- **Note**: `aerospace/aerospace.toml` is a gitignored symlink to
  `aerospace/hosts/<host>.toml`. Edit the host variant, never the symlink.

### JSON configs (karabiner/)

- **Validate**: `python3 -m json.tool karabiner/karabiner.json > /dev/null && echo "Valid"`
- **Lint**: N/A

### Dotfiles test suite

- **Run**: `bash tests/test_dotfiles.sh` (add `-v` for per-assertion output)
- Validates file structure, every profile in `profiles/`, Brewfile bundles, zsh
  security/correctness, stow symlinks, and `install.sh`. No side effects.
- Note: `brew bundle check` assertions fail when packages on the machine are
  merely outdated; that is a machine state issue, not a config regression.

### Shell scripts

- **Syntax check**: `bash -n install.sh lib/profile.sh tests/test_dotfiles.sh`
- **Zsh**: `zsh -n zsh/.zshrc`

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
- Profile machinery: `profiles/*.conf` (definitions), `lib/profile.sh` (shared
  resolver, sourced by `install.sh` and the tests), `brew/*.Brewfile` (bundles).
- Per-profile config fragments: `zsh/profiles/`, `nvim/lua/config/profiles/`,
  `aerospace/hosts/`.
- `zsh/` is a stow package: anything added under it is linked into `$HOME` unless
  listed in `zsh/.stow-local-ignore`.
- Tool-specific documentation (if any) is in each directory's README.md
- Ignore patterns: `.DS_Store`, `*.log`, caches, temporary files (see .gitignore)

## Git Conventions

- Repository: git@github.com:AleCo3lho/dotfiles.git
- Branch: main
- Commit messages: Short, descriptive (see `git log` for examples)
- Never commit secrets or sensitive data

## Plugin/Package Managers

- **Homebrew**: `brew bundle` over the profile's `brew/*.Brewfile` bundles. A
  package must appear in exactly one bundle; the test suite enforces this.
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
