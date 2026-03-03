# dotfiles

My dotfiles, managed with [chezmoi](https://www.chezmoi.io/). Secrets are stored in [1Password](https://1password.com/) and pulled into config files via chezmoi's `onepasswordRead` template function.

## Prerequisites

- [1Password CLI](https://developer.1password.com/docs/cli/get-started/) (`op`)
- [chezmoi](https://www.chezmoi.io/install/)

## Setup on a new machine

The bootstrap script handles everything: configuring 1Password, installing chezmoi, and applying the dotfiles.

```bash
curl -fsSL https://raw.githubusercontent.com/bkw/dotfiles/main/install.sh | bash
```

You will be prompted for your 1Password secret key, password, and 2FA code. After that, chezmoi pulls all config values from your vault automatically.

If you prefer to inspect the script first:

```bash
git clone https://github.com/bkw/dotfiles.git
./dotfiles/install.sh
```

## Updating

```bash
chezmoi update
```

## How it works

- `.chezmoi.toml.tmpl` detects whether 1Password is signed in
  - If yes: config values (name, email, signing key, etc.) are read from the `Private` vault
  - If no: placeholder values are written so chezmoi can complete the initial run
- `install.sh` bootstraps 1Password before invoking chezmoi, avoiding the chicken-and-egg problem
- No secrets are stored in this repository
