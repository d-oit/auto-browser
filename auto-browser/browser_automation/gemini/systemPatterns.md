## Template Generator Component

### Purpose
Generates site templates by analyzing webpages using Google's Gemini model. Creates structured templates containing CSS selectors and metadata for web automation tasks.

### Key Classes
1. `Selector` (dataclass)
   - Represents a CSS selector with metadata
   - Fields:
     * `css`: The CSS selector string
     * `description`: Optional description of the element
     * `multiple`: Whether selector matches multiple elements

2. `Template` (dataclass)
   - Represents a complete site template
   - Fields:
     * `name`: Template name
     * `description`: Template description
     * `url_pattern`: URL pattern for matching sites
     * `selectors`: Dictionary of Selector objects

3. `TemplateGenerator` (class)
   - Main class for generating templates
   - Methods:
     * `create_template`: Analyzes a webpage and creates a template
     * `_create_selectors`: Internal method to process analysis results
     * `save_template`: Saves template to YAML config file

### Workflow
1. Initialize with Google Gemini model
2. Analyze webpage structure
3. Identify key elements (content, interactive elements, data)
4. Generate CSS selectors
5. Save template to YAML config

### Dependencies
- Google Gemini API (via langchain_google_genai)
- Browser automation (via browser_use)
- YAML configuration handling
