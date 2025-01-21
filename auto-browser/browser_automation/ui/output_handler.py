from typing import Optional
from queue import Queue
import threading
from rich.console import Console

class StreamlitOutputHandler:
    def __init__(self, queue: Queue):
        self.queue = queue
        self.console = Console()
        
    def write(self, text: str, message_type: str = "info"):
        """Write output to the Streamlit queue"""
        if self.queue is not None:
            self.queue.put((text, message_type))
        # Also write to console for CLI usage
        if message_type == "error":
            self.console.print(f"[red]{text}[/red]")
        elif message_type == "success":
            self.console.print(f"[green]{text}[/green]")
        else:
            self.console.print(text)

    def error(self, text: str):
        """Write error message"""
        self.write(text, "error")

    def success(self, text: str):
        """Write success message"""
        self.write(text, "success")

class OutputManager:
    _instance: Optional["OutputManager"] = None
    _lock = threading.Lock()

    def __init__(self):
        self.queue: Optional[Queue] = None
        self.handler: Optional[StreamlitOutputHandler] = None

    @classmethod
    def get_instance(cls) -> "OutputManager":
        if cls._instance is None:
            with cls._lock:
                if cls._instance is None:
                    cls._instance = cls()
        return cls._instance

    def initialize(self, queue: Optional[Queue] = None):
        """Initialize with optional Streamlit queue"""
        self.queue = queue
        self.handler = StreamlitOutputHandler(queue)

    def get_handler(self) -> StreamlitOutputHandler:
        """Get the output handler"""
        if self.handler is None:
            self.initialize()
        return self.handler
