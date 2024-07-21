#!/bin/bash
#
# This shell script is used to get a directory environment
# specified in <argument-1> from the file specified in
# <argument-2> and give it to the parent program using a
# return statement.
#
# Part of the MRain scripts source code.
#

# Colour codes
error='\e[1;91m'
default='\e[0m'

error() {
    echo -e "${me}: $2: ${error}$1${default}"
    exit 1
}

# Gather arguments
me=$0
dir_env=$1
src_file=$2

# Check if the variables are empty
if [ -z "$src_file" ]; then
    error "Variable cannot be empty. Check the first argument." "src_file"
else
    if [ -z "$dir_env" ]; then
        error "Variable cannot be empty. Check the second argument." "dir_env"
    fi
fi

# Check if the file exist
if [ ! -f "$src_file" ]; then
    error "The specified file doesn't exist." "src_file"
fi

# Look through the file for the variable
definition=$(grep -E "^${dir_env}=" "$src_file")

# Count the number of variable definitons
num_definitions=$(echo "$definition" | wc -l)

# Check if the number is less than or greater than one
if [ "$num_definitions" -eq 0 ] || [ -z "$definition" ]; then
    error "No definitions with '${dir_env}' found." "src_file"
elif [ "$num_definitions" -gt 1 ]; then
    error "More than one definition for '${dir_env}'. Cannot continue." "src_file"
else
    # Extract the value after the first equal symbol
    definition_value=$(echo "$definition" | cut -d'=' -f2-)
    echo $definition_value
fi
