#!/bin/bash

# Magenta Sport Basketball Demo
# Automates fetching basketball games from magentasport.de using auto-browser

# Ensure we're in the right directory
cd auto-browser || exit 1

# Install dependencies if needed
# pip install -e . auto-browser-dependencies

# Example: Fetching basketball games from magentasport.de
echo "Fetching basketball games from magentasport.de..."
auto-browser easy --provider google --model gemini-2.0-flash-exp --verbose "https://www.magentasport.de/basketball" "Erlebe ausgewählte Topspiele der Turkish Airlines EuroLeague kostenlos! Scrape all basketball games under this text and navigate through all pages."

# Format the output in a markdown table
echo "Formatting output in a markdown table..."
auto-browser easy --provider google --model gemini-2.0-flash-exp --verbose "https://www.magentasport.de/basketball" "Erlebe ausgewählte Topspiele der Turkish Airlines EuroLeague kostenlos! Scrape all basketball games under this text and navigate through all pages. Format the output in a markdown table."

# Return to original directory
cd - > /dev/null