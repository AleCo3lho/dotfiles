#!/usr/bin/env bash
# Dotfiles test suite — validates setup without installing anything or causing side effects.
# Usage:
#   bash tests/test_dotfiles.sh        # Run all tests
#   bash tests/test_dotfiles.sh -v     # Verbose mode (show pass/fail for each test)

set -uo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.config}"
# shellcheck source=../lib/profile.sh
source "$DOTFILES_DIR/lib/profile.sh"
load_profile || { echo "Could not load profile"; exit 1; }

VERBOSE=false
[[ "${1:-}" == "-v" ]] && VERBOSE=true

PASS=0
FAIL=0

pass() {
  PASS=$((PASS + 1))
  $VERBOSE && printf '\033[32m  PASS\033[0m %s\n' "$1"
  return 0
}

fail() {
  FAIL=$((FAIL + 1))
  printf '\033[31m  FAIL\033[0m %s\n' "$1"
  return 0
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
  assert "install.sh exists and is executable" test -x "$DOTFILES_DIR/install.sh"
  assert "lib/profile.sh exists" test -f "$DOTFILES_DIR/lib/profile.sh"
  assert "zsh/.zshrc exists" test -f "$DOTFILES_DIR/zsh/.zshrc"
  assert "zsh/.p10k.zsh exists" test -f "$DOTFILES_DIR/zsh/.p10k.zsh"
  assert ".secrets.example exists" test -f "$DOTFILES_DIR/.secrets.example"
  assert ".gitignore exists" test -f "$DOTFILES_DIR/.gitignore"
  assert "wezterm/.wezterm.lua exists" test -f "$DOTFILES_DIR/wezterm/.wezterm.lua"

  local bundle
  for bundle in $BREW_BUNDLES; do
    assert "brew/$bundle.Brewfile exists and is non-empty" test -s "$DOTFILES_DIR/brew/$bundle.Brewfile"
  done
}

