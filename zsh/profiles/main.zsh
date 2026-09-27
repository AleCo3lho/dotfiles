# Profile: main — primary personal machine.
# Sourced from .zshrc when ~/.config/.profile contains "main".

# Personal git identity (signed commits).
alias personalgitconfig='git config user.email "alexandre.coelho.ramos@proton.me" && git config user.name "Alexandre Coelho Ramos" && git config user.signingkey 3D410111AD01FD30BC9AA0FFCB1F052E99CDE73B && git config commit.gpgsign true && git config tag.gpgSign true'

# Raspberry Pi Pico SDK
export PICO_SDK_PATH=~/pico/pico-sdk
