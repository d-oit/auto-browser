import streamlit as st
import time
from pathlib import Path
import yaml
import queue
import threading
from typing import Optional

class StreamlitUI:
    def __init__(self):
        st.set_page_config(page_title="Auto-Browser UI", layout="wide")
        self.output_queue = queue.Queue()
        self.should_stop = threading.Event()
        
        if "config" not in st.session_state:
            config_path = Path("config.yaml")
            if config_path.exists():
                with open(config_path) as f:
                    st.session_state.config = yaml.safe_load(f)
            else:
                st.session_state.config = {
                    "browser": {
                        "headless": True,
                        "viewport": {"width": 1280, "height": 720}
                    },
                    "output_dir": "output"
                }

    def render(self):
        st.title("Auto-Browser UI")
        
        # Sidebar for configuration
        with st.sidebar:
            st.header("Configuration")
            
            # Browser settings
            st.subheader("Browser Settings")
            browser_config = st.session_state.config.get("browser", {})
            headless = st.checkbox("Headless Mode", value=browser_config.get("headless", True))
            viewport_width = st.number_input("Viewport Width", value=browser_config.get("viewport", {}).get("width", 1280))
            viewport_height = st.number_input("Viewport Height", value=browser_config.get("viewport", {}).get("height", 720))
            
            # Output settings
            st.subheader("Output Settings")
            output_dir = st.text_input("Output Directory", value=st.session_state.config.get("output_dir", "output"))
            verbose = st.checkbox("Verbose Output", value=st.session_state.config.get("verbose", True))
            
            # Save configuration
            if st.button("Save Configuration"):
                st.session_state.config = {
                    "browser": {
                        "headless": headless,
                        "viewport": {
                            "width": viewport_width,
                            "height": viewport_height
                        }
                    },
                    "output_dir": output_dir,
                    "verbose": verbose
                }
                with open("config.yaml", "w") as f:
                    yaml.dump(st.session_state.config, f)
                st.success("Configuration saved!")

        # Main interface
        st.header("Auto-Browser Command Interface")
        
        # URL input
        url = st.text_input("URL", placeholder="https://example.com")
        
        # Command input
        command = st.text_area("Command", placeholder='Example: "Extract the main heading and links"', height=100)
        
        # Execute button
        if st.button("Execute", type="primary"):
            if not url or not command:
                st.error("Please provide both URL and command")
                return
                
            # Create tabs for output and report
            cli_tab, report_tab = st.tabs(["CLI Output", "Final Report"])
            
            # Create scrollable container for CLI output
            with cli_tab:
                st.markdown("### Execution Output")
                output_container = st.container()
                with output_container:
                    output_area = st.empty()
                    # Add CSS to make container scrollable
                    st.markdown("""
                        <style>
                            .stMarkdown {
                                max-height: 400px;
                                overflow-y: auto;
                                border: 1px solid #ccc;
                                padding: 10px;
                                border-radius: 5px;
                            }
                        </style>
                    """, unsafe_allow_html=True)
            
            # Initialize report tab
            with report_tab:
                report_area = st.empty()
                report_area.markdown("Report will appear here after execution...")
            
            # Process command
            try:
                import subprocess
                
                # Import required modules
                import asyncio
                import sys
                from io import StringIO
                from browser_automation.cli import run_all_tasks, console
                from rich.console import Console
                from rich.progress import Progress, SpinnerColumn, TextColumn, BarColumn
                
                output_area.markdown("🤖 Processing request...")
                
                # Create a custom console that writes to the UI
                class UIConsole(Console):
                    def __init__(self, output_area):
                        super().__init__(force_terminal=True)
                        self.output_area = output_area
                        self.buffer = StringIO()
                        
                    def print(self, *args, **kwargs):
                        # Capture the output
                        with StringIO() as temp_buffer:
                            console = Console(file=temp_buffer, force_terminal=True)
                            console.print(*args, **kwargs)
                            output = temp_buffer.getvalue()
                            
                        # Write to our buffer
                        self.buffer.write(output)
                        
                        # Format and display the output
                        content = self.buffer.getvalue()
                        formatted_lines = []
                        current_progress = None
                        
                        for line in content.split('\n'):
                            if "━" in line:
                                current_progress = line
                            elif line.strip().startswith(("🔧", "🔍", "📋", "🌐", "📊")):
                                formatted_lines.extend(["", line])
                            else:
                                formatted_lines.append(line)
                        
                        # Combine output
                        formatted_output = ""
                        if current_progress:
                            formatted_output += f"```\n{current_progress}\n```\n"
                        formatted_output += "```\n" + "\n".join(formatted_lines) + "\n```"
                        
                        self.output_area.markdown(formatted_output)
                
                # Create event loop
                loop = asyncio.new_event_loop()
                asyncio.set_event_loop(loop)
                
                try:
                    # Replace the global console with our UI console
                    ui_console = UIConsole(output_area)
                    original_console = sys.modules['browser_automation.cli'].console
                    sys.modules['browser_automation.cli'].console = ui_console
                    
                    # Create progress bar
                    progress = Progress(
                        SpinnerColumn(),
                        TextColumn("[blue]{task.description}"),
                        BarColumn(),
                        console=ui_console
                    )
                    
                    # Run the task
                    with progress:
                        task = progress.add_task("Processing...", total=1)
                        output_path = loop.run_until_complete(
                            run_all_tasks(
                                url=url,
                                prompt=command,
                                interactive=False,
                                verbose=True,  # Always use verbose mode
                                report=True,   # Always generate report
                                site_config=None,
                                progress=progress,
                                task_id=task
                            )
                        )
                    
                    # Restore original console
                    sys.modules['browser_automation.cli'].console = original_console
                    
                    # Display report if available
                    if output_path and Path(output_path).exists():
                        with open(output_path, 'r') as f:
                            report_content = f.read()
                            report_tab.markdown("### Final Report")
                            report_tab.markdown(report_content)
                    
                    output_area.markdown("✅ Complete")
                    
                finally:
                    loop.close()
                    
            except Exception as e:
                output_area.markdown(f"❌ Error: {str(e)}")

    def add_message(self, text: str, message_type: str = "info"):
        """Add a message to the queue to be displayed"""
        self.output_queue.put((text, message_type))

    def run(self):
        """Main entry point for the Streamlit UI"""
        self.render()

def main():
    ui = StreamlitUI()
    ui.run()

if __name__ == "__main__":
    main()
