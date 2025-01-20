"""Template generator for auto-browser."""

import asyncio
import os
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Any, Optional
import yaml
from browser_use import Agent
from browser_use.browser.browser import Browser, BrowserConfig
from langchain_openai import ChatOpenAI

@dataclass
class Selector:
    """Represents a CSS selector with metadata."""
    css: str
    description: Optional[str] = None
    multiple: bool = False

@dataclass
class Template:
    """Represents a site template."""
    name: str
    description: str
    url_pattern: str
    selectors: Dict[str, Selector]

class TemplateGenerator:
    """Generate site templates by analyzing webpages."""
    
    async def create_template(self, url: str, name: str, description: str) -> Template:
        """Create a template by analyzing a webpage.
        
        Args:
            url: URL to analyze
            name: Template name
            description: Template description
            
        Returns:
            Generated template
        """
        browser = Browser(config=BrowserConfig(headless=True))
        
        try:
            # Create task for analyzing the page
            task = f"""
            1. Navigate to '{url}'
            2. Analyze the page structure and identify:
               - Main content sections
               - Interactive elements (forms, buttons)
               - Important data elements
            3. Return a list of CSS selectors for extracting content
            """
            
            # Create and run agent
            # Get API key and model from environment
            api_key = os.getenv('OPENAI_API_KEY')
            if not api_key:
                raise ValueError("OPENAI_API_KEY environment variable must be set")

            model = os.getenv('LLM_MODEL', 'gpt-4o-mini')

            # Create agent with explicit API key and model
            agent = Agent(
                task=task,
                llm=ChatOpenAI(
                    api_key=api_key,
                    model=model
                ),
                browser=browser,
                use_vision=True
            )
            
            # Get analysis result
            result = await agent.run()
            
            # Create selectors from analysis
            selectors = self._create_selectors(result)
            
            return Template(
                name=name,
                description=description,
                url_pattern=url,
                selectors=selectors
            )
            
        finally:
            await browser.close()
    
    def _create_selectors(self, analysis: Dict[str, Any]) -> Dict[str, Selector]:
        """Create selectors from analysis result."""
        selectors = {}
        
        # Extract content selectors
        if 'content' in analysis:
            for key, value in analysis['content'].items():
                selectors[f"content_{key}"] = Selector(
                    css=value['selector'],
                    description=value.get('description'),
                    multiple=value.get('multiple', False)
                )
        
        # Extract interactive element selectors
        if 'interactive' in analysis:
            for key, value in analysis['interactive'].items():
                selectors[f"interactive_{key}"] = Selector(
                    css=value['selector'],
                    description=value.get('description'),
                    multiple=False
                )
        
        return selectors
    
    def save_template(self, template: Template, output_path: Optional[Path] = None) -> None:
        """Save template to a file.
        
        Args:
            template: Template to save
            output_path: Optional path to save to (defaults to config.yaml)
        """
        if output_path is None:
            output_path = Path('config.yaml')
            
        # Create config structure
        config = {
            'sites': {
                template.name: {
                    'name': template.name,
                    'description': template.description,
                    'url_pattern': template.url_pattern,
                    'selectors': {
                        name: {
                            'css': sel.css,
                            'description': sel.description,
                            'multiple': sel.multiple
                        }
                        for name, sel in template.selectors.items()
                    }
                }
            }
        }
        
        # Save to file
        output_path = Path(output_path)
        if output_path.exists():
            # Update existing config
            existing_config = yaml.safe_load(output_path.read_text())
            existing_config['sites'].update(config['sites'])
            config = existing_config
            
        output_path.write_text(yaml.dump(config, sort_keys=False))
