#!/bin/bash

# Demo 2: Simple Google Search Automation
# This script demonstrates basic browser automation with a Google search

# Ensure we have a config file
if [ ! -f "config.yaml" ]; then
    echo "Creating config file first..."
    ../auto-browser init config.yaml
fi

# Create a template for Google search
cat > google_template.yaml << EOL
sites:
  google_search:
    name: "Google Search"
    description: "Extract search results from Google"
    url_pattern: "https://www.google.com"
    selectors:
      search_box:
        css: "textarea[name='q']"
        description: "Google search input field"
      search_results:
        css: "div.g"
        description: "Search result entries"
        multiple: true
EOL

# Add the template to config
cat google_template.yaml >> config.yaml

echo "Performing a Google search for 'browser automation'..."
echo "This will demonstrate:"
echo "- Navigating to a website"
echo "- Interacting with a search box"
echo "- Extracting search results"

../auto-browser process "https://www.google.com" \
    --site google_search \
    --output search_results \
    --verbose

echo -e "\nSearch completed! Results have been saved."
echo "This demonstrates basic web interaction and data extraction."
echo -e "\nTry the next demo (03_multi_tab.sh) to see how to handle multiple browser tabs!"

# Clean up
rm google_template.yaml
