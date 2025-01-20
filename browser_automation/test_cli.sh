#!/bin/bash

# Exit on error
set -e

# Function to print colored output
print_header() {
    echo -e "\n\033[1;34m$1\033[0m"
}

print_success() {
    echo -e "\033[1;32m$1\033[0m"
}

print_error() {
    echo -e "\033[1;31m$1\033[0m"
}

# Create output directory if it doesn't exist
mkdir -p output

# Install dependencies
# print_header "Installing dependencies..."
# pip install -e .

# Test basic site listing
print_header "Testing site listing..."
PYTHONPATH=src python -m browser_automation.cli --config config.yaml list-sites

# Test Wikipedia article processing without verbose output
print_header "Testing Wikipedia article processing (non-verbose)..."
PYTHONPATH=src python -m browser_automation.cli --config config.yaml process "https://en.wikipedia.org/wiki/Python_(programming_language)" --site wiki
print_success "Non-verbose test completed"

# Test Wikipedia article processing with verbose output
print_header "Testing Wikipedia article processing (verbose)..."
PYTHONPATH=src python -m browser_automation.cli --config config.yaml process "https://en.wikipedia.org/wiki/Python_(programming_language)" --site wiki --verbose
print_success "Verbose test completed"

print_header "All tests completed successfully!"
