export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Load secrets (API keys, tokens) from gitignored file
[[ -f "$HOME/.config/.secrets" ]] && source "$HOME/.config/.secrets"

export ZSH="$HOME/.oh-my-zsh"
export ZSH_TMUX_CONFIG="$HOME/.config/tmux/tmux.conf"

ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(tmux git zsh-autosuggestions zsh-syntax-highlighting)
ZSH_TMUX_AUTONAME_SESSION=true
source $ZSH/oh-my-zsh.sh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

alias tf=terraform
alias tg=terragrunt
export PATH="$HOME/go/bin:$PATH"
JSII_SILENCE_WARNING_UNTESTED_NODE_VERSION=true

export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completio

#kubectl autocompletion
autoload -Uz compinit
compinit
source <(kubectl completion zsh)
alias k=kubectl
alias ks=kubens
alias kx=kubectx
alias reload-zsh="source ~/.zshrc"
alias edit-zsh="nvim ~/.zshrc"

# history setup
HISTFILE=$HOME/.zhistory
SAVEHIST=100000
HISTSIZE=100000
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify


# Set up fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"

# --- setup fzf theme ---
fg="#CBE0F0"
bg="#011628"
bg_highlight="#143652"
purple="#B388FF"
blue="#06BCE4"
cyan="#2CF9ED"

export FZF_DEFAULT_OPTS="--color=fg:${fg},bg:${bg},hl:${purple},fg+:${fg},bg+:${bg_highlight},hl+:${purple},info:${blue},prompt:${cyan},pointer:${cyan},marker:${cyan},spinner:${cyan},header:${cyan}"

# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

source ~/.config/fzf-git.sh

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

function prompt_xplr() {
  local -i len=$#_p9k__prompt _p9k__has_upglob
  _p9k_prompt_segment $0 6 $_p9k_color1 XPLR_ICON 0 '' ''
  (( _p9k__has_upglob )) || typeset -g "_p9k__segment_val_${_p9k__prompt_side}[_p9k__segment_index]"=$_p9k__prompt[len+1,-1]
}

_p9k_prompt_xplr_init() {
  typeset -g "_p9k__segment_cond_${_p9k__prompt_side}[_p9k__segment_index]"='$XPLR_PID'
}

function instant_prompt_xplr() {
  _p9k_prompt_segment prompt_xplr 6 $_p9k_color1 XPLR_ICON 0 '$XPLR_PID' ''
}

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

export HOMEBREW_NO_ENV_HINTS=true

# ----- Bat (better cat) -----

export BAT_THEME="TwoDark"

# ---- Eza (better ls) -----

alias ls="eza --icons=always"

# ---- Zoxide (better cd) ----
# eval "$(zoxide init zsh)"
#
# alias cd="z"
alias cat="bat"
alias n="nvim"
alias ta="tmux attach"
alias t="tmux"
export GOPATH=$HOME/go
export TEMPL_EXPERIMENT=rawgo
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH="$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools"
alias lokagitconfig='git config user.email "alexandre.ramos@loka.com" && git config user.name "Alexandre Ramos"'
export CLAUDE_CONFIG_DIR="$HOME/.claude-active"

export PATH=$PATH:$HOME/.bin:$HOME/.local
export KUBE_EDITOR='nvim'

#Backtage.io
export NODE_OPTIONS=--no-node-snapshot


eval $(thefuck --alias)

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/vault vault


export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"
export EDITOR="nvim"

export PATH="$HOME/.local/bin:$PATH"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# ---- Per-machine profile ----
# The profile name lives in ~/.config/.profile, which is gitignored, so each
# machine picks its own without the repo ever knowing about it.
DOTFILES_PROFILE=main
[[ -r "$HOME/.config/.profile" ]] && DOTFILES_PROFILE="${$(<"$HOME/.config/.profile"):-main}"
export DOTFILES_PROFILE

[[ -f "$HOME/.config/zsh/profiles/$DOTFILES_PROFILE.zsh" ]] && \
  source "$HOME/.config/zsh/profiles/$DOTFILES_PROFILE.zsh"

# Machine-local overrides, never committed. Loaded last so it wins.
[[ -f "$HOME/.config/zsh/local.zsh" ]] && source "$HOME/.config/zsh/local.zsh"
