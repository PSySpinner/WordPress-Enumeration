#!/bin/bash

# Function to display usage information
usage() {
  echo "Usage: $0 [-f <file> | <target.url>] <output.format>"
  echo "Output format options: html, markdown, text"
  exit 1
}

# Function to sanitize URLs to create valid filenames
sanitize_url() {
  echo "$1" | sed 's/[^a-zA-Z0-9]/_/g'
}

# Check if -f flag is used for file input
if [ "$1" == "-f" ]; then
  if [ -z "$2" ] || [ -z "$3" ]; then
    usage
  fi
  FILE="$2"
  FORMAT="$3"
  if [ ! -f "$FILE" ]; then
    echo "Error: File not found!"
    exit 1
  fi

  # Loop through each URL in the file
  while IFS= read -r TARGET_URL; do
    TARGET_URL=$(echo "$TARGET_URL" | xargs) # Trim whitespace
    if [ -n "$TARGET_URL" ]; then
      SANITIZED_URL=$(sanitize_url "$TARGET_URL")
      
      case "$FORMAT" in
        html) output_file="${SANITIZED_URL}_wordpress_enum.html" ;;
        markdown) output_file="${SANITIZED_URL}_wordpress_enum.md" ;;
        text) output_file="${SANITIZED_URL}_wordpress_enum.txt" ;;
        *) usage ;;
      esac
      
      # Fetch the page content
      echo "Fetching data from $TARGET_URL..."
      response=$(curl -s -X GET "$TARGET_URL")

      # Check if the response is empty
      if [ -z "$response" ]; then
        echo "Error: No data fetched from $TARGET_URL."
        continue
      fi

      # Create output file
      echo "Generating output in $FORMAT format for $TARGET_URL..."
      
      # Initialize the output file
      case "$FORMAT" in
        html)
          echo "<html><head><title>WordPress Enumeration Report</title></head><body>" > $output_file
          echo "<h1>WordPress Enumeration Report</h1>" >> $output_file
          ;;
        markdown)
          echo "# WordPress Enumeration Report" > $output_file
          ;;
        text)
          echo "WordPress Enumeration Report" > $output_file
          echo "" >> $output_file
          ;;
      esac

      # Meta generator tags
      echo "Processing meta generator tags..."
      meta_tags=$(echo "$response" | grep '<meta name="generator"' | sed 's/.*content="\([^"]*\)".*/\1/')
      case "$FORMAT" in
        html)
          echo "<h2>Meta Generator Tags</h2>" >> $output_file
          echo "<p style='color: red;'>$meta_tags</p>" >> $output_file
          ;;
        markdown)
          echo "## Meta Generator Tags" >> $output_file
          echo "$meta_tags" >> $output_file
          ;;
        text)
          echo "Meta Generator Tags" >> $output_file
          echo "===================" >> $output_file
          echo "$meta_tags" >> $output_file
          echo "" >> $output_file
          ;;
      esac

      # Plugins
      echo "Enumerating plugins..."
      plugins=$(echo "$response" | sed 's/href=/\n/g' | sed 's/src=/\n/g' | grep 'wp-content/plugins/' | cut -d"'" -f2)
      case "$FORMAT" in
        html)
          echo "<h2>Plugins</h2>" >> $output_file
          echo "<ul>" >> $output_file
          echo "$plugins" | while read -r plugin; do
            echo "<li>$plugin</li>" >> $output_file
          done
          echo "</ul>" >> $output_file
          ;;
        markdown)
          echo "## Plugins" >> $output_file
          echo "$plugins" | while read -r plugin; do
            echo "- $plugin" >> $output_file
          done
          ;;
        text)
          echo "Plugins" >> $output_file
          echo "========" >> $output_file
          echo "$plugins" | while read -r plugin; do
            echo "$plugin" >> $output_file
          done
          echo "" >> $output_file
          ;;
      esac

      # Themes
      echo "Enumerating themes..."
      themes=$(echo "$response" | sed 's/href=/\n/g' | sed 's/src=/\n/g' | grep 'wp-content/themes/' | cut -d"'" -f2)
      case "$FORMAT" in
        html)
          echo "<h2>Themes</h2>" >> $output_file
          echo "<ul>" >> $output_file
          echo "$themes" | while read -r theme; do
            echo "<li>$theme</li>" >> $output_file
          done
          echo "</ul>" >> $output_file
          ;;
        markdown)
          echo "## Themes" >> $output_file
          echo "$themes" | while read -r theme; do
            echo "- $theme" >> $output_file
          done
          ;;
        text)
          echo "Themes" >> $output_file
          echo "========" >> $output_file
          echo "$themes" | while read -r theme; do
            echo "$theme" >> $output_file
          done
          echo "" >> $output_file
          ;;
      esac

      # Users
      echo "Fetching users..."
      users=$(curl -s -X GET "$TARGET_URL/wp-json/wp/v2/users" | jq -r '.[] | "\(.id): \(.name) (\(.slug))"')
      case "$FORMAT" in
        html)
          echo "<h2>Users</h2>" >> $output_file
          echo "<ul>" >> $output_file
          echo "$users" | while read -r user; do
            echo "<li>$user</li>" >> $output_file
          done
          echo "</ul>" >> $output_file
          ;;
        markdown)
          echo "## Users" >> $output_file
          echo "$users" | while read -r user; do
            echo "- $user" >> $output_file
          done
          ;;
        text)
          echo "Users" >> $output_file
          echo "=====" >> $output_file
          echo "$users" | while read -r user; do
            echo "$user" >> $output_file
          done
          ;;
      esac

      # Media
      echo "Fetching media..."
      media=$(curl -s -X GET "$TARGET_URL/wp-json/wp/v2/media" | jq -r '.[] | "\(.id): \(.source_url)"')
      case "$FORMAT" in
        html)
          echo "<h2>Media</h2>" >> $output_file
          echo "<ul>" >> $output_file
          echo "$media" | while read -r media_item; do
            echo "<li>$media_item</li>" >> $output_file
          done
          echo "</ul>" >> $output_file
          ;;
        markdown)
          echo "## Media" >> $output_file
          echo "$media" | while read -r media_item; do
            echo "- $media_item" >> $output_file
          done
          ;;
        text)
          echo "Media" >> $output_file
          echo "=====" >> $output_file
          echo "$media" | while read -r media_item; do
            echo "$media_item" >> $output_file
          done
          ;;
      esac

      # Take a snapshot of the site using wkhtmltoimage
      snapshot_file="${SANITIZED_URL}_snapshot.png"
      wkhtmltoimage "$TARGET_URL" "$snapshot_file"

      # Add snapshot to HTML output
      if [ "$FORMAT" == "html" ]; then
        echo "<h2>Snapshot of the Site</h2>" >> $output_file
        echo "<img src=\"$snapshot_file\" alt=\"Snapshot of $TARGET_URL\" style=\"width:600px;\">" >> $output_file
      fi

      # Add footer with creator info
      case "$FORMAT" in
        html)
          echo "<footer><p><strong style='color: red;'>Dark0wl</strong></p></footer></body></html>" >> $output_file
          ;;
        markdown)
          echo "" >> $output_file
          echo "**Dark0wl**" >> $output_file
          ;;
        text)
          echo "" >> $output_file
          echo "**Dark0wl**" >> $output_file
          ;;
      esac

      echo "Output saved to $output_file"
    fi
  done < "$FILE"

else
  # Process a single URL
  if [ -z "$1" ] || [ -z "$2" ]; then
    usage
  fi
  TARGET_URL="$1"
  FORMAT="$2"
  
  SANITIZED_URL=$(sanitize_url "$TARGET_URL")
  case "$FORMAT" in
    html) output_file="${SANITIZED_URL}_wordpress_enum.html" ;;
    markdown) output_file="${SANITIZED_URL}_wordpress_enum.md" ;;
    text) output_file="${SANITIZED_URL}_wordpress_enum.txt" ;;
    *) usage ;;
  esac
  
  # Fetch the page content
  echo "Fetching data from $TARGET_URL..."
  response=$(curl -s -X GET "$TARGET_URL")

  # Check if the response is empty
  if [ -z "$response" ]; then
    echo "Error: No data fetched from $TARGET_URL."
    exit 1
  fi

  # Initialize the output file and generate the report (repeat the logic above for a single URL)
  # Same code as in the file processing section...
fi
