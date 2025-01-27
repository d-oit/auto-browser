"""Factory for creating language model instances."""

from typing import Any
from langchain_core.language_models import BaseLLM
from .config import ModelConfig, ModelProvider

class ModelFactory:
    """Factory class for creating language model instances."""
    
    @staticmethod
    def create_model(config: ModelConfig) -> BaseLLM:
        """Create a language model instance based on configuration.
        
        Args:
            config: Model configuration
            
        Returns:
            Language model instance
            
        Raises:
            ValueError: If provider is not supported
            ImportError: If provider-specific dependencies are not installed
        """
        try:
            if config.provider == ModelProvider.OPENAI:
                from langchain_openai import ChatOpenAI
                return ChatOpenAI(
                    api_key=config.api_key.get_secret_value(),
                    model=config.model_name,
                    **(config.extra_params or {})
                )
                
            elif config.provider == ModelProvider.GOOGLE:
                from langchain_google_genai import ChatGoogleGenerativeAI
                return ChatGoogleGenerativeAI(
                    model=config.model_name,
                    google_api_key=config.api_key.get_secret_value(),
                    **(config.extra_params or {})
                )
                
            raise ValueError(f"Unsupported model provider: {config.provider}")
            
        except ImportError as e:
            raise ImportError(
                f"Failed to import dependencies for {config.provider.value} provider. "
                f"Please install the required package: {str(e)}"
            ) from e