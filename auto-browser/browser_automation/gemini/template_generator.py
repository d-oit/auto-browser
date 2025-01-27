"""Template generator for auto-browser using Google's Gemini model."""

from typing import Optional
from ..models import ModelConfig, ModelProvider
from ..template_generator import TemplateGenerator

class GeminiTemplateGenerator(TemplateGenerator):
    """Generate site templates using Google's Gemini model."""
    
    def __init__(self, model_config: Optional[ModelConfig] = None):
        """Initialize Gemini template generator.
        
        Args:
            model_config: Optional model configuration. If not provided,
                        will create a Gemini-specific configuration.
        """
        if model_config is None:
            # Create default Gemini configuration
            model_config = ModelConfig(
                provider=ModelProvider.GOOGLE,
                model_name="gemini-2.0-flash-exp",
                api_key=ModelConfig.from_env().api_key
            )
        elif model_config.provider != ModelProvider.GOOGLE:
            raise ValueError("GeminiTemplateGenerator requires a Google model configuration")
            
        super().__init__(model_config)
