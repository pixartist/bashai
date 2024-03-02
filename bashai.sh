#!/bin/bash

# Concatenate all arguments to capture the full question
QUESTION="$*"

# Check for required tools and exit if any are missing
for tool in jq curl; do
  if ! command -v $tool &> /dev/null; then
    echo "Error: Required tool '$tool' is not installed."
    exit 1
  fi
done

# Check if the OPENAI_API_TOKEN environment variable is set
if [ -z "$OPENAI_API_TOKEN" ]; then
  echo "Error: OPENAI_API_TOKEN environment variable is not set."
  exit 1
fi

# Use the OPENAI_API_TOKEN environment variable for the API key
API_KEY="$OPENAI_API_TOKEN"

# GPT API URL
API_URL="https://api.openai.com/v1/chat/completions"

# Prepare the data
DATA=$(jq -n \
    --arg prompt "Provide a bash command to solve the following problem: $QUESTION. The response should be in the form of a single bash command. Do not add additional explanation. The response should work as it is when pasted into the terminal" \
    --arg role "You are a bash script generation assistant." \
    '{messages: [{role:"system", content:$role}, {role:"user", content:$prompt}], max_tokens: 600, temperature: 0.5, model: "gpt-4"}')

# Make the API request and extract the text response
RESPONSE=$(curl -s -X POST "$API_URL" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_KEY" \
    -d "$DATA" | jq -r '.choices[0].message.content')

echo $RESPONSE
