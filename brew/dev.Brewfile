# Language toolchains and build libraries.
brew "nvm"
brew "pyenv"
brew "go"
brew "zig"
brew "rustup"
# blink.cmp compiles its fuzzy matcher from source (see nvim/lua/plugins/
# blinkcmp.lua, which calls blink.cmp.build()), so cargo must exist before
# Neovim first opens. The `rust` formula is the one that links cargo/rustc into
# the brew prefix; `rustup` above only provides the rustup binary itself.
brew "rust"
brew "lua"
brew "stylua"

# Libraries
brew "openjdk"
brew "libpq"
