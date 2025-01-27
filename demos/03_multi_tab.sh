#!/bin/bash

# Multi-tab demo
# Shows how to work with multiple stocks

# Set environment variables for OpenAI
export LLM_PROVIDER=openai
export LLM_MODEL=gpt-4-vision-preview
export OPENAI_API_KEY=$(grep OPENAI_API_KEY .env | cut -d '=' -f2)

# Compare multiple stocks
echo "Comparing tech stocks..."
auto-browser easy -v -r "https://www.google.com/finance" "Compare AAPL, MSFT, and GOOGL stock prices"

# Extract news for multiple companies
echo -e "\nGetting latest news..."
auto-browser easy -v -r "https://www.google.com/finance" "Get latest news for AAPL and TSLA"
