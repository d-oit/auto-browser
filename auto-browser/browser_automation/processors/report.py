"""Report generation module for auto-browser."""

import os
from typing import Dict, Any
from langchain_core.language_models import BaseLLM
from langchain_openai import ChatOpenAI
from langchain_google_genai import ChatGoogleGenerativeAI

class ReportGenerator:
    """Generate structured reports from extracted content."""

    def __init__(self):
        """Initialize the report generator."""
        self.llm_provider = os.getenv('LLM_PROVIDER')
        self.llm_model = os.getenv('LLM_MODEL', 'gpt-4o-mini')
        self.api_key = os.getenv('OPENAI_API_KEY')
        self.google_api_key = os.getenv('GOOGLE_API_KEY')

        if self.llm_provider == 'openai':
            self.llm = ChatOpenAI(api_key=self.api_key, model=self.llm_model)
        elif self.llm_provider == 'google':
            self.llm = ChatGoogleGenerativeAI(model=self.llm_model, google_api_key=self.google_api_key)
        else:
            raise ValueError(f"Unsupported LLM provider: {self.llm_provider}")

    def generate_report(self, content: Dict[str, Any], prompt: str) -> str:
        """Generate a structured markdown report.

        Args:
            content: Extracted content from webpage
            prompt: Original user prompt describing the task

        Returns:
            Structured markdown report
        """
        system_prompt = """
        You are a report generator that creates well-structured markdown reports.
        Create a comprehensive report based on the provided content and original task prompt.

        Use markdown formatting to create:
        - Clear section headers
        - Tables for structured data
        - Bullet points for lists
        - Code blocks for technical content
        - Blockquotes for important notes

        Focus on:
        1. Summarizing key findings
        2. Organizing data in tables where appropriate
        3. Highlighting important insights
        4. Providing context and analysis
        5. Making recommendations if relevant

        Use this structure:
        # Report Title
        ## Executive Summary
        Brief overview of findings

        ## Analysis Details
        Detailed findings in tables/lists

        ## Key Insights
        Important takeaways

        ## Additional Context
        Any relevant background or context
        """

        user_prompt = f"""
        Original Task: {prompt}

        Content to Analyze:
        {content}

        Generate a structured report focusing on the task objectives.
        """

        messages = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt}
        ]

        response = self.llm.invoke(messages)
        return response.content

    def format_data_table(self, data: Dict[str, Any]) -> str:
        """Format data as a markdown table.

        Args:
            data: Dictionary of data to format

        Returns:
            Markdown table string
        """
        if not data:
            return ""

        # Get all keys
        headers = list(data.keys())

        # Create table header
        table = "| " + " | ".join(headers) + " |\n"
        table += "|-" + "-|-".join(["-" * len(header) for header in headers]) + "-|\n"

        # Create table row
        values = [str(data[header]) for header in headers]
        table += "| " + " | ".join(values) + " |"

        return table
