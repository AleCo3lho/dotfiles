#!/usr/bin/env bash
# Shared profile resolution for the dotfiles repo.
# Source this, don't execute it.

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.config}"
PROFILE_FILE="$DOTFILES_DIR/.profile"

# Reads ~/.config/.profile (gitignored) and falls back to "main".
resolve_profile_name() {
  local name=""
  if [[ -r "$PROFILE_FILE" ]]; then
    name="$(tr -d '[:space:]' < "$PROFILE_FILE")"
  fi
  printf '%s' "${name:-main}"
}

# Sources profiles/<name>.conf, exporting BREW_BUNDLES, STOW_PACKAGES,
# AEROSPACE_HOST, STEPS and SPARSE_PATHS.
load_profile() {
  DOTFILES_PROFILE="${1:-$(resolve_profile_name)}"
  local conf="$DOTFILES_DIR/profiles/$DOTFILES_PROFILE.conf"

  if [[ ! -r "$conf" ]]; then
    printf 'Unknown profile "%s". Available:\n' "$DOTFILES_PROFILE" >&2
    list_profiles >&2
    return 1
  fi

  BREW_BUNDLES=""; STOW_PACKAGES=""; AEROSPACE_HOST=""; STEPS=""; SPARSE_PATHS=""
  # shellcheck source=/dev/null
  source "$conf"
}

list_profiles() {
  local f
  for f in "$DOTFILES_DIR"/profiles/*.conf; do
    [[ -e "$f" ]] || continue
    printf '  %s\n' "$(basename "$f" .conf)"
  done
}

# True when $1 appears in the profile's STEPS list.
step_enabled() {
  [[ " $STEPS " == *" $1 "* ]]
}
