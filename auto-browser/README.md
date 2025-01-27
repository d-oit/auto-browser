# Auto-Browser

An automated browser interaction tool powered by language models.

## Features

- Automated webpage analysis and content extraction
- Support for multiple language models (OpenAI GPT-4, Google Gemini)
- Template-based site configuration
- Flexible output formatting
- Headless browser automation

## Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/auto-browser.git
cd auto-browser/auto-browser

# Install dependencies
pip install -e .
```

## Configuration

### Language Model Setup

The system supports multiple language models through a flexible configuration system. You can choose between OpenAI and Google models using environment variables or configuration files.

1. Copy the example environment file:
```bash
cp .env.example .env
```

2. Edit `.env` to configure your preferred model:

```bash
# Choose provider: 'openai' or 'google'
LLM_PROVIDER=openai

# Set model name (provider-specific)
LLM_MODEL=gpt-4-vision-preview  # For OpenAI
# or
LLM_MODEL=gemini-2.0-flash-exp  # For Google

# Set API key for chosen provider
OPENAI_API_KEY=your-key-here
# or
GOOGLE_API_KEY=your-key-here
```

### Model Configuration

You can configure different aspects of the language models:

1. **Environment Variables**:
   - `LLM_PROVIDER`: Choose between 'openai' or 'google'
   - `LLM_MODEL`: Specific model name for the chosen provider
   - `OPENAI_API_KEY`/`GOOGLE_API_KEY`: API key for the chosen provider

2. **Provider-Specific Features**:
   
   OpenAI Models:
   - Support for GPT-4 Vision
   - Advanced text completion
   - High accuracy in web analysis

   Google Gemini:
   - Fast performance
   - Competitive pricing
   - Strong visual analysis capabilities

### Using Different Models

1. **Default Template Generator**:
```python
from browser_automation import TemplateGenerator

# Uses configuration from environment
generator = TemplateGenerator()
```

2. **Explicit Model Configuration**:
```python
from browser_automation.models import ModelConfig, ModelProvider
from browser_automation import TemplateGenerator

config = ModelConfig(
    provider=ModelProvider.OPENAI,
    model_name="gpt-4-vision-preview",
    api_key="your-key-here"
)

generator = TemplateGenerator(model_config=config)
```

3. **Using Gemini Models**:
```python
from browser_automation.gemini import GeminiTemplateGenerator

# Automatically uses Gemini configuration
generator = GeminiTemplateGenerator()
```

## Usage Examples

1. **Basic Template Creation**:
```python
import asyncio
from browser_automation import TemplateGenerator

async def main():
    generator = TemplateGenerator()
    template = await generator.create_template(
        url="https://example.com",
        name="example",
        description="Example site template"
    )
    generator.save_template(template)

asyncio.run(main())
```

2. **Model-Specific Template**:
```python
from browser_automation.models import ModelConfig, ModelProvider
from browser_automation import TemplateGenerator

config = ModelConfig(
    provider=ModelProvider.GOOGLE,
    model_name="gemini-2.0-flash-exp",
    api_key="your-google-key"
)

generator = TemplateGenerator(model_config=config)
```

## Best Practices

1. **Model Selection**:
   - Use OpenAI models for complex analysis tasks
   - Use Gemini models for faster processing and cost efficiency
   - Consider task requirements when choosing models

2. **Configuration Management**:
   - Keep API keys secure in environment variables
   - Use version control for template configurations
   - Document model-specific requirements

3. **Error Handling**:
   - Handle provider-specific error cases
   - Implement fallback strategies
   - Monitor model performance

## Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests to our repository.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
