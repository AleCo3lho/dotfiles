#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/.config"

# ---------- Helpers ----------
log()     { printf '\033[1;34m=> %s\033[0m\n' "$*"; }
warn()    { printf '\033[1;33m=> %s\033[0m\n' "$*"; }
success() { printf '\033[1;32m=> %s\033[0m\n' "$*"; }
fail()    { printf '\033[1;31m=> %s\033[0m\n' "$*"; exit 1; }

command_exists() { command -v "$1" &>/dev/null; }

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
  log "Installing Homebrew packages from Brewfile..."
  brew bundle --file="$DOTFILES_DIR/Brewfile"
  success "Homebrew packages installed"
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
  log "Setting up symlinks with GNU Stow..."

  # Back up existing files if they are real files (not symlinks)
  for file in .zshrc .p10k.zsh .wezterm.lua; do
    if [[ -f "$HOME/$file" && ! -L "$HOME/$file" ]]; then
      warn "Backing up ~/$file to ~/${file}.backup"
      mv "$HOME/$file" "$HOME/${file}.backup"
    fi
  done

  cd "$DOTFILES_DIR" && stow -v -t "$HOME" zsh wezterm
  success "Symlinks created"
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

# ---------- Manual Steps ----------
print_manual_steps() {
  echo ""
  success "Bootstrap complete!"
  echo ""
  log "Remaining manual steps:"
  echo "  1. Open a new terminal to load the new zsh config"
  echo "  2. Open Neovim (nvim) to trigger lazy.nvim plugin installation"
  echo "  3. In tmux, press prefix + I to install tmux plugins"
  echo "  4. Install Nerd Fonts if not already installed (required for Powerlevel10k)"
  echo "     -> https://www.nerdfonts.com/font-downloads"
  echo "  5. Fill in ~/.config/.secrets if not done yet"
  echo ""
}

# ---------- Main ----------
main() {
  log "Starting dotfiles bootstrap..."
  echo ""

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
  print_manual_steps
}

main "$@"
