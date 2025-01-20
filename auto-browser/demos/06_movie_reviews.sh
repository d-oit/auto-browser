#!/bin/bash

# Demo 6: Movie Reviews Automation
# This script demonstrates web scraping of movie reviews from Rotten Tomatoes

# Ensure we have a config file
if [ ! -f "config.yaml" ]; then
    echo "Creating config file first..."
    ../auto-browser init config.yaml
fi

# Create a template for Rotten Tomatoes
cat > movies_template.yaml << EOL
sites:
  rotten_tomatoes:
    name: "Rotten Tomatoes Movies"
    description: "Extract movie reviews from Rotten Tomatoes"
    url_pattern: "https://www.rottentomatoes.com/browse/movies_in_theaters/"
    selectors:
      movie_items:
        css: ".media-list__item"
        description: "Movie entries"
        multiple: true
      movie_title:
        css: ".media-list__title"
        description: "Movie title"
      movie_score:
        css: ".tomatometer-score"
        description: "Tomatometer score"
EOL

# Add the template to config
cat movies_template.yaml >> config.yaml

echo "Fetching latest movie reviews from Rotten Tomatoes..."
echo "This will demonstrate:"
echo "- Navigating to Rotten Tomatoes"
echo "- Extracting movie information"
echo "- Processing multiple items"

../auto-browser process "https://www.rottentomatoes.com/browse/movies_in_theaters/" \
    --site rotten_tomatoes \
    --output movie_reviews \
    --verbose

echo -e "\nReview extraction completed!"
echo "This demonstrates web scraping and data extraction capabilities."

# Clean up
rm movies_template.yaml
