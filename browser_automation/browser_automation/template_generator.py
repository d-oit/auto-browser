import os
from pathlib import Path
from typing import Dict, List, Optional
import yaml
from dotenv import load_dotenv
from openai import OpenAI
from pydantic import BaseModel
from .config import SiteConfig, Selector
from .browser import BrowserAutomation

load_dotenv()

class TemplateGenerator:
    """Handles template creation with LLM assistance"""
    
    def __init__(self):
        """Initialize the template generator with API credentials"""
        api_key = os.getenv("OPENAI_API_KEY")
        if not api_key:
            raise ValueError("OPENAI_API_KEY not found in environment variables")
        self.client = OpenAI(api_key=api_key)
        self.model = os.getenv("LLM_MODEL", "gpt-4o")
        
    async def analyze_page(self, url: str) -> Dict:
        """Visit a page and analyze its structure"""
        # Create a temporary browser automation instance
        automation = BrowserAutomation(None, None)
        page_content = await automation.get_page_content(url)
        
        # Use LLM to analyze the page structure
        analysis_prompt = f"""
        Analyze this webpage content and identify key elements that could be extracted.
        For each element, provide in this exact format:
        - name: [descriptive name]
          css: [CSS selector]
          multiple: [true/false]
          description: [what this element represents]
        
        Page URL: {url}
        Content: {page_content[:2000]}  # First 2000 chars for context
        """
        
        response = self.client.chat.completions.create(
            model=self.model,
            messages=[
                {"role": "system", "content": "You are a web scraping expert helping to create templates for data extraction."},
                {"role": "user", "content": analysis_prompt}
            ]
        )
        
        # Parse LLM response into structured format
        analysis = response.choices[0].message.content
        return self._parse_llm_analysis(analysis)
    
    def _parse_llm_analysis(self, analysis: str) -> Dict:
        """Parse the LLM's analysis into a structured format"""
        selectors = {}
        current_element = None
        
        for line in analysis.split('\n'):
            line = line.strip()
            if not line:
                continue
                
            if line.startswith('- name:'):
                # Save previous element if exists
                if current_element and 'name' in current_element:
                    selectors[current_element['name']] = Selector(
                        css=current_element.get('css', ''),
                        multiple=current_element.get('multiple', False),
                        description=current_element.get('description', '')
                    )
                current_element = {'name': line[7:].strip()}
            elif current_element and ':' in line:
                key, value = [x.strip() for x in line.split(':', 1)]
                if key == 'multiple':
                    value = value.lower() == 'true'
                current_element[key] = value
                
        # Add final element
        if current_element and 'name' in current_element:
            selectors[current_element['name']] = Selector(
                css=current_element.get('css', ''),
                multiple=current_element.get('multiple', False),
                description=current_element.get('description', '')
            )
            
        return selectors
    
    async def create_template(self, url: str, name: str, description: str) -> SiteConfig:
        """Create a new template configuration for a given URL"""
        selectors = await self.analyze_page(url)
        
        # Use LLM to suggest URL pattern
        pattern_prompt = f"""
        Given this example URL: {url}
        Suggest a URL pattern that could match similar pages on this site.
        Replace variable parts with {{parameter}} placeholders.
        Example: https://example.com/products/123 -> https://example.com/products/{{id}}
        
        Respond with ONLY the pattern, nothing else.
        """
        
        response = self.client.chat.completions.create(
            model=self.model,
            messages=[
                {"role": "system", "content": "You are a web scraping expert helping to create URL patterns."},
                {"role": "user", "content": pattern_prompt}
            ]
        )
        
        url_pattern = response.choices[0].message.content.strip()
        
        # Create site config
        return SiteConfig(
            name=name,
            description=description,
            url_pattern=url_pattern,
            selectors=selectors,
            output_format="markdown"  # Default format
        )
    
    def save_template(self, config_path: Path, template: SiteConfig):
        """Save a new template to the config file"""
        if config_path.exists():
            with open(config_path) as f:
                config = yaml.safe_load(f) or {"sites": {}, "output_dir": "output"}
        else:
            config = {"sites": {}, "output_dir": "output"}
            
        # Add new template
        config["sites"][template.name.lower().replace(" ", "_")] = template.dict(
            exclude_none=True,
            exclude_unset=True
        )
        
        # Save updated config
        with open(config_path, 'w') as f:
            yaml.dump(config, f, sort_keys=False, indent=2)
