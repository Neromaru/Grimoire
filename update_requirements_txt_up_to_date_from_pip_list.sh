#!/bin/bash

# Create a temporary file
temp_file=$(mktemp)

# Get the current pip list in a format similar to requirements.txt
pip list --format=freeze > pip_versions.tmp

# Read each line from requirements.txt
while IFS= read -r package; do
    # Skip empty lines
    if [ -z "$package" ]; then
        continue
    fi

    # Extract package name (remove any version if present)
    package_name=$(echo "$package" | cut -d'=' -f1 | cut -d'>' -f1 | cut -d'<' -f1 | tr -d ' ')

    # Find the package with version in pip list
    version_line=$(grep -i "^${package_name}==" pip_versions.tmp)

    if [ -n "$version_line" ]; then
        # If found, use the version from pip list
        echo "$version_line" >> "$temp_file"
    else
        # If not found, keep the original line
        echo "$package" >> "$temp_file"
    fi
done < "requirements.txt"

# Replace the original requirements.txt with the new content
mv "$temp_file" requirements.txt

# Clean up temporary file
rm pip_versions.tmp

echo "Requirements file has been updated with current versions."