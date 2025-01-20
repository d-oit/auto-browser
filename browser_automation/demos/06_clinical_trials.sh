#!/bin/bash

# Demo 6: Clinical Trials Data Extraction
# This script demonstrates advanced data extraction from clinical trials website

# Ensure we have a config file
if [ ! -f "config.yaml" ]; then
    echo "Creating config file first..."
    ../auto-browser init config.yaml
fi

# Create output directory for downloads
mkdir -p output

# Create a template for clinical trials
cat > clinical_trials_template.yaml << EOL
sites:
  clinical_trials:
    name: "Clinical Trials Demo"
    description: "Extract data from EU Clinical Trials website"
    url_pattern: "https://euclinicaltrials.eu/ctis-public/view/{trial_id}"
    selectors:
      title:
        css: "h1.trial-title"
        description: "Trial title"
      summary:
        css: "div.trial-summary"
        description: "Trial summary"
      details:
        css: "div.trial-details div"
        description: "Trial detail sections"
      download_button:
        css: "button:contains('Download clinical trial')"
        description: "Download button"
      notifications_tab:
        css: "button:has-text('Notifications')"
        description: "Notifications tab"
      serious_breach:
        css: "div:has-text('Serious Breach')"
        description: "Serious breach section"
      breach_details:
        css: ".breach-details"
        description: "Breach detail content"
EOL

# Add the template to config
cat clinical_trials_template.yaml >> config.yaml

echo "Demonstrating clinical trials data extraction..."
echo "This will:"
echo "- Navigate to a clinical trial page"
echo "- Extract trial details"
echo "- Download trial documents"
echo "- Process serious breach notifications"
echo "- Save structured data"

../auto-browser process "https://euclinicaltrials.eu/ctis-public/view/2023-509462-38-00" \
    --site clinical_trials \
    --output trial_data \
    --verbose

echo -e "\nClinical trials demonstration complete!"
echo "This shows advanced data extraction and document processing capabilities."
echo "Check the output directory for extracted data and documents."

# Clean up template
rm clinical_trials_template.yaml
