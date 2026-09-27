#!/usr/bin/env bash
set -euo pipefail

# Derive from this script's own location so the repo works wherever it is
# cloned (normally ~/.config) and so the bootstrap can be tested out of place.
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DOTFILES_DIR/lib/profile.sh"

# ---------- Helpers ----------
log()     { printf '\033[1;34m=> %s\033[0m\n' "$*"; }
warn()    { printf '\033[1;33m=> %s\033[0m\n' "$*"; }
success() { printf '\033[1;32m=> %s\033[0m\n' "$*"; }
skip()    { printf '\033[1;30m=> skip %s (not in profile)\033[0m\n' "$*"; }
fail()    { printf '\033[1;31m=> %s\033[0m\n' "$*"; exit 1; }

command_exists() { command -v "$1" &>/dev/null; }

usage() {
  cat <<EOF
Usage: ./install.sh [--profile NAME] [--activate] [--list]

  --profile NAME  Use profile NAME and persist it to ~/.config/.profile.
                  Defaults to whatever that file already contains, else "main".
  --activate      Skip package installation; only (re)apply profile wiring:
                  sparse-checkout, stow symlinks and the aerospace host config.
                  Run this after a "git pull" that changed profiles/.
  --list          List available profiles and exit.

Profiles live in profiles/*.conf.
EOF
}

# ---------- Argument parsing ----------
REQUESTED_PROFILE=""
ACTIVATE_ONLY=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile) REQUESTED_PROFILE="${2:-}"; [[ -n "$REQUESTED_PROFILE" ]] || fail "--profile needs a name"; shift 2 ;;
    --profile=*) REQUESTED_PROFILE="${1#*=}"; shift ;;
    --activate) ACTIVATE_ONLY=true; shift ;;
    --list) list_profiles; exit 0 ;;
    -h|--help) usage; exit 0 ;;
    *) fail "Unknown argument: $1 (try --help)" ;;
  esac
done

# ---------- Profile selection ----------
select_profile() {
  if [[ -n "$REQUESTED_PROFILE" ]]; then
    load_profile "$REQUESTED_PROFILE" || exit 1
    printf '%s\n' "$DOTFILES_PROFILE" > "$PROFILE_FILE"
    log "Profile set to '$DOTFILES_PROFILE' (recorded in $PROFILE_FILE)"
  else
    load_profile || exit 1
    log "Using profile '$DOTFILES_PROFILE'"
    [[ -r "$PROFILE_FILE" ]] || warn "No $PROFILE_FILE yet; defaulting to 'main'. Use --profile to pin it."
  fi
}

# ---------- Sparse checkout ----------
apply_sparse_checkout() {
  if [[ -z "$SPARSE_PATHS" ]]; then
    if git -C "$DOTFILES_DIR" config --get core.sparseCheckout &>/dev/null; then
      log "Profile wants the full tree; disabling sparse-checkout..."
      git -C "$DOTFILES_DIR" sparse-checkout disable
    fi
    return
  fi

  log "Applying sparse-checkout for profile '$DOTFILES_PROFILE'..."
  git -C "$DOTFILES_DIR" sparse-checkout init --cone
  # shellcheck disable=SC2086
  git -C "$DOTFILES_DIR" sparse-checkout set $SPARSE_PATHS
  success "Materialized: $SPARSE_PATHS"
}

# ---------- Xcode CLI Tools ----------
install_xcode_cli_tools() {
  if xcode-select -p &>/dev/null; then
    log "Xcode CLI tools already installed"
    return
  fi
  log "Installing Xcode CLI tools..."
  xcode-select --install
  echo "Press enter once Xcode CLI tools installation is complete."
  read -r
}

# ---------- Homebrew ----------
install_homebrew() {
  if command_exists brew; then
    log "Homebrew already installed"
    return
  fi
  log "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add Homebrew to PATH for the rest of this script
  eval "$(/opt/homebrew/bin/brew shellenv)"
}

# ---------- Brew Packages ----------
install_brew_packages() {
  local bundle file
  for bundle in $BREW_BUNDLES; do
    file="$DOTFILES_DIR/brew/$bundle.Brewfile"
    [[ -r "$file" ]] || fail "Profile references missing bundle: brew/$bundle.Brewfile"
    log "Installing Homebrew bundle '$bundle'..."
    brew bundle --file="$file"
  done
  success "Homebrew bundles installed: $BREW_BUNDLES"
}

# ---------- Oh-My-Zsh + Plugins ----------
setup_zsh_framework() {
  local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    log "Installing Oh-My-Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
  else
    log "Oh-My-Zsh already installed"
  fi

  if [[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
    log "Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
  else
    log "Powerlevel10k already installed"
  fi

  if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    log "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  else
    log "zsh-autosuggestions already installed"
  fi

  if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
    log "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
  else
    log "zsh-syntax-highlighting already installed"
  fi
}

# ---------- GNU Stow Symlinks ----------
setup_stow_symlinks() {
  [[ -n "$STOW_PACKAGES" ]] || { log "No stow packages for this profile"; return; }
  log "Setting up symlinks with GNU Stow..."

  # Back up existing files if they are real files (not symlinks)
  for file in .zshrc .p10k.zsh .wezterm.lua; do
    if [[ -f "$HOME/$file" && ! -L "$HOME/$file" ]]; then
      warn "Backing up ~/$file to ~/${file}.backup"
      mv "$HOME/$file" "$HOME/${file}.backup"
    fi
  done

  # shellcheck disable=SC2086
  (cd "$DOTFILES_DIR" && stow -v -t "$HOME" $STOW_PACKAGES)
  success "Symlinks created for: $STOW_PACKAGES"
}

# ---------- Aerospace host config ----------
# aerospace.toml has no include mechanism, so the active config is a gitignored
# symlink to one of the tracked variants in aerospace/hosts/.
setup_aerospace() {
  local target="$DOTFILES_DIR/aerospace/hosts/$AEROSPACE_HOST.toml"
  local link="$DOTFILES_DIR/aerospace/aerospace.toml"

  [[ -r "$target" ]] || fail "Missing aerospace host config: aerospace/hosts/$AEROSPACE_HOST.toml"

  if [[ -f "$link" && ! -L "$link" ]]; then
    warn "Backing up existing aerospace.toml to aerospace.toml.backup"
    mv "$link" "$link.backup"
  fi

  ln -sfn "$target" "$link"
  success "aerospace.toml -> hosts/$AEROSPACE_HOST.toml"
}

# ---------- TPM (Tmux Plugin Manager) ----------
setup_tpm() {
  local TPM_DIR="$HOME/.config/tmux/plugins/tpm"
  if [[ -d "$TPM_DIR" ]]; then
    log "TPM already installed"
    return
  fi
  log "Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
  log "Installing tmux plugins..."
  "$TPM_DIR/bin/install_plugins" || true
}

# ---------- Node.js (via nvm) ----------
setup_node() {
  export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"

  if command_exists node; then
    log "Node.js already installed: $(node --version)"
    return
  fi
  log "Installing Node.js LTS via nvm..."
  nvm install --lts
  success "Node.js installed: $(node --version)"
}

# ---------- Python (via pyenv) ----------
setup_python() {
  export PYENV_ROOT="$HOME/.pyenv"
  [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)" 2>/dev/null || true

  if pyenv versions --bare | head -1 | grep -q .; then
    log "Python already installed via pyenv: $(pyenv versions --bare | head -1)"
    return
  fi
  log "Installing latest Python via pyenv..."
  local latest
  latest=$(pyenv install --list | grep -E '^\s+[0-9]+\.[0-9]+\.[0-9]+$' | tail -1 | tr -d ' ')
  pyenv install "$latest"
  pyenv global "$latest"
  success "Python $latest installed"
}

# ---------- Rust (via rustup) ----------
setup_rust() {
  if command_exists rustc; then
    log "Rust already installed: $(rustc --version)"
    return
  fi
  log "Installing Rust via rustup..."
  rustup-init -y --no-modify-path
  source "$HOME/.cargo/env"
  success "Rust installed: $(rustc --version)"
}

# ---------- Secrets ----------
setup_secrets() {
  if [[ -f "$DOTFILES_DIR/.secrets" ]]; then
    log "Secrets file already exists"
    return
  fi
  log "Creating secrets file from template..."
  cp "$DOTFILES_DIR/.secrets.example" "$DOTFILES_DIR/.secrets"
  warn "Fill in your secrets at $DOTFILES_DIR/.secrets"
}

# ---------- Step dispatch ----------
# Each step runs only if its name is listed in the profile's STEPS.
run_step() {
  local name="$1" fn="$2"
  if step_enabled "$name"; then
    "$fn"
  else
    skip "$name"
  fi
}

# ---------- Manual Steps ----------
print_manual_steps() {
  echo ""
  success "Bootstrap complete for profile '$DOTFILES_PROFILE'!"
  echo ""
  log "Remaining manual steps:"
  echo "  1. Open a new terminal to load the new zsh config"
  echo "  2. Open Neovim (nvim) to trigger lazy.nvim plugin installation"
  echo "  3. In tmux, press prefix + I to install tmux plugins"
  echo "  4. Install Nerd Fonts if not already installed (required for Powerlevel10k)"
  echo "     -> https://www.nerdfonts.com/font-downloads"
  echo "  5. Fill in ~/.config/.secrets if not done yet"
  echo "  6. Machine-local tweaks that should never be committed go in:"
  echo "     ~/.config/zsh/local.zsh and ~/.config/nvim/lua/config/local.lua"
  echo ""
}

# ---------- Main ----------
main() {
  select_profile

  if [[ "$ACTIVATE_ONLY" == true ]]; then
    log "Activate-only: applying profile wiring, skipping installs"
    apply_sparse_checkout
    run_step stow setup_stow_symlinks
    run_step aerospace setup_aerospace
    success "Profile '$DOTFILES_PROFILE' activated"
    return
  fi

  log "Starting dotfiles bootstrap..."
  echo ""

  apply_sparse_checkout
  run_step xcode         install_xcode_cli_tools
  run_step homebrew      install_homebrew
  run_step brew          install_brew_packages
  run_step zsh_framework setup_zsh_framework
  run_step stow          setup_stow_symlinks
  run_step aerospace     setup_aerospace
  run_step tpm           setup_tpm
  run_step node          setup_node
  run_step python        setup_python
  run_step rust          setup_rust
  run_step secrets       setup_secrets
  print_manual_steps
}

main "$@"
