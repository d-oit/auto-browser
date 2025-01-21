import asyncio
import pytest
import sys
import os
from unittest.mock import patch, MagicMock
from pathlib import Path
from io import StringIO
from rich.console import Console
from browser_automation.cli import run_all_tasks, console
from browser_automation.template_generator import Template, Selector
from browser_automation.processors.report import ReportGenerator

class MockStreamlit:
    def __init__(self):
        self.output = []
        
    def markdown(self, text):
        self.output.append(text)

class TestUI:
    @pytest.mark.asyncio
    async def test_run_task_output(self):
        # Mock streamlit output area
        output_area = MockStreamlit()
        
        # Create a custom console for testing
        class TestConsole(Console):
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
                print(f"Debug - Output sent to UI: {formatted_output}")  # Debug print
        
        # Create console and run test
        test_console = TestConsole(output_area)
        
        # Run a simple test task
        test_url = "https://example.com"
        test_command = "Extract the main heading"
        
        # Create a mock template for testing
        mock_template = Template(
            name='test',
            description='Test template',
            url_pattern='https://example.com',
            selectors={
                'main_heading': Selector(
                    css='.main-heading',
                    description='Main page heading',
                    multiple=False
                )
            }
        )
        
        try:
            # Set up environment variables
            os.environ['OPENAI_API_KEY'] = 'dummy-key-for-testing'
            
            # Replace the global console with our test console
            original_console = sys.modules['browser_automation.cli'].console
            sys.modules['browser_automation.cli'].console = test_console
            
            try:
                # Mock OpenAI API calls
                mock_response = MagicMock()
                mock_response.content = "Test report content"
                
                # Mock both template generator and report generator
                with patch('browser_automation.template_generator.TemplateGenerator.create_template') as mock_create_template, \
                     patch('langchain_openai.ChatOpenAI.invoke') as mock_invoke:
                    mock_create_template.return_value = mock_template
                    mock_invoke.return_value = mock_response
                    
                    output_path = await run_all_tasks(
                        url=test_url,
                        prompt=test_command,
                        interactive=False,
                        verbose=True,
                        report=True,
                        site_config=None,
                        progress=None,
                        task_id=None
                    )
            finally:
                # Restore original console
                sys.modules['browser_automation.cli'].console = original_console
            
            # Verify we got some output
            assert len(output_area.output) > 0, "No output was captured"
            
            # Check for expected output patterns
            output_text = "\n".join(output_area.output)
            assert "🔧" in output_text, "Missing initialization emoji"
            assert "🔍" in output_text, "Missing analysis emoji"
            
            # Check if report was generated
            if output_path:
                assert Path(output_path).exists(), "Report file was not created"
            
            print("Test passed successfully!")
            print(f"Number of output lines: {len(output_area.output)}")
            print("Sample output:")
            for line in output_area.output[:5]:  # Show first 5 lines
                print(f"  {line}")
                
        except Exception as e:
            print(f"Test failed with error: {str(e)}")
            raise

if __name__ == "__main__":
    # Run the test
    asyncio.run(TestUI().test_run_task_output())
