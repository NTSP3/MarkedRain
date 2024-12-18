#!/bin/bash
#
# This shell script is used to create text files by executing
# all *.sh files specified in <argument-1> and its sub-directories
# to the folder specified in <argument-2> while preserving the
# directory structure of <argument-1>'s directories and the name
# of the .sh file (The name will be the bit before the extension)
#
# Directories will be auto-created if not existing already.
# Part of the MRain scripts source code.
#
# 17 - 12 - 2024 @ 11:11 AM
#

# Fancy output functions
heading() {
    # Double substituting to account for double '\\'
    echo -e `echo -e ${col_SUBHEADING}`$1 `echo -e ${col_NORMAL}`::`echo -e ${col_INFO}` ${me} `echo -e ${col_NORMAL}`
}

ok() {
    echo -e $1: `echo -e ${col_DONE}`OK`echo -e ${col_NORMAL}`
}

error() {
    echo -e ${me}: $2: `echo -e ${col_ERROR}`$1`echo -e ${col_NORMAL}` >&2
    exit 1
}

# Gather arguments
me="$0"
src_folder="$1"
dmp_folder="$2"

# Check if the variables are empty
heading "Checking arguments for nullified values"
if [ -z "$src_folder" ]; then
    error "Variable cannot be empty. Check the first argument." "src_folder"
elif [ -z "$dmp_folder" ]; then
    error "Variable cannot be empty. Check the second argument." "dmp_folder"
fi

# Check if the source folder exist
heading "Checking for folder existence"
if [ ! -d "$src_folder" ]; then
    error "The specified folder doesn't exist." "src_folder"
fi

# Find all .sh files in $src_folder and process them
heading "Creating files"
find "$src_folder" -type f -name "*.sh" | while read -r script; do
    # Determine the relative path of the script
    relative_path="${script#$src_folder/}"
    # Remove ".sh" extension to get the output file name
    output_path="${relative_path%.sh}"
    # Construct the full path for the output file in $dmp_folder
    output_file="$dmp_folder/$output_path"
    
    # Create the parent directory structure for the output file
    mkdir -p "$(dirname "$output_file")"

    # Check if the file is to be appended or overwritten,
    # and then execute the script and redirect its output
    if [[ "$output_path" == *.append ]]; then
        # Strip .append from end
        append_file="${output_file%.append}"
        bash "$script" >> "$append_file" 2>&1
        ok "Appended '$script' to '$append_file'" # Update progress
    else
        bash "$script" > "$output_file" 2>&1
        ok "'$script' to '$output_file'" # Update progress
    fi
done