#!/bin/bash

# Magenta Sport Basketball Demo
# Automates fetching basketball games from magentasport.de using auto-browser with Google Gemini

# Set environment variables for Google Gemini
export LLM_PROVIDER=google
export LLM_MODEL=gemini-2.0-flash-exp
export GOOGLE_API_KEY=$(grep GOOGLE_API_KEY .env | cut -d '=' -f2)

# Ensure we're in the right directory
cd auto-browser || exit 1

# Install dependencies if needed
# pip install -e . auto-browser-dependencies

# Create a template for magentasport.de/basketball
echo "Creating template for magentasport.de/basketball..."
# auto-browser create-template "https://www.magentasport.de/basketball" --name magentasport_basketball --description "Extract basketball games from Magenta Sport"

# Fetch basketball games using Google Gemini
echo "Fetching basketball games and formatting as markdown..."
auto-browser easy --provider google --model gemini-2.0-flash-exp --verbose --site magentasport_basketball "https://www.magentasport.de/basketball" "Erlebe ausgewählte Topspiele der Turkish Airlines EuroLeague kostenlos! Scrape all games after this and create a list of all basketball games. Each game should include the teams, date, time, and location."

# Return to original directory
cd - > /dev/null