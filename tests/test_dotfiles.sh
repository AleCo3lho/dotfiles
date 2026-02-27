#!/usr/bin/env bash
# Dotfiles test suite — validates setup without installing anything or causing side effects.
# Usage:
#   bash tests/test_dotfiles.sh        # Run all tests
#   bash tests/test_dotfiles.sh -v     # Verbose mode (show pass/fail for each test)

set -uo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.config}"
VERBOSE=false
[[ "${1:-}" == "-v" ]] && VERBOSE=true

PASS=0
FAIL=0

pass() {
  PASS=$((PASS + 1))
  $VERBOSE && printf '\033[32m  PASS\033[0m %s\n' "$1"
}

fail() {
  FAIL=$((FAIL + 1))
  printf '\033[31m  FAIL\033[0m %s\n' "$1"
}

assert() {
  local desc="$1"; shift
  if "$@" &>/dev/null; then
    pass "$desc"
  else
    fail "$desc"
  fi
}

assert_not() {
  local desc="$1"; shift
  if "$@" &>/dev/null; then
    fail "$desc"
  else
    pass "$desc"
  fi
}

# ===========================
# 1. File structure tests
# ===========================
section_file_structure() {
  $VERBOSE && echo ""
  $VERBOSE && echo "--- File structure ---"
  assert "Brewfile exists and is non-empty" test -s "$DOTFILES_DIR/Brewfile"
  assert "install.sh exists and is executable" test -x "$DOTFILES_DIR/install.sh"
  assert "zsh/.zshrc exists" test -f "$DOTFILES_DIR/zsh/.zshrc"
  assert "zsh/.p10k.zsh exists" test -f "$DOTFILES_DIR/zsh/.p10k.zsh"
  assert ".secrets.example exists" test -f "$DOTFILES_DIR/.secrets.example"
  assert ".gitignore exists" test -f "$DOTFILES_DIR/.gitignore"
  assert "wezterm/.wezterm.lua exists" test -f "$DOTFILES_DIR/wezterm/.wezterm.lua"
}

# ===========================
# 2. Brewfile validation
# ===========================
section_brewfile() {
  $VERBOSE && echo ""
  $VERBOSE && echo "--- Brewfile validation ---"

  if command -v brew &>/dev/null; then
    if brew bundle check --file="$DOTFILES_DIR/Brewfile" &>/dev/null; then
      pass "brew bundle check passes"
    else
      fail "brew bundle check fails (some packages not installed)"
    fi
  else
    $VERBOSE && echo "  SKIP brew bundle check (brew not installed)"
  fi

  # Check for duplicate entries
  local dupes
  dupes=$(grep -E '^(brew|cask|tap) ' "$DOTFILES_DIR/Brewfile" | sort | uniq -d)
  if [[ -z "$dupes" ]]; then
    pass "Brewfile has no duplicate entries"
  else
    fail "Brewfile has duplicate entries: $dupes"
  fi
}

# ===========================
# 3. Zsh config security
# ===========================
section_zsh_security() {
  $VERBOSE && echo ""
  $VERBOSE && echo "--- Zsh config security ---"

  local zshrc="$DOTFILES_DIR/zsh/.zshrc"

  # No hardcoded secrets
  assert_not ".zshrc does not contain sk-proj- patterns" grep -q 'sk-proj-' "$zshrc"
  assert_not ".zshrc does not contain ghp_ patterns" grep -q 'ghp_' "$zshrc"
  assert_not ".zshrc does not contain hardcoded OPENAI_API_KEY value" grep -qE 'OPENAI_API_KEY=.+[A-Za-z0-9]{20}' "$zshrc"

  # Sources secrets file
  assert ".zshrc sources \$HOME/.config/.secrets" grep -q 'source "$HOME/.config/.secrets"' "$zshrc"

  # .secrets in gitignore
  assert ".secrets is listed in .gitignore" grep -q '^\.secrets$' "$DOTFILES_DIR/.gitignore"

  # .secrets.example has all required variables
  local example="$DOTFILES_DIR/.secrets.example"
  assert ".secrets.example has OPENAI_API_KEY" grep -q 'OPENAI_API_KEY' "$example"
  assert ".secrets.example has GITHUB_TOKEN" grep -q 'GITHUB_TOKEN' "$example"
  assert ".secrets.example has GITHUB_CLIENTID" grep -q 'GITHUB_CLIENTID' "$example"
  assert ".secrets.example has GITHUB_CLIENTSECRET" grep -q 'GITHUB_CLIENTSECRET' "$example"
}

# ===========================
# 4. Zsh config correctness
# ===========================
section_zsh_correctness() {
  $VERBOSE && echo ""
  $VERBOSE && echo "--- Zsh config correctness ---"

  local zshrc="$DOTFILES_DIR/zsh/.zshrc"

  # No hardcoded user paths
  assert_not ".zshrc has no hardcoded /Users/alexandrecoelho/ paths" grep -q '/Users/alexandrecoelho/' "$zshrc"

  # Expected plugins
  assert ".zshrc references tmux plugin" grep -qE 'plugins=.*tmux' "$zshrc"
  assert ".zshrc references git plugin" grep -qE 'plugins=.*git' "$zshrc"
  assert ".zshrc references zsh-autosuggestions plugin" grep -qE 'plugins=.*zsh-autosuggestions' "$zshrc"
  assert ".zshrc references zsh-syntax-highlighting plugin" grep -qE 'plugins=.*zsh-syntax-highlighting' "$zshrc"

  # Theme
  assert ".zshrc sets ZSH_THEME to powerlevel10k" grep -q 'ZSH_THEME="powerlevel10k/powerlevel10k"' "$zshrc"
}

