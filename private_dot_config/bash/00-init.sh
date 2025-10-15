# ~/.config/bash/00-init.sh
# Main initialization for interactive shells.

# Starship Prompt
eval "$(starship init bash)"

# Zoxide (smarter cd)
eval "$(zoxide init bash)"

# Direnv (per-directory environments)
eval "$(direnv hook bash)"

export PATH="$HOME/.atuin/bin:$PATH"

# Atuin (magical shell history)
eval "$(atuin init bash)"

# 1Password CLI completions
if [ -x "$(command -v op)" ]; then
  source <(op completion bash)
fi
