# WordPress-Enumeration

# WordPress Enumeration Script

## Description
This script is designed to automate the enumeration of WordPress websites. It can extract information such as:

- Meta generator tags (WordPress version and other CMS info)
- Installed plugins
- Installed themes
- Users (from the `/wp-json/wp/v2/users` endpoint)
- Media (from the `/wp-json/wp/v2/media` endpoint)
- A snapshot of the website (HTML format only)

The output can be generated in three different formats: HTML, Markdown, or plain text.

## Features
- **Single URL or Multiple URLs**: Target either a single URL or use a file containing multiple URLs.
- **Snapshot**: The script can take a screenshot of the target website (HTML output only).
- **Flexible Output**: Generate reports in HTML, Markdown, or plain text format.
- **File or Single Target Input**: Specify either a single target URL or a file with multiple targets.

## Requirements
Ensure the following tools are installed:

- `curl`: Used to fetch data from the target URLs.
- `jq`: Required to parse JSON responses from WordPress's REST API.
- `wkhtmltoimage`: Needed for capturing snapshots of websites in HTML reports.

You can install these dependencies with the following commands:

```bash
# Install curl and jq
sudo apt-get install curl jq

# Install wkhtmltoimage (if not installed)
sudo apt-get install wkhtmltopdf

