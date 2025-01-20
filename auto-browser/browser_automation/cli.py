"""Command-line interface for auto-browser."""

import asyncio
from pathlib import Path
import sys
import os
import json
import click
from rich.console import Console
from rich.progress import Progress, SpinnerColumn, TextColumn, BarColumn
import yaml
from dotenv import load_dotenv

# Load environment variables from the correct location
def load_environment():
    """Load environment variables from .env file."""
    env_paths = [
        Path.cwd() / '.env',  # Current directory
        Path.cwd() / 'auto-browser' / '.env',  # auto-browser subdirectory
        Path(__file__).parent.parent.parent / '.env'  # Repository root
    ]
    
    for env_path in env_paths:
        if env_path.exists():
            load_dotenv(env_path)
            return True
    return False

from .config import load_config, create_example_config
from .browser import BrowserAutomation
from .template_generator import TemplateGenerator
from .processors.content import ContentProcessor
from .processors.interactive import InteractiveProcessor
from .formatters.markdown import MarkdownFormatter

console = Console()

def create_progress() -> Progress:
    """Create a progress bar."""
    return Progress(
        SpinnerColumn(),
        TextColumn("[blue]{task.description}"),
        BarColumn(),
        console=console
    )

async def run_all_tasks(url: str, prompt: str, interactive: bool, verbose: bool):
    """Run all async tasks in sequence."""
    # Initialize processors
    content_processor = ContentProcessor()
    interactive_processor = InteractiveProcessor()
    formatter = MarkdownFormatter()
    
    # Create temporary config
    config = {
        'sites': {
            'temp': {
                'name': 'Temporary Site',
                'description': prompt,
                'url_pattern': url,
                'interactive': interactive
            }
        },
        'output_dir': 'output',
        'browser': {
            'headless': True,  # Always use headless mode
            'viewport': {'width': 1280, 'height': 720}
        }
    }
    
    # Generate template
    console.print("[blue]Analyzing webpage...[/blue]")
    generator = TemplateGenerator()
    template = await generator.create_template(url, 'temp', prompt)
    
    if verbose:
        console.print("[yellow]Template generated:[/yellow]")
        console.print(json.dumps(template.__dict__, indent=2))
    
    # Update config with template
    config['sites']['temp'].update({
        'selectors': {name: sel.css for name, sel in template.selectors.items()},
        'actions': interactive_processor.analyze_prompt(prompt) if interactive else []
    })
    
    # Process webpage
    automation = BrowserAutomation(config['sites']['temp'], config['output_dir'])
    with create_progress() as progress:
        task = progress.add_task("Processing...", total=1)
        result = await automation.process_url(url)
        progress.update(task, advance=1)
        
        if verbose:
            console.print("[yellow]Raw result:[/yellow]")
            console.print(json.dumps(result, indent=2))
    
    # Format and save output
    analyzed = content_processor.analyze_page(result)
    markdown = formatter.format_content(analyzed)
    output_path = formatter.save_markdown(markdown, url)
    
    return output_path

def run_async_task(coro):
    """Run an async task with proper cleanup."""
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    try:
        return loop.run_until_complete(coro)
    finally:
        loop.close()

@click.group()
@click.option('--config', type=click.Path(exists=True, path_type=Path), default='config.yaml')
@click.pass_context
def cli(ctx, config):
    """Browser automation tool for web scraping and interaction."""
    ctx.ensure_object(dict)
    try:
        ctx.obj['config'] = load_config(config)
    except Exception as e:
        console.print(f"[red]Error loading config:[/red] {e}")
        ctx.exit(1)

@cli.command()
@click.argument('url')
@click.argument('prompt')
@click.option('--interactive', is_flag=True, help='Enable interactive mode')
@click.option('--verbose', '-v', is_flag=True, help='Show detailed output')
@click.pass_context
def easy(ctx, url: str, prompt: str, interactive: bool, verbose: bool):
    """Easy mode: Describe what you want to do with the webpage."""
    try:
        # Run all tasks in a single event loop
        output_path = run_async_task(run_all_tasks(url, prompt, interactive, verbose))
        console.print(f"[green]Success![/green] Output saved to: {output_path}")
        
    except Exception as e:
        console.print(f"[red]Error:[/red] {e}")
        if verbose:
            console.print_exception()
        ctx.exit(1)

@cli.command()
@click.argument('output_path', type=click.Path(path_type=Path))
def init(output_path: Path):
    """Create an example configuration file."""
    try:
        create_example_config(output_path)
        console.print(f"[green]Created example config at:[/green] {output_path}")
    except Exception as e:
        console.print(f"[red]Error:[/red] {e}")
        ctx.exit(1)

def main():
    """CLI entry point."""
    try:
        # Load environment variables
        if not load_environment():
            console.print("[red]Error:[/red] No .env file found")
            sys.exit(1)
            
        # Check for required environment variables
        if not os.getenv('OPENAI_API_KEY'):
            console.print("[red]Error:[/red] OPENAI_API_KEY environment variable must be set")
            sys.exit(1)
            
        cli(obj={}, standalone_mode=False)
    except click.exceptions.Abort:
        sys.exit(1)
    except Exception as e:
        console.print(f"[red]Error:[/red] {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()
