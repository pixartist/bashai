# Concatenate all arguments to capture the full question
$QUESTION = $args -join " "

# Check for required tools (PowerShell equivalents) and exit if any are missing
$requiredCommands = @("Invoke-RestMethod", "ConvertTo-Json")
foreach ($cmd in $requiredCommands) {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        Write-Host "Error: Required command '$cmd' is not available."
        exit 1
    }
}

# Check if the OPENAI_API_TOKEN environment variable is set
if ([string]::IsNullOrEmpty($env:OPENAI_API_TOKEN)) {
    Write-Host "Error: OPENAI_API_TOKEN environment variable is not set."
    exit 1
}

# Use the OPENAI_API_TOKEN environment variable for the API key
$API_KEY = $env:OPENAI_API_TOKEN

# GPT API URL
$API_URL = "https://api.openai.com/v1/chat/completions"

# Prepare the data
$BODY = @{
    messages = @(
        @{role="system"; content="You are a powershell script generation assistant."},
        @{role="user"; content="Provide a powershell command to solve the following problem: $QUESTION. The response should be in the form of a single powershell command. Do not add additional explanation. The response should work as it is when pasted into the powershell"}
    )
    max_tokens = 600
    temperature = 0.5
    model = "gpt-4"
} | ConvertTo-Json

# Make the API request and extract the text response
$RESPONSE = Invoke-RestMethod -Uri $API_URL -Method Post -ContentType "application/json" -Headers @{Authorization = "Bearer $API_KEY"} -Body $BODY

# Output the response
$RESPONSE.choices[0].message.content | Write-Host