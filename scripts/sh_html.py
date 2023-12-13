import re

def escape_html(text):
    """Escape HTML special characters in a given text."""
    return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")

def add_syntax_highlighting(line):
    """Add syntax highlighting to a line of shell script."""
    # Check for a comment and return early if found
    if line.strip().startswith('#'):
        return '<span class="green">' + escape_html(line) + '</span>'

    # Regex patterns for keywords and variables
    keyword_pattern = re.compile(r'\b(if|then|elif|fi|for|do|done|while|break|continue|case|esac|echo|import|in|as|from)\b')
    variable_pattern = re.compile(r'(\$[a-zA-Z_][a-zA-Z0-9_]*)')

    # Escape HTML characters
    line = escape_html(line)

    # Apply syntax highlighting
    line = keyword_pattern.sub(r'<span class="blue">\1</span>', line)
    line = variable_pattern.sub(r'<span class="orange">\1</span>', line)

    return line

def convert_shell_to_html(file_path):
    """Convert a shell script to HTML format."""
    html_lines = ['<pre><code>']
    with open(file_path, 'r') as file:
        for line in file:
            highlighted_line = add_syntax_highlighting(line.rstrip())
            html_lines.append(f'<span>{highlighted_line if highlighted_line.strip() else "&nbsp;"}</span>')
    html_lines.append('</code></pre>')
    return '\n'.join(html_lines)

# Path to your shell script
shell_script_path = './nuage_mot.py'

# Convert the shell script to HTML
html_content = convert_shell_to_html(shell_script_path)

# Optionally, save the HTML content to a file
with open('output.html', 'w') as html_file:
    html_file.write(html_content)

print("Conversion completed and saved to output.html")
