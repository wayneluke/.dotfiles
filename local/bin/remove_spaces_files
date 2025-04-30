#!/bin/bash

# Check if a directory is provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

# Assign the directory to a variable
directory="$1"

# Check if the directory exists
if [ ! -d "$directory" ]; then
    echo "Error: Directory '$directory' does not exist."
    exit 1
fi

# Loop through files with spaces in the name
for file in "$directory"/*; do
    # Skip if no matching files
    if [ ! -e "$file" ]; then
        continue
    fi

    # Replace spaces with underscores
    new_file=$(echo "$file" | tr ' ' '_')

    # Rename the file
    if [ "$file" != "$new_file" ]; then
        mv "$file" "$new_file"
        echo "Renamed: '$file' -> '$new_file'"
    fi
done

echo "Done!"