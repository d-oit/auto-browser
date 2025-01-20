#!/bin/bash

# Demo 3: Multiple Tab Handling
# This script demonstrates how to work with multiple browser tabs

# Ensure we have a config file
if [ ! -f "config.yaml" ]; then
    echo "Creating config file first..."
    ../auto-browser init config.yaml
fi

# Create a template for multi-tab browsing
cat > multi_tab_template.yaml << EOL
sites:
  multi_tab_demo:
    name: "Multi-Tab Demo"
    description: "Handle multiple browser tabs"
    url_pattern: "https://{domain}"
    selectors:
      page_title:
        css: "h1"
        description: "Main page title"
      tab_content:
        css: "main"
        description: "Main content area"
      new_tab_button:
        css: "button[title='Open new tab']"
        description: "New tab button"
EOL

# Add the template to config
cat multi_tab_template.yaml >> config.yaml

echo "Demonstrating multi-tab handling..."
echo "This will:"
echo "- Open multiple tabs with different content"
echo "- Switch between tabs"
echo "- Extract content from each tab"
echo "- Demonstrate tab management"

../auto-browser process "https://www.example.com" \
    --site multi_tab_demo \
    --output tab_results \
    --verbose

echo -e "\nMulti-tab demonstration complete!"
echo "This shows how to handle multiple browser tabs simultaneously."
echo -e "\nTry the next demo (04_form_interaction.sh) to see complex form interactions!"

# Clean up
rm multi_tab_template.yaml
