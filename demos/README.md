# Auto-Browser Advanced Demos

This directory contains example scripts demonstrating various features and real-world automation workflows using auto-browser.

## Demo Categories

### Basic Demos (1-6)
Demonstrate fundamental features and simple interactions.

### Advanced Workflow Demos (7-11)
Show complex, multi-step automation scenarios for real-world tasks.

## Available Demos

### Basic Usage (1-6)

1. **01_basic_setup.sh**: Basic usage and template creation
   - Stock data extraction
   - Template creation
   - Report generation

   1. **gemini_basic_setup.sh**: Gemini LLM integration
      - Using Google's Gemini model
      - Stock price extraction
      - Detailed market data analysis
      - Complex task execution
      - Interactive mode capabilities
      - Detailed report generation

2. **02_simple_search.sh**: Search and data extraction
   - Search functionality
   - Data parsing
   - Result formatting

3. **03_multi_tab.sh**: Multi-page operations
   - Multiple stock comparison
   - News aggregation
   - Cross-page data collection

4. **04_form_interaction.sh**: Form interactions
   - Form filling
   - Button clicking
   - Input validation

5. **05_parallel_tasks.sh**: Complex extraction
   - Market data analysis
   - Performance tracking
   - Data aggregation

6. **06_clinical_trials.sh**: Specialized extraction
   - Medical data parsing
   - Trial information
   - Status tracking

### Advanced Workflows (7-11)

7. **07_timesheet_automation.sh**: Complete timesheet management
   - Weekly time entry
   - Project allocation
   - Multi-day entry
   - Report generation
   - Approval workflow
   - Monthly summaries

8. **08_social_media_campaign.sh**: Social media management
   - Multi-platform posting
   - Content scheduling
   - Engagement tracking
   - Analytics monitoring
   - Response automation
   - Campaign coordination

9. **09_research_workflow.sh**: Academic research automation
   - Literature search
   - Paper analysis
   - Citation management
   - Bibliography creation
   - Collaboration setup
   - Export functionality

10. **10_project_management.sh**: Project setup and coordination
    - Repository creation
    - Issue tracking
    - Documentation setup
    - Team communication
    - CI/CD configuration
    - Integration management

## Environment Setup

### Required Environment Variables
```bash
# Authentication
export USER_EMAIL="your.email@company.com"
export TWITTER_USER="your_twitter_username"
export GITHUB_TOKEN="your_github_token"

# API Keys
export OPENAI_API_KEY="your_openai_key"
export LLM_MODEL="gpt-4o-mini"

# Browser Settings
export BROWSER_HEADLESS="true"
```

### Platform-Specific Setup

#### GitHub Integration
```bash
export GITHUB_USER="your_username"
export GITHUB_EMAIL="your.email@domain.com"
```

#### Jira/Confluence
```bash
export JIRA_DOMAIN="your-domain.atlassian.net"
export JIRA_EMAIL="your.email@company.com"
```

#### Social Media
```bash
export BUFFER_ACCESS_TOKEN="
