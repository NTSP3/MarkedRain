#!/bin/bash
#
# This shell script is used to increment a numeric value specified
# in <argument-1> and also add the timestamp of the value in the
# file specified by <argument-2>
#
# This file expects 'get_var.sh' to be in the same dir as this one is.
#
# Part of the MRain scripts source code.
#

# Colour codes
error='\e[1;91m'
default='\e[0m'

# Fancy output functions
error() {
    echo -e "${me}: $2: ${error}$1${default}"
    exit 1
}

# Set variables
me=$0
src_str=$1
out_file=$2
me_dir=$(dirname "$0")
compile_time=$(date '+%Y-%m-%d %H:%M:%S')

# Check if the variables are empty
if [ -z "$src_str" ]; then
    error "Variable cannot be empty. Check the first argument." "src_str"
else
    if [ -z "$out_file" ]; then
        error "Variable cannot be empty. Check the second argument." "out_file"
    fi
fi

# Check if the file exist
if [ ! -f "$out_file" ]; then
    error "The specified file doesn't exist." "out_file"
fi

# Call get_var.sh
number=$($me_dir/get_var.sh "$src_str" "$out_file")

# Check if the variable contains only numbers
if [[ "$number" =~ [^0-9] ]]; then
    error "Returned value contains non-numeric characters." "number"
fi

# Increment the value
number=$((number + 1))

# Use sed to find the line starting with 'latest=' and replace its value
sed -i "s/^latest=[0-9]*/latest=$number/" "$out_file"

# Use sed to put the os count information stuff
sed -i "/^latest=$number/a\\
$number - $compile_time" "$out_file"