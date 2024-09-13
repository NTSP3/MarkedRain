#!/bin/bash
#
# This shell script is used to copy non-existing folders & non-existing
# files, and append to already existing files in the directory
# specified in <argument-2> from the directory specified in <argument-1>.
#
# Part of the MRain scripts source code.
#

# Fancy output functions
error() {
    eval echo -e "${me}: $2: ${col_ERROR}$1${col_NORMAL}" >&2
    exit 1
}

# Gather arguments
me="$0"
source="$1"
destination="$2"

# Check if the variables are empty
if [ -z "$source" ]; then
    error "Variable cannot be empty. Check the first argument." "source"
else
    if [ -z "$destination" ]; then
        error "Variable cannot be empty. Check the second argument." "destination"
    fi
fi

# Copy stuff that doesn't exist already
rsync -a --ignore-existing "$source/" "$destination"

# Append to files that exist already
find "$source" -type f | while read files; do
    dest_file="$destination${files#$source}"
    if [ -f "$dest_file" ]; then
        # If the file exists, append the contents
        cat "$files" >> "$dest_file"
    fi
done
