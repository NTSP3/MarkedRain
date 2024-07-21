#!/bin/bash
#
# This shell script is used to create the directories specified in
# <argument-1> using format "root/<directory>" in the directory
# specified by <argument-2>
#
# Part of the MRain scripts source code.
#

# Colour codes
col_heading="\e[30;46m"
col_info="\e[36m"
col_ok="\e[1;32m"
col_error="\e[1;91m"
col_normal="\e[0m"

# Fancy output functions
heading() {
    echo -e "${col_heading}---[ $1 ]---${col_normal}"
}

info() {
    if [ "$2" = "wait" ]; then
        echo -e -n "${col_info}$1... ${col_normal}"
    elif [ "$1" = "ok" ]; then
        if [ -z $2 ]; then
            echo -e "${col_ok}OK${col_normal}"
        else
            echo -e "${col_ok}OK: $2${col_normal}"
        fi
    elif [ "$3" = "stop" ]; then
        echo -e "${col_error}Fail${col_normal}"
        error "$1" "$2"
    else
        error "Specify an argument to me!" "info"
    fi
}

ok() {
    echo -e "$1: ${col_ok}OK${col_normal}"
}

error() {
    echo -e "$2: ${col_error}$1${col_normal}"
    exit 1
}

# Gather arguments
src_file="$1"
dmp_folder="$2"

# Check if the variables are empty
heading "Checking arguments for nullified values"
if [ -z "$src_file" ]; then
    error "Variable cannot be empty. Check the first argument." "src_file"
else
    ok "src_file"
    if [ -z "$dmp_folder" ]; then
      error "Variable cannot be empty. Check the second argument." "dmp_folder"
    else
      ok "dmp_folder"
    fi
fi

# Check if the file & folder exist
heading "Checking for file & folder existence"
if [ -f "$src_file" ]; then
    ok "src_file"
    if [ -d "$dmp_folder" ]; then
        ok "dmp_folder"
    else
        error "The specified folder doesn't exist." "dmp_folder"
    fi
else
    error "The specified file doesn't exist." "src_file"
fi

# Gather heading from the file
info "Gathering directories to create" "wait"
lines=$(grep '^root' "$src_file")
info "ok"

# Replace 'root' with the bin directory
info "Replacing 'root' with the bin directory" "wait"
dirs=()
while IFS= read -r line; do
    dir="${dmp_folder}${line:4}"
    dirs+=("$dir")
done <<< "$lines"
info "ok"

# Start creating the directories
heading "Creating directories"
for dir in "${dirs[@]}"; do
    mkdir -p "$dir"
    ret=$?
    if [ ${ret} -eq 0 ]; then
        ok "$dir"
    else
        error "mkdir returned not code 0." "$dir"
    fi
done
