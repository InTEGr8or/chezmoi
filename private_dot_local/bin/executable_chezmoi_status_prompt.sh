#!/bin/bash
# Script to check for uncommitted changes in the chezmoi git repository.

# Exit immediately if a command exits with a non-zero status.
set -e

# Define the path to the chezmoi repository.
CHEZMOI_REPO="${HOME}/.local/share/chezmoi"

# Check if the directory exists and is a git repository.
if [ -d "${CHEZMOI_REPO}/.git" ]; then
  # Use git status --porcelain to check for changes.
  # This command outputs nothing if the working tree is clean.
  if [ -n "$(git -C "${CHEZMOI_REPO}" status --porcelain)" ]; then
    # If there are changes, print a wrench icon.
    echo "🔧"
  fi
fi
