function oi() {
  # Check if 1Password is signed in
  if ! op account get &>/dev/null; then
    echo "You are not signed in to 1Password. Please sign in."
    eval $(op signin)
  fi

  # Try to get the API key
  API_KEY=$(op item get ANTHROPIC_API_KEY --reveal --field credential 2>/dev/null)
  MODEL="claude-3-5-haiku-20241022"
  echo "Starting Open Interpreter with $MODEL"
# API_KEY=$(op item get OPENAI_API_KEY --reveal --field credential 2>/dev/null)
#  MODEL=""

  # Check if API key retrieval was successful
  if [ -z "$API_KEY" ]; then
    echo "Failed to retrieve the API key. Please make sure you're signed in to 1Password and the item exists."
    return 1
  fi

  # Execute interpreter using the Anthropic API key
  # uvx --from open-interpreter interpreter --model "$MODEL" -ak "$API_KEY" $args
  source ~/.oi/bin/activate
  interpreter $args --model $MODEL -ak "$API_KEY" 
}
