#!/bin/bash

# Demo 4: Form Interaction
# This script demonstrates complex form interactions including file uploads and input handling

# Ensure we have a config file
if [ ! -f "config.yaml" ]; then
    echo "Creating config file first..."
    ../auto-browser init config.yaml
fi

# Create a sample file for upload demonstration
mkdir -p uploads
echo "Sample content for upload" > uploads/test_file.txt

# Create a template for form interactions
cat > form_template.yaml << EOL
sites:
  form_demo:
    name: "Form Interaction Demo"
    description: "Handle complex form interactions"
    url_pattern: "https://example.com/form"
    selectors:
      text_input:
        css: "input[type='text']"
        description: "Text input field"
      email_input:
        css: "input[type='email']"
        description: "Email input field"
      file_upload:
        css: "input[type='file']"
        description: "File upload field"
      checkbox:
        css: "input[type='checkbox']"
        description: "Checkbox input"
      radio_buttons:
        css: "input[type='radio']"
        description: "Radio button options"
        multiple: true
      submit_button:
        css: "button[type='submit']"
        description: "Form submit button"
      response_message:
        css: ".response-message"
        description: "Form submission response"
EOL

# Add the template to config
cat form_template.yaml >> config.yaml

echo "Demonstrating form interactions..."
echo "This will show:"
echo "- Text input handling"
echo "- Email field validation"
echo "- File upload capabilities"
echo "- Checkbox toggling"
echo "- Radio button selection"
echo "- Form submission"
echo "- Response handling"

../auto-browser process "https://example.com/form" \
    --site form_demo \
    --output form_results \
    --verbose

echo -e "\nForm interaction demonstration complete!"
echo "This shows how to handle complex form interactions and file uploads."
echo -e "\nTry the next demo (05_parallel_tasks.sh) to see parallel task execution!"

# Clean up
rm -r uploads form_template.yaml
