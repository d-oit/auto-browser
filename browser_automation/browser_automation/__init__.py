"""Browser automation CLI tool for configurable site scraping"""

from .browser import BrowserAutomation
from .config import Config, SiteConfig, load_config

__all__ = ['BrowserAutomation', 'Config', 'SiteConfig', 'load_config']
__version__ = '0.1.0'
