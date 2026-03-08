# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A chezmoi-managed dotfiles repository targeting macOS and headless Linux. Secrets come from 1Password; no secret is ever stored in the repo.

## Key Commands

```bash
chezmoi apply                  # Apply dotfiles to target machine
chezmoi apply --dry-run        # Preview changes without applying
chezmoi diff                   # Show diff between source and target
chezmoi add ~/.config/foo/bar  # Add a target file to chezmoi source
chezmoi cd                     # Open shell in source directory
chezmoi execute-template < file.tmpl  # Test template rendering
```

Bootstrap a new machine:
```bash
curl -fsSL https://raw.githubusercontent.com/bkw/dotfiles/main/install.sh | bash
```

## Architecture

### Templating & Platform Conditionals

- `.chezmoi.os` (`"darwin"` / `"linux"`) — most branching uses this
- `.chezmoi.arch` (`"arm64"` / `"amd64"`) — for binary paths (e.g., homebrew)
- `.chezmoi.hostname` (`"DoiT"` vs others) — work vs personal 1Password vaults
- Template data (`.name`, `.email`, `.signingKey`, `.githubUser`) populated from 1Password at `chezmoi init` time via `.chezmoi.toml.tmpl`

### Secrets Flow

1. `install.sh` signs into 1Password before chezmoi runs (solves chicken-and-egg)
2. `.chezmoi.toml.tmpl` reads identity data via `onepasswordRead` into `[data]`
3. Templates reference data as `.name`, `.email`, etc.
4. GPG secret key stored as 1Password document "GPG Secret Key" in "Private" vault
5. `run_once_before_setup-pass.sh.tmpl` imports GPG key and initializes `pass` on Linux

### GitHub Auth (platform split)

- **macOS**: 1Password shell plugin (`op plugin run -- gh`) with OAuth token — sourced via `op/plugins.sh`
- **Headless Linux**: `pass` + GPG — a `gh()` wrapper function injects `GH_TOKEN` per-invocation only (never exported to environment). Op shell plugins don't work headless (require desktop app for biometric unlock).

### Git Commit Signing

- Format is SSH (`gpg.format = ssh`)
- macOS: signs via 1Password app (`op-ssh-sign`)
- Linux: signs via `ssh-keygen`

### Key Tooling

- **Neovim**: LazyVim-based config at `private_dot_config/private_nvim/`
- **LazyGit**: branch prefix from `.githubUser`, at `private_dot_config/private_lazygit/`
- **Jujutsu (jj)**: alternative VCS config at `private_dot_config/private_jj/`
- **Git pager**: `delta` with `difftastic` support
- **Topgrade**: system update orchestrator (disables ruby_gems/gem)
- **ZSH framework**: Prezto (steeef prompt theme, emacs keybindings)

### External Dependencies (`.chezmoiexternal.toml.tmpl`)

- **Prezto** (zsh framework) — git-repo, weekly refresh, recursive clone
- **oh-my-tmux** — archive, weekly refresh

### ZSH Load Order

`dot_zshenv` (root) sets `ZDOTDIR`, then under `private_dot_config/private_zsh/`:
`dot_zshenv` → `dot_zprofile` (PATH, EDITOR) → `dot_zlogin` → `dot_zshrc.tmpl` (interactive: Prezto, aliases, completions, gh wrapper on Linux)

### Run Scripts

- `run_once_before_setup-pass.sh.tmpl` — Linux only: GPG key import, gpg-agent config (loopback pinentry for headless), pass init
- `run_once_install-volta.sh.tmpl` — Volta (Node version manager)
- `run_once_install-cargo-tools.sh.tmpl` — Rust toolchain + tree-sitter-cli
- `run_once_install-claude-code.sh.tmpl` — Claude Code CLI
- `run_onchange_google-cloud-sdk.sh.tmpl` — GCloud SDK (re-runs on version change)

### Chezmoi Naming Conventions

- `private_` prefix → 0700 (dirs) / 0600 (files)
- `dot_` prefix → becomes `.` in target
- `.tmpl` suffix → processed as Go template
- `run_once_` / `run_onchange_` → script execution hooks
- `run_once_before_` → runs before file operations

### XDG Compliance

All tools configured for XDG directories in `dot_zshenv`. `ZDOTDIR` is `$XDG_CONFIG_HOME/zsh`. The pass store lives at `$XDG_DATA_HOME/pass`, GNUPGHOME at `$XDG_DATA_HOME/gnupg`.

### 1Password Fallback

If 1Password is not signed in, template data fields fall back to `"pending 1password setup"`. This allows `chezmoi apply` to succeed partially without 1Password, but the resulting configs will contain placeholder values.

### Conditional Ignores (`.chezmoiignore.tmpl`)

- `README.md` and `install.sh` — always ignored (repo-only files)
- `.local/share/pass/**` — excluded on non-Linux systems

### SSH Keys

Authorized keys in `private_dot_ssh/private_authorized_keys`. Current key names: `bkw-2026`, `id_rsa`, `id_ed25519`.
