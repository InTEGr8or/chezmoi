ORANGE='\033[0;33m'  # Yellow (closest to orange in standard terminals)
RESET='\033[0m'      # Reset to default color

function aider() {
  # Check if 1Password is signed in
  if ! op account get &>/dev/null; then
    echo "You are not signed in to 1Password. Please sign in."
    eval $(op signin)
  fi

  # Try to get the API key
  API_KEY=$(op item get ANTHROPIC_API_KEY --reveal --field credential 2>/dev/null)

  # Check if API key retrieval was successful
  if [ -z "$API_KEY" ]; then
    echo "Failed to retrieve the API key. Please make sure you're signed in to 1Password and the item exists."
    return 1
  fi

  # Execute interpreter using the Anthropic API key
  uvx --from aider-chat aider --model "claude-3-5-haiku-20241022" --anthropic-api-key "$API_KEY" $args
}

function aider-env() {
  if [[ -f "./.aider.env" ]]; then
    echo "${ORANGE}The file '.aider.env' already exists.${RESET}"
    return 0
  fi
  wget https://raw.githubusercontent.com/paul-gauthier/aider/refs/heads/main/aider/website/assets/sample.env -O ./.aider.env
}
