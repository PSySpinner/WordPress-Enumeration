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
```

## Usage
Enumerate a Single URL
To enumerate a single WordPress URL:
```bash
./wordpress_enum.sh <target.url> <output.format>
```

Enumerate Multiple URLs from a File
``` bash
./wordpress_enum.sh -f <file> <output.format>
```


## Supported Output Formats:
`html`: Generates a report in HTML format, including a snapshot of the site.
`markdown`: Generates a report in Markdown format.
`text`: Generates a plain text report.


## Output Files
The output files are saved as `target_url_sanitized_wordpress_enum.<format>`. Example: `example_com_wordpress_enum.html.`

### Example
Running the following command:
```bash
./wordpress_enum.sh https://example.com html
```
Will generate an HTML report named example_com_wordpress_enum.html with the following information:

WordPress version from the meta generator tag.
- List of detected plugins.
- List of detected themes.
- List of WordPress users.
- List of media.
- A snapshot of the website.


