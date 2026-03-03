#!/bin/bash

# Bootstrap script for dotfiles.
# Usage: curl -fsSL https://raw.githubusercontent.com/bkw/dotfiles/main/install.sh | bash
# Or:    git clone ... && ./install.sh

set -euo pipefail

OP_ACCOUNT="jackhuhn.1password.com"
OP_EMAIL="bkw@weisshuhn.de"

# --- 1Password CLI setup ---

if ! command -v op &>/dev/null; then
  echo "1Password CLI (op) is not installed."
  echo "Install it from https://developer.1password.com/docs/cli/get-started/"
  exit 1
fi

if ! op account list --format=json 2>/dev/null | grep -q "$OP_ACCOUNT"; then
  echo "Adding 1Password account $OP_ACCOUNT..."
  op account add --address "$OP_ACCOUNT" --email "$OP_EMAIL" </dev/tty
fi

echo "Signing in to 1Password..."
eval "$(op signin --account "$OP_ACCOUNT" </dev/tty)"

# --- chezmoi setup ---

if ! command -v chezmoi &>/dev/null; then
  echo "Installing chezmoi..."
  sh -c "$(curl -fsSL https://get.chezmoi.io)"
fi

echo "Initializing dotfiles..."
chezmoi init --apply bkw
