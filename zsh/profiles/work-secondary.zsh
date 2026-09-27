# Profile: work-secondary — secondary work laptop.
# Sourced from .zshrc when ~/.config/.profile contains "work-secondary".
#
# This file is committed to a public repo. Anything machine-specific or
# work-confidential belongs in zsh/local.zsh instead, which is gitignored.

# Work is the only identity here, so apply it to new repos by default rather
# than needing `lokagitconfig` in each one.
export GIT_AUTHOR_NAME="Alexandre Ramos"
export GIT_AUTHOR_EMAIL="alexandre.ramos@loka.com"
export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