# ===========================
# 2. Brewfile validation
# ===========================
section_brewfile() {
  $VERBOSE && echo ""
  $VERBOSE && echo "--- Brewfile validation (profile: $DOTFILES_PROFILE) ---"

  local bundle file
  for bundle in $BREW_BUNDLES; do
    file="$DOTFILES_DIR/brew/$bundle.Brewfile"
    [[ -s "$file" ]] || continue

    if command -v brew &>/dev/null; then
      if brew bundle check --file="$file" &>/dev/null; then
        pass "brew bundle check passes for $bundle"
      else
        fail "brew bundle check fails for $bundle (some packages not installed)"
      fi
    fi

    local dupes
    dupes=$(grep -E '^(brew|cask|tap) ' "$file" | sort | uniq -d)
    if [[ -z "$dupes" ]]; then
      pass "brew/$bundle.Brewfile has no duplicate entries"
    else
      fail "brew/$bundle.Brewfile has duplicate entries: $dupes"
    fi
  done
  command -v brew &>/dev/null || { $VERBOSE && echo "  SKIP brew bundle check (brew not installed)"; }

  # A package declared in two bundles would be installed twice over.
  local cross_dupes
  cross_dupes=$(grep -hE '^(brew|cask) ' "$DOTFILES_DIR"/brew/*.Brewfile | sort | uniq -d)
  if [[ -z "$cross_dupes" ]]; then
    pass "no package is declared in more than one bundle"
  else
    fail "package declared in multiple bundles: $cross_dupes"
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
  assert_not ".zshrc has no hardcoded /Users/ paths" grep -q '/Users/' "$zshrc"

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
    setup_aerospace
    apply_sparse_checkout
    select_profile
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
# 8. Profile system
# ===========================
section_profiles() {
  $VERBOSE && echo ""
  $VERBOSE && echo "--- Profile system (active: $DOTFILES_PROFILE) ---"

  assert ".profile is gitignored" grep -qx '\.profile' "$DOTFILES_DIR/.gitignore"
  assert "aerospace/aerospace.toml is gitignored" grep -qx 'aerospace/aerospace\.toml' "$DOTFILES_DIR/.gitignore"
  assert "zsh/local.zsh is gitignored" grep -qx 'zsh/local\.zsh' "$DOTFILES_DIR/.gitignore"

  assert ".zshrc sources the active profile" \
    grep -q 'zsh/profiles/$DOTFILES_PROFILE.zsh' "$DOTFILES_DIR/zsh/.zshrc"
  assert ".zshrc sources machine-local overrides last" \
    grep -q 'zsh/local.zsh' "$DOTFILES_DIR/zsh/.zshrc"
  assert "nvim resolves the profile" test -f "$DOTFILES_DIR/nvim/lua/config/profile.lua"
  assert "nvim/init.lua wires in the profile" \
    grep -q 'require("config.profile")' "$DOTFILES_DIR/nvim/init.lua"

  # zsh/ is a stow package, so anything added under it gets linked into $HOME
  # unless explicitly ignored.
  assert "zsh package has a stow ignore list" test -f "$DOTFILES_DIR/zsh/.stow-local-ignore"
  assert_not "stow did not link zsh/profiles into \$HOME" test -e "$HOME/profiles"
  assert_not "stow did not link zsh/local.zsh into \$HOME" test -e "$HOME/local.zsh"

  # The active aerospace config must be a symlink into hosts/, not a real file,
  # otherwise a machine would silently edit the shared config.
  local link="$DOTFILES_DIR/aerospace/aerospace.toml"
  if [[ -L "$link" ]]; then
    pass "aerospace/aerospace.toml is a symlink"
    if [[ "$(readlink "$link")" == *"hosts/$AEROSPACE_HOST.toml" ]]; then
      pass "aerospace.toml points at hosts/$AEROSPACE_HOST.toml"
    else
      fail "aerospace.toml points at $(readlink "$link"), expected hosts/$AEROSPACE_HOST.toml"
    fi
  else
    fail "aerospace/aerospace.toml is not a symlink (run ./install.sh --activate)"
  fi

  # Validate every profile, not just the active one — a broken profile should
  # fail here rather than on the machine that adopts it.
  local conf name bundle host
  for conf in "$DOTFILES_DIR"/profiles/*.conf; do
    name=$(basename "$conf" .conf)
    if (
      # shellcheck source=/dev/null
      BREW_BUNDLES=""; STOW_PACKAGES=""; AEROSPACE_HOST=""; STEPS=""; SPARSE_PATHS=""
      source "$conf"
      [[ -n "$BREW_BUNDLES" && -n "$STOW_PACKAGES" && -n "$AEROSPACE_HOST" && -n "$STEPS" ]]
    ); then
      pass "profile '$name' declares all required keys"
    else
      fail "profile '$name' is missing a required key"
    fi

    # shellcheck source=/dev/null
    if ( BREW_BUNDLES=""; AEROSPACE_HOST=""; SPARSE_PATHS=""; source "$conf"
      for bundle in $BREW_BUNDLES; do
        [[ -s "$DOTFILES_DIR/brew/$bundle.Brewfile" ]] || exit 1
      done
      [[ -r "$DOTFILES_DIR/aerospace/hosts/$AEROSPACE_HOST.toml" ]] || exit 1
      [[ -f "$DOTFILES_DIR/zsh/profiles/$name.zsh" ]] || exit 1
    ); then
      pass "profile '$name' references only files that exist"
    else
      fail "profile '$name' references a missing bundle, aerospace host, or zsh fragment"
    fi
  done

  # Every aerospace host variant must be valid TOML.
  if command -v python3 &>/dev/null; then
    for host in "$DOTFILES_DIR"/aerospace/hosts/*.toml; do
      name=$(basename "$host")
      if python3 -c "import tomllib,sys; tomllib.load(open(sys.argv[1],'rb'))" "$host" 2>/dev/null; then
        pass "aerospace/hosts/$name is valid TOML"
      else
        fail "aerospace/hosts/$name is not valid TOML"
      fi
    done
  fi

  # A sparse profile that lists a nonexistent or fully-gitignored directory
  # silently materializes nothing on the machine that adopts it.
  local dir
  for dir in $SPARSE_PATHS; do
    if [[ ! -d "$DOTFILES_DIR/$dir" ]]; then
      fail "SPARSE_PATHS entry '$dir' is not a directory"
    elif [[ -z "$(git -C "$DOTFILES_DIR" ls-files --cached --others --exclude-standard -- "$dir")" ]]; then
      fail "SPARSE_PATHS entry '$dir' has no files git tracks or would track"
    else
      pass "SPARSE_PATHS entry '$dir' is checkout-able"
    fi
  done
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
  section_profiles
  section_tools_smoke

  echo ""
  echo "=============================="
  printf "Results: \033[32m%d passed\033[0m, \033[31m%d failed\033[0m\n" "$PASS" "$FAIL"
  echo "=============================="

  [[ $FAIL -eq 0 ]]
}

main
