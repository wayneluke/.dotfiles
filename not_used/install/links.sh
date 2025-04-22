#!/bin/bash

# List of directories to create symlinks for
directories=("/Volumes/Secondary/Files" "/Volumes/Secondary/Sites" "/Volumes/Secondary/Customers")

# Target directory for the symlinks
#target_dir="~/"
target_dir="~"

# Create the target directory if it doesn't exist
mkdir -p "$target_dir"

# Loop through each directory and create the symlink
for dir in "${directories[@]}"; do
    ln -s "$dir" "$target_dir"
done