#!/usr/bin/env bash

# Script to update the version number in README.md and install.sh

# Function to display usage information
usage() {
    echo "Usage: $0 <current_version> <new_version>"
    echo "Example: $0 v0.1.1 v0.1.2"
}

# Function to validate version number format
validate_version() {
    if [[ ! $1 =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "Error: Version number $1 is not in the correct format (e.g., v0.1.2)"
        exit 1
    fi
}

# Function to update version number in a file
update_version_in_file() {
    file=$1
    current_version=$2
    new_version=$3

    # Use different syntax based on sed version
    if sed --version 2>/dev/null | grep -q GNU; then
        # GNU sed
        sed -i "s/$current_version/$new_version/g" "$file"
    else
        # BSD sed
        sed -i '' "s/$current_version/$new_version/g" "$file"
    fi
}

# Ensure two arguments are passed
if [ "$#" -ne 2 ]; then
    echo "Error: Illegal number of parameters."
    usage
    exit 1
fi

# Assign arguments to variables for better readability
current_version=$1
new_version=$2

# Validate both version numbers
validate_version "$current_version"
validate_version "$new_version"

# Function to update version number in a file
update_version() {
    local file=$1
    if [ -f "$file" ]; then
        update_version_in_file "$file" "$current_version" "$new_version"
        echo "Updated version in $file to $new_version"
    else
        echo "Warning: File $file not found. Version not updated."
    fi
}

# Update version numbers in files
update_version "README.md"
update_version "install.sh"

# Next steps
# - Commit the changes
# - Push the changes to git
# - Create a new tag for the new version
# - Push the new tag to git
# - Create a new release on GitHub
# - Publish the release notes
