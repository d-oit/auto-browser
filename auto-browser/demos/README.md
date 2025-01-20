# Browser Automation Demos

This directory contains a series of demo scripts showcasing various capabilities of the browser automation tool, from basic operations to advanced features.

## Prerequisites

- Make sure you have the browser automation tool installed
- All scripts should be run from the `browser_automation` directory

## Demo Scripts

### 1. Basic Setup (01_basic_setup.sh)
- Creates initial configuration file
- Shows available site templates
- Basic tool setup and configuration

### 2. Simple Search (02_simple_search.sh)
- Demonstrates basic Google search automation
- Shows how to interact with search boxes
- Extracts search results

### 3. Multi-Tab Handling (03_multi_tab.sh)
- Shows how to work with multiple browser tabs
- Tab navigation and management
- Content extraction from multiple tabs

### 4. Form Interaction (04_form_interaction.sh)
- Complex form interactions
- File upload handling
- Form submission and response processing

### 5. Parallel Tasks (05_parallel_tasks.sh)
- Running multiple automation tasks simultaneously
- Efficient resource utilization
- Parallel data extraction

### 6. Clinical Trials (06_clinical_trials.sh)
- Advanced data extraction from clinical trials website
- Document downloading and processing
- Structured data extraction

## Running the Demos

1. Start with the basic setup:
```bash
cd browser_automation
demos/01_basic_setup.sh
```

2. Run subsequent demos in order to understand progressively more complex features:
```bash
demos/02_simple_search.sh
demos/03_multi_tab.sh
# ... and so on
```

Each script includes detailed comments explaining what it does and demonstrates different aspects of the browser automation tool.

## Output

- Most demos will create output files in the `output` directory
- Check the terminal output for progress and results
- Some demos will save extracted data as structured files

## Notes

- Each demo is self-contained and will create its own configuration
- Demos can be run independently, but it's recommended to start with 01_basic_setup.sh
- Some demos may require internet connectivity
- Check each script's comments for specific requirements or setup instructions