# ===========================
# 5. Stow symlink tests
# ===========================
section_stow_symlinks() {
  $VERBOSE && echo ""
  $VERBOSE && echo "--- Stow symlinks ---"

  if [[ -L "$HOME/.zshrc" ]]; then
    local target
    target=$(readlink "$HOME/.zshrc")
    if [[ "$target" == *".config/zsh/.zshrc" ]]; then
      pass "~/.zshrc symlink points to .config/zsh/.zshrc"
    else
      fail "~/.zshrc symlink points to $target (expected .config/zsh/.zshrc)"
    fi
  else
    fail "~/.zshrc is not a symlink"
  fi

  if [[ -L "$HOME/.p10k.zsh" ]]; then
    local target
    target=$(readlink "$HOME/.p10k.zsh")
    if [[ "$target" == *".config/zsh/.p10k.zsh" ]]; then
      pass "~/.p10k.zsh symlink points to .config/zsh/.p10k.zsh"
    else
      fail "~/.p10k.zsh symlink points to $target (expected .config/zsh/.p10k.zsh)"
    fi
  else
    fail "~/.p10k.zsh is not a symlink"
  fi

  if [[ -L "$HOME/.wezterm.lua" ]]; then
    local target
    target=$(readlink "$HOME/.wezterm.lua")
    if [[ "$target" == *".config/wezterm/.wezterm.lua" ]]; then
      pass "~/.wezterm.lua symlink points to .config/wezterm/.wezterm.lua"
    else
      fail "~/.wezterm.lua symlink points to $target (expected .config/wezterm/.wezterm.lua)"
    fi
  else
    fail "~/.wezterm.lua is not a symlink"
  fi
}

# ===========================
# 6. install.sh validation
# ===========================
section_install_script() {
  $VERBOSE && echo ""
  $VERBOSE && echo "--- install.sh validation ---"

  local script="$DOTFILES_DIR/install.sh"

  # shellcheck
  if command -v shellcheck &>/dev/null; then
    if shellcheck "$script" 2>/dev/null; then
      pass "install.sh passes shellcheck"
    else
      fail "install.sh has shellcheck warnings"
    fi
  else
    $VERBOSE && echo "  SKIP shellcheck (not installed)"
  fi

  # set -euo pipefail
  assert "install.sh uses set -euo pipefail" grep -q 'set -euo pipefail' "$script"

  # Expected functions
  local funcs=(
    install_xcode_cli_tools
    install_homebrew
    install_brew_packages
    setup_zsh_framework
    setup_stow_symlinks
    setup_tpm
    setup_node
    setup_python
    setup_rust
    setup_secrets
  )
  for fn in "${funcs[@]}"; do
    assert "install.sh defines $fn" grep -q "^${fn}()" "$script"
  done

  # Idempotency guards — each install function should check before acting
  assert "install_xcode_cli_tools has guard" grep -A5 'install_xcode_cli_tools()' "$script" | grep -q 'xcode-select -p'
  assert "install_homebrew has guard" grep -A5 'install_homebrew()' "$script" | grep -q 'command_exists brew'
  assert "setup_zsh_framework has guard" grep -A5 'setup_zsh_framework()' "$script" | grep -q '\.oh-my-zsh'
  assert "setup_tpm has guard" grep -A5 'setup_tpm()' "$script" | grep -q 'TPM_DIR'
  assert "setup_node has guard" grep -A10 'setup_node()' "$script" | grep -q 'command_exists node'
  assert "setup_python has guard" grep -A10 'setup_python()' "$script" | grep -q 'pyenv versions'
  assert "setup_rust has guard" grep -A5 'setup_rust()' "$script" | grep -q 'command_exists rustc'
  assert "setup_secrets has guard" grep -A5 'setup_secrets()' "$script" | grep -q '\.secrets'
}

# ===========================
# 7. Installed tools smoke test
# ===========================
section_tools_smoke() {
  $VERBOSE && echo ""
  $VERBOSE && echo "--- Installed tools smoke test ---"

  local tools=(brew git nvim tmux fzf fd bat eza btop rg stow xplr go zig lua stylua terraform kubectl kubens kubectx vault)
  for tool in "${tools[@]}"; do
    if command -v "$tool" &>/dev/null; then
      pass "$tool is available on PATH"
    else
      $VERBOSE && echo "  SKIP $tool (not installed)"
    fi
  done

  # nvm / node
  export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh" 2>/dev/null
  if command -v node &>/dev/null; then
    pass "node is available (via nvm)"
  else
    $VERBOSE && echo "  SKIP node (not installed or nvm not loaded)"
  fi

  # pyenv
  if command -v pyenv &>/dev/null; then
    if pyenv versions --bare 2>/dev/null | head -1 | grep -q .; then
      pass "pyenv has at least one Python version installed"
    else
      $VERBOSE && echo "  SKIP pyenv has no Python versions"
    fi
  else
    $VERBOSE && echo "  SKIP pyenv (not installed)"
  fi
}

# ===========================
# Run all sections
# ===========================
main() {
  echo "Running dotfiles tests..."
  echo ""

  section_file_structure
  section_brewfile
  section_zsh_security
  section_zsh_correctness
  section_stow_symlinks
  section_install_script
  section_tools_smoke

  echo ""
  echo "=============================="
  printf "Results: \033[32m%d passed\033[0m, \033[31m%d failed\033[0m\n" "$PASS" "$FAIL"
  echo "=============================="

  [[ $FAIL -eq 0 ]]
}

main
