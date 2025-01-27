# Model Provider Switching Architecture

## Current Issues

### 1. Inconsistent Provider Defaults
- `config.py` sets Google as the default provider
- `.env` file can override with OpenAI
- No clear single source of truth for provider selection

### 2. Environment Variable Loading
- Multiple components load environment variables independently
  - `cli.py` uses `load_environment()`
  - `config.py` uses `load_dotenv()`
  - `browser.py` uses `load_dotenv()`
- Multiple potential `.env` file locations:
  - `/workspaces/auto-browser/.env`
  - `{cwd}/.env`
  - `{cwd}/auto-browser/.env`

### 3. API Key Handling
- Placeholder values might be used if `.env` files are loaded in the wrong order
- No clear validation of API key format or validity
- Error messages don't indicate which `.env` file was used

## Recommended Changes

### 1. Provider Selection
```python
# config.py
@classmethod
def from_env(cls) -> "ModelConfig":
    provider = os.getenv("LLM_PROVIDER")
    if not provider:
        raise ValueError("LLM_PROVIDER must be set in environment or .env file")
    
    provider = provider.lower()
    if provider not in ModelProvider.__members__.values():
        raise ValueError(f"Unsupported provider: {provider}")
    
    return cls(...)
```

### 2. Environment Variable Loading
```python
# settings.py (new file)
from pathlib import Path
from typing import Optional
import os
from dotenv import load_dotenv

class Settings:
    _instance: Optional["Settings"] = None
    
    def __init__(self):
        self.env_file = self._load_env_file()
        self.provider = self._get_provider()
        self.api_key = self._get_api_key()
        
    @classmethod
    def get_instance(cls) -> "Settings":
        if cls._instance is None:
            cls._instance = cls()
        return cls._instance
        
    def _load_env_file(self) -> Path:
        env_paths = [
            Path('/workspaces/auto-browser/.env'),
            Path.cwd() / '.env',
            Path.cwd() / 'auto-browser' / '.env',
        ]
        
        for path in env_paths:
            if path.exists():
                load_dotenv(path, override=True)
                return path
                
        raise FileNotFoundError("No .env file found")
        
    def _get_provider(self) -> str:
        provider = os.getenv("LLM_PROVIDER")
        if not provider:
            raise ValueError(
                f"LLM_PROVIDER not set in {self.env_file}"
            )
        return provider.lower()
        
    def _get_api_key(self) -> str:
        key_env = (
            "OPENAI_API_KEY" 
            if self.provider == "openai" 
            else "GOOGLE_API_KEY"
        )
        api_key = os.getenv(key_env)
        if not api_key:
            raise ValueError(
                f"{key_env} not set in {self.env_file}"
            )
        return api_key
```

### 3. Usage in Components

```python
# factory.py
def create_model(config: ModelConfig) -> BaseLLM:
    settings = Settings.get_instance()
    if config.provider != settings.provider:
        raise ValueError(
            f"Provider mismatch: {config.provider} != {settings.provider}"
        )
    # ... rest of create_model implementation
```

## Benefits

1. **Single Source of Truth**: All environment configuration is handled by the `Settings` class
2. **Clear Error Messages**: Each error indicates exactly which file and variable caused the issue
3. **Consistent Provider Selection**: No more conflicting defaults between components
4. **Better API Key Validation**: Keys are validated at startup, not during operation
5. **Singleton Pattern**: Ensures consistent settings across the application

## Implementation Steps

1. Create new `settings.py` file
2. Update all components to use `Settings.get_instance()`
3. Remove individual `load_dotenv()` calls
4. Update error handling to use new error messages
5. Add logging for configuration loading
6. Update documentation to reflect new architecture

## Migration Guide

1. **For Users**:
   - Ensure `.env` file exists and has required variables
   - Set `LLM_PROVIDER` explicitly
   - Provide correct API key for chosen provider

2. **For Developers**:
   - Use `Settings.get_instance()` instead of direct env vars
   - Add error handling for configuration errors
   - Update tests to mock `Settings` class

## Future Improvements

1. Add validation for API key format
2. Add support for multiple provider configurations
3. Add configuration validation at startup
4. Add configuration hot-reloading
5. Add provider-specific validation rules