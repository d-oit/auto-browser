#!/bin/bash

# Demo 1: Basic Setup and Configuration
# This script demonstrates the initial setup and configuration of the browser automation tool

echo "Step 1: Creating example configuration file..."
./auto-browser init config.yaml

echo -e "\nStep 2: Displaying available site templates..."
./auto-browser list-sites

echo -e "\nBasic setup complete! The tool is now configured with example templates."
echo -e "\nTry the other demo scripts to see different automation capabilities:"
echo "- 02_simple_search.sh: Basic Google search automation"
echo "- 03_multi_tab.sh: Handling multiple browser tabs"
echo "- 04_form_interaction.sh: Complex form interactions"
echo "- 05_parallel_tasks.sh: Running multiple tasks in parallel"
echo "- 06_clinical_trials.sh: Clinical trials data extraction"
