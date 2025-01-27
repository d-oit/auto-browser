"""Configuration for language models."""

from enum import Enum
from typing import Optional, Dict, Any
from pydantic import BaseModel, SecretStr


class ModelProvider(str, Enum):
    """Supported model providers."""
    OPENAI = "openai"
    GOOGLE = "google"


class ModelConfig(BaseModel):
    """Configuration for a language model.
    
    Attributes:
        provider: The model provider (OpenAI, Google, etc.)
        model_name: Name of the specific model to use
        api_key: API key for the provider
        extra_params: Additional parameters for model initialization
    """
    provider: ModelProvider
    model_name: str
    api_key: SecretStr
    extra_params: Optional[Dict[str, Any]] = None

    @classmethod
    def from_env(cls) -> "ModelConfig":
        """Create a ModelConfig from environment variables.
        
        Environment variables:
            LLM_PROVIDER: The model provider (openai or google)
            LLM_MODEL: The model name to use
            OPENAI_API_KEY: API key for OpenAI (if using OpenAI)
            GOOGLE_API_KEY: API key for Google (if using Google)
            
        Returns:
            ModelConfig instance
        
        Raises:
            ValueError: If required environment variables are missing
        """
        import os
        from dotenv import load_dotenv
        
        # Load environment variables from .env file
        load_dotenv()
        
        # Get provider with Google as default
        provider = os.getenv("LLM_PROVIDER", "google").lower()
        if provider not in ModelProvider.__members__.values():
            raise ValueError(f"Unsupported provider: {provider}")
            
        provider = ModelProvider(provider)
        
        # Get provider-specific settings
        if provider == ModelProvider.GOOGLE:
            default_model = "gemini-2.0-flash-exp"
            api_key_env = "GOOGLE_API_KEY"
            api_key = os.getenv(api_key_env)
            if not api_key:
                raise ValueError(f"{api_key_env} must be set in environment or .env file")
        else:  # OpenAI
            default_model = "gpt-4-vision-preview"
            api_key_env = "OPENAI_API_KEY"
            api_key = os.getenv(api_key_env)
            if not api_key:
                raise ValueError(f"{api_key_env} must be set in environment or .env file")
            
        # Get model name
        model_name = os.getenv("LLM_MODEL", default_model)
            
        return cls(
            provider=provider,
            model_name=model_name,
            api_key=SecretStr(api_key)
        )