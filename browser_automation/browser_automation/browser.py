import asyncio
import os
from pathlib import Path
from typing import Optional, Dict, Any, List
from dotenv import load_dotenv
from browser_use import Agent
from browser_use.browser.browser import Browser, BrowserConfig
from langchain_openai import ChatOpenAI
from rich.console import Console
from .config import SiteConfig, Selector

console = Console()

class BrowserAutomation:
    def __init__(self, config: Optional[SiteConfig], output_dir: Optional[Path], verbose: bool = False):
        load_dotenv()
        self.config = config
        self.output_dir = output_dir
        if output_dir:
            self.output_dir.mkdir(parents=True, exist_ok=True)
        self.verbose = verbose
        
    async def get_page_content(self, url: str) -> str:
        """Visit a page and get its content for analysis"""
        browser = Browser(config=BrowserConfig(
            headless=os.getenv('BROWSER_HEADLESS', 'true').lower() == 'true'
        ))
        
        try:
            # Create a simple agent to visit the page and extract content
            task = f"""
            1. Navigate to '{url}'
            2. Extract and return the page's main content, including:
               - Headers and titles
               - Main text content
               - Important UI elements and their structure
            """
            
            agent = Agent(
                task=task,
                llm=ChatOpenAI(model=os.getenv('LLM_MODEL', 'gpt-4o')),
                browser=browser,
                use_vision=True
            )
            
            # Run agent and get result
            result = await agent.run()
            return str(result)
            
        finally:
            await browser.close()
        
    async def process_url(self, url: str, output_name: Optional[str] = None) -> Path:
        """Process a single URL using the configured site template"""
        if not self.config:
            raise ValueError("No site configuration provided")
            
        browser = Browser(config=BrowserConfig(
            headless=os.getenv('BROWSER_HEADLESS', 'true').lower() == 'true'
        ))
        
        try:
            # Create task description for the agent
            selectors_desc = "\n".join([
                f"- Extract {key} using selector '{selector.css if isinstance(selector, Selector) else selector}'"
                for key, selector in self.config.selectors.items()
            ])
            
            task = f"""
            1. Navigate to '{url}'
            2. Extract the following content:
            {selectors_desc}
            3. Return the content in a JSON format with keys matching the selector names.
            """
            
            # Create agent
            agent = Agent(
                task=task,
                llm=ChatOpenAI(model=os.getenv('LLM_MODEL', 'gpt-4o')),
                browser=browser,
                use_vision=True  # Enable vision capabilities for better extraction
            )
            
            # Run agent and get result
            result = await agent.run()
            
            # Parse result into content dictionary
            content = {}
            for key, selector in self.config.selectors.items():
                try:
                    if isinstance(selector, str):
                        selector = Selector(css=selector)
                    
                    # Extract content from result
                    if key in result:
                        content[key] = result[key]
                    else:
                        if self.verbose:
                            console.print(f"[yellow]Warning:[/yellow] No content found for '{key}'")
                        content[key] = None if not selector.multiple else []
                        
                except Exception as e:
                    if self.verbose:
                        console.print(f"[red]Error extracting {key}:[/red] {e}")
                    if selector.required:
                        raise
                    content[key] = None
            
            # Generate output filename
            if not output_name:
                output_name = url.split('/')[-1].split('?')[0]  # Remove query params
            output_path = self.output_dir / f"{output_name}.{self.config.output_format}"
            
            # Save content
            if self.config.output_format == "markdown":
                await self._save_markdown(content, output_path)
            else:
                raise ValueError(f"Unsupported output format: {self.config.output_format}")
            
            if self.verbose:
                console.print(f"[green]Successfully processed[/green] {url}")
            return output_path
            
        finally:
            await browser.close()
            
        # Small delay between processing
        await asyncio.sleep(float(os.getenv('BROWSER_DELAY', '2.0')))
        
    async def _save_markdown(self, content: Dict[str, Any], output_path: Path):
        """Save extracted content as markdown"""
        markdown = []
        
        # Add metadata section
        markdown.append("---")
        markdown.append(f"site: {self.config.name}")
        markdown.append(f"url: {self.config.url_pattern}")
        markdown.append("---\n")
        
        # Add content sections
        for key, value in content.items():
            selector = self.config.selectors[key]
            description = selector.description if isinstance(selector, Selector) else key.title()
            
            markdown.append(f"# {description}\n")
            
            if isinstance(value, list):
                for item in value:
                    if item and str(item).strip():
                        markdown.append(f"{str(item).strip()}\n")
            elif value and str(value).strip():
                markdown.append(f"{str(value).strip()}\n")
                
            markdown.append("")  # Empty line between sections
            
        output_path.write_text("\n".join(markdown))

    @staticmethod
    def format_filename(url: str) -> str:
        """Generate a safe filename from URL"""
        # Remove common prefixes
        for prefix in ['http://', 'https://', 'www.']:
            if url.startswith(prefix):
                url = url[len(prefix):]
                
        # Replace unsafe characters
        unsafe_chars = '<>:"/\\|?*'
        filename = ''.join(c if c not in unsafe_chars else '_' for c in url)
        
        # Limit length
        if len(filename) > 200:
            filename = filename[:200]
            
        return filename
