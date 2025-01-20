"""Browser automation package for web scraping and interaction."""

import logging

# Configure logging
logging.basicConfig(
    level=logging.WARNING,  # Only show warnings and errors
    format='%(message)s'    # Only show the message, no timestamp or level
)

# Import main components
from .browser import BrowserAutomation
from .template_generator import TemplateGenerator, Template, Selector
from .processors.content import ContentProcessor, PageElement
from .processors.interactive import InteractiveProcessor, BrowserAction
from .formatters.markdown import MarkdownFormatter

__all__ = [
    'BrowserAutomation',
    'TemplateGenerator',
    'Template',
    'Selector',
    'ContentProcessor',
    'PageElement',
    'InteractiveProcessor',
    'BrowserAction',
    'MarkdownFormatter'
]
