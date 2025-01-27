# UnicodeEncodeError in Markdown Formatter

## Error Description
A `UnicodeEncodeError` occurred when attempting to save markdown content to a file. The error message was:
```
UnicodeEncodeError: 'charmap' codec can't encode character '\U0001f517' in position 159: character maps to <undefined>
```

## Cause
The error is caused by the default encoding used by the `write_text` method, which does not support the Unicode character '\U0001f517'. This character is a Unicode emoji.

## Resolution
To resolve this issue, the `save_markdown` method in the `markdown.py` file was modified to explicitly specify the 'utf-8' encoding when writing the file. This ensures that all Unicode characters are properly encoded.

## Steps Taken
1. Located the `save_markdown` method in the `markdown.py` file.
2. Modified the method to use 'utf-8' encoding.
3. Tested the changes to ensure the error is resolved.

## Reference
The `save_markdown` method in the `markdown.py` file was updated as follows:
```python
def save_markdown(self, content: str, url: str, output_dir: str = "output") -> Path:
    """Save markdown content to file with unique name."""
    # Create unique filename
    filename = self._create_filename(url)

    # Ensure output directory exists
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)

    # Save content
    file_path = output_path / filename
    file_path.write_text(content, encoding='utf-8')
    return file_path
```

## Conclusion
The UnicodeEncodeError has been resolved by ensuring that the 'utf-8' encoding is used when writing the markdown content to a file.