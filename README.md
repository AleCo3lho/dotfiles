# dotfiles

This repository *is* `~/.config`. Most tools read their config straight out of
it; `zsh` and `wezterm` are additionally symlinked into `$HOME` with GNU Stow.

It is shared across several machines that want different subsets of it, which is
what the profile system below exists for.

## Profiles

A **profile** answers two separate questions for a machine:

1. **What gets installed and materialized** — which Homebrew bundles, which
   bootstrap steps, and which directories are checked out at all.
2. **How shared configs differ** — monitor layout, git identity, per-machine
   paths.

The active profile name lives in `~/.config/.profile`, a single-line, gitignored
file. Nothing about which machine is which is ever committed.

| Profile | Machine |
| --- | --- |
| `main` | Primary personal machine. Everything enabled, full checkout. |
| `work-secondary` | Secondary work laptop. Editor/terminal/WM plus the CLI suite, single display, no personal apps, sparse checkout. |

Profiles are defined in `profiles/*.conf`:

```sh
BREW_BUNDLES="core dev infra gui"   # brew/<name>.Brewfile, in install order
STOW_PACKAGES="zsh wezterm"         # packages symlinked into $HOME
AEROSPACE_HOST="work-secondary"     # aerospace/hosts/<name>.toml to activate
STEPS="xcode homebrew brew ..."     # bootstrap steps; omit a name to skip it
SPARSE_PATHS="nvim aerospace ..."   # git sparse-checkout; empty = full tree
```

## Bootstrapping a new machine

```sh
git clone --no-checkout git@github.com:AleCo3lho/dotfiles.git ~/.config
cd ~/.config
git sparse-checkout init --cone
git sparse-checkout set lib profiles brew
git checkout main

./install.sh --profile work-secondary
```

The first `sparse-checkout set` is only enough to run the installer; `install.sh`
then expands it to the full `SPARSE_PATHS` of the chosen profile. Root-level files
are always present in cone mode, so `install.sh` does not need to be listed.

**If `~/.config` already exists** (common on a Mac that has been booted a few
times), `git clone` refuses it: *"destination path already exists and is not an
empty directory"*. Clone beside it and move the git dir in — existing contents are
preserved:

```sh
git clone --no-checkout git@github.com:AleCo3lho/dotfiles.git ~/cfgtmp
mv ~/cfgtmp/.git ~/.config/.git && rmdir ~/cfgtmp
cd ~/.config
git sparse-checkout init --cone
git sparse-checkout set lib profiles brew
git checkout main            # may need -f if a tracked path already exists
```

On a machine that already has the repo, switch or re-apply a profile with:

```sh
./install.sh --profile work-secondary   # switch profile and bootstrap
./install.sh --activate                 # re-apply wiring only, no installs
./install.sh --list                     # show available profiles
```

Run `--activate` after any `git pull` that changed `profiles/`, `brew/`, or
`aerospace/hosts/`.

## Sparse checkout

`SPARSE_PATHS` keeps large, machine-specific directories (`opencode/`,
`raycast/`, `weechat/`, `mole/`) off machines that don't want them. Measured on
the `work-secondary` profile:

| | full checkout | sparse |
| --- | --- | --- |
| working tree | ~108 MB | ~0.4 MB |
| `.git` | ~9 MB | ~9 MB |
| total | ~118 MB | ~9.6 MB |

Note that sparse-checkout shrinks the **working tree**, not `.git` — the object
store is still fetched in full. Add `--filter=blob:none` to the clone if you also
want to skip downloading blobs for excluded paths, at the cost of making the repo
fetch on demand.

Excluded paths stay in the index as skip-worktree, so commits and pushes from a
sparse machine cannot delete them.

Sparse checkout only materializes files git **tracks**. Listing a directory that
is untracked or gitignored (`gh/`, `uv/`) achieves nothing — that config simply
will not exist on the sparse machine. The test suite flags such entries.

## Per-machine differences

Three layers, in increasing order of privacy:

1. **Shared config** — `zsh/.zshrc`, `nvim/lua/`, committed, identical everywhere.
2. **Profile fragment** — committed, but only loaded by machines on that profile:
   - `zsh/profiles/<profile>.zsh`
   - `nvim/lua/config/profiles/<profile>.lua`
   - `aerospace/hosts/<host>.toml`
3. **Machine-local** — gitignored, loaded last so it always wins:
   - `zsh/local.zsh`
   - `nvim/lua/config/local.lua`
   - `.secrets` (from `.secrets.example`)

**This repository is public.** Anything work-confidential — internal hostnames,
client paths, private endpoints — belongs in layer 3, never in a profile
fragment.

### aerospace

`aerospace.toml` has no `include` mechanism, so the active config is a
gitignored **symlink** to one of the tracked variants in `aerospace/hosts/`.
`install.sh` creates it. Edit `aerospace/hosts/<host>.toml`, never the symlink
target path itself.

### nvim

`vim.g.dotfiles_profile` is set before lazy.nvim builds its spec, so plugins can
gate themselves:

```lua
{ "some/plugin", enabled = vim.g.dotfiles_profile ~= "work-secondary" }
```

Options and keymaps that differ per machine go in
`nvim/lua/config/profiles/<profile>.lua`, loaded after lazy.nvim.

## Adding a profile

1. `profiles/<name>.conf`
2. `zsh/profiles/<name>.zsh`
3. `nvim/lua/config/profiles/<name>.lua` (optional)
4. `aerospace/hosts/<host>.toml` if it needs a new display layout
5. `bash tests/test_dotfiles.sh -v` — every profile is validated, not just the
   active one

## Tests

```sh
bash tests/test_dotfiles.sh      # summary
bash tests/test_dotfiles.sh -v   # per-assertion output
```

No side effects; nothing is installed.
