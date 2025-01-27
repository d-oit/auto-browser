#!/bin/bash

# Gemini LLM Provider Demo
# Shows how to use auto-browser with Google's Gemini model

# First ensure we're in the right directory
cd auto-browser || exit 1

# Install language model dependencies
# pip install -e . langchain langchain_google_genai

# Example 1: Using command line parameter to specify Gemini
echo "Example 1: Using Gemini for stock price extraction..."
auto-browser easy --provider google --model gemini-2.0-flash-exp -v "https://www.google.com/finance" "Get AAPL stock price"

# Example 2: Using Gemini for detailed data
echo -e "\nExample 2: Using Gemini for detailed market data..."
auto-browser easy --provider google --model gemini-2.0-flash-exp -v -r "https://www.google.com/finance" "Search for NVDA and get its current price and market cap"

# Example 3: Complex task with detailed report
echo -e "\nExample 3: Complex task with Gemini..."
auto-browser easy --provider google --model gemini-2.0-flash-exp -v -r "https://www.google.com/finance" "Compare the market caps and P/E ratios of AAPL, MSFT, and GOOGL. Create a summary table."

# Example 4: Interactive mode with Gemini
echo -e "\nExample 4: Interactive mode with Gemini..."
auto-browser easy --provider google --model gemini-2.0-flash-exp --interactive -v "https://www.google.com/finance" "Search for AMD stock, switch to the news tab, and extract the latest 3 news headlines"

# Return to original directory
cd - > /dev/null