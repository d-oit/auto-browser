#!/usr/bin/env python3

import asyncio
from pathlib import Path
import sys
import click
from rich.console import Console
from rich.progress import Progress, SpinnerColumn, TextColumn, BarColumn, TaskProgressColumn
from .config import load_config, create_example_config
from .browser import BrowserAutomation
from .template_generator import TemplateGenerator

console = Console()

def create_progress() -> Progress:
    """Create a rich progress bar with custom formatting"""
    return Progress(
        SpinnerColumn(),
        TextColumn("[blue]{task.description}"),
        BarColumn(),
        TaskProgressColumn(),
        console=console
    )

@click.group()
@click.option(
    '--config',
    type=click.Path(exists=True, path_type=Path),
    default='config.yaml',
    help='Path to config file'
)
@click.pass_context
def cli(ctx, config):
    """Browser automation CLI tool for configurable site scraping"""
    ctx.ensure_object(dict)
    try:
        ctx.obj['config'] = load_config(config)
    except Exception as e:
        console.print(f"[red]Error loading config:[/red] {e}")
        ctx.exit(1)

@cli.command()
@click.argument('url')
@click.option('--site', help='Site template to use')
@click.option('--output', help='Output filename (without extension)')
@click.option('--verbose', '-v', is_flag=True, help='Enable verbose output')
@click.pass_context
def process(ctx, url: str, site: str, output: str, verbose: bool):
    """Process a single URL using a site template"""
    config = ctx.obj['config']
    
    # Determine site template
    if not site:
        site = config.default_site
    if not site or site not in config.sites:
        console.print("[red]Error:[/red] No valid site template specified")
        ctx.exit(1)
        
    site_config = config.sites[site]
    automation = BrowserAutomation(site_config, config.output_dir, verbose=verbose)
    
    try:
        with create_progress() as progress:
            task = progress.add_task(f"Processing {url}...", total=1)
            output_path = asyncio.run(automation.process_url(url, output))
            progress.update(task, advance=1)
        
        console.print(f"[green]Success![/green] Output saved to: {output_path}")
    except Exception as e:
        console.print(f"[red]Error processing URL:[/red] {e}")
        ctx.exit(1)

@cli.command()
@click.argument('input_file', type=click.Path(exists=True, path_type=Path))
@click.option('--site', help='Site template to use')
@click.option('--continue-on-error', is_flag=True, help='Continue processing if an error occurs')
@click.pass_context
def batch(ctx, input_file: Path, site: str, continue_on_error: bool):
    """Process multiple URLs from a file"""
    config = ctx.obj['config']
    
    # Determine site template
    if not site:
        site = config.default_site
    if not site or site not in config.sites:
        console.print("[red]Error:[/red] No valid site template specified")
        ctx.exit(1)
        
    site_config = config.sites[site]
    automation = BrowserAutomation(site_config, config.output_dir)
    
    # Read URLs
    urls = input_file.read_text().splitlines()
    urls = [url.strip() for url in urls if url.strip()]
    
    with create_progress() as progress:
        task = progress.add_task("Processing URLs...", total=len(urls))
        
        for url in urls:
            try:
                asyncio.run(automation.process_url(url))
                progress.update(task, advance=1)
            except Exception as e:
                console.print(f"[red]Error processing {url}:[/red] {e}")
                if not continue_on_error:
                    ctx.exit(1)

@cli.command()
@click.argument('url')
@click.option('--name', prompt=True, help='Name for the template')
@click.option('--description', prompt=True, help='Description of what this template extracts')
@click.option('--config-path', type=click.Path(path_type=Path), default='config.yaml', help='Path to save the template')
@click.pass_context
def create_template(ctx, url: str, name: str, description: str, config_path: Path):
    """Create a new template by analyzing a webpage with AI assistance"""
    try:
        generator = TemplateGenerator()
        
        with create_progress() as progress:
            task = progress.add_task(f"Analyzing {url}...", total=1)
            template = asyncio.run(generator.create_template(url, name, description))
            progress.update(task, advance=1)
            
        # Preview the template
        console.print("\n[bold]Generated Template:[/bold]")
        console.print(f"Name: {template.name}")
        console.print(f"Description: {template.description}")
        console.print(f"URL Pattern: {template.url_pattern}")
        console.print("\nSelectors:")
        for name, selector in template.selectors.items():
            console.print(f"  - {name}:")
            console.print(f"    CSS: {selector.css}")
            if selector.description:
                console.print(f"    Description: {selector.description}")
            console.print(f"    Multiple: {selector.multiple}")
            
        # Confirm save
        if click.confirm("\nSave this template?", default=True):
            generator.save_template(config_path, template)
            console.print(f"\n[green]Template saved to {config_path}[/green]")
        
    except Exception as e:
        console.print(f"[red]Error creating template:[/red] {e}")
        ctx.exit(1)

@cli.command()
@click.argument('output_path', type=click.Path(path_type=Path))
def init(output_path: Path):
    """Create an example configuration file"""
    try:
        create_example_config(output_path)
        console.print(f"[green]Created example config at:[/green] {output_path}")
    except Exception as e:
        console.print(f"[red]Error creating config:[/red] {e}")
        raise click.Abort()

@cli.command()
@click.pass_context
def list_sites(ctx):
    """List available site templates"""
    config = ctx.obj['config']
    
    console.print("\n[bold]Available site templates:[/bold]\n")
    
    for name, site in config.sites.items():
        console.print(f"[blue]{name}[/blue]")
        if site.description:
            console.print(f"  Description: {site.description}")
        console.print(f"  URL Pattern: {site.url_pattern}")
        console.print(f"  Selectors:")
        for key, selector in site.selectors.items():
            if isinstance(selector, str):
                console.print(f"    - {key}: {selector}")
            else:
                console.print(f"    - {key}:")
                console.print(f"      CSS: {selector.css}")
                if selector.description:
                    console.print(f"      Description: {selector.description}")
        console.print("")

def main():
    """CLI entry point"""
    try:
        cli(obj={}, standalone_mode=False)
    except click.exceptions.Abort:
        sys.exit(1)
    except Exception as e:
        console.print(f"[red]Error:[/red] {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()
