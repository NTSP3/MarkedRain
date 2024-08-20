#!/bin/bash
#
# This shell script is used to create the directories specified in
# <argument-1> using format "root/<directory>" in the directory
# specified by <argument-2>
#
# Part of the MRain scripts source code.
#

# Fancy output functions
heading() {
    val_temp=${script_heading//<type>/$1}
    val_temp=${val_temp//<message>/$2}
    eval "${val_temp}"
}

info() {
    if [ "$2" = "wait" ]; then
        eval echo -en "${col_INFO}$1... ${col_NORMAL}" ${OUT}
    elif [ "$1" = "ok" ]; then
        if [ -z $2 ]; then
            eval echo -e "${col_DONE}OK${col_NORMAL}" ${OUT}
        else
            eval echo -e "${col_DONE}OK: $2${col_NORMAL}" ${OUT}
        fi
    elif [ "$3" = "stop" ]; then
        eval echo -e "${col_ERROR}Fail${col_NORMAL}" ${OUT}
        error "$1" "$2"
    else
        error "Specify an argument to me!" "info"
    fi
}

ok() {
    eval echo -e "$1: ${col_DONE}OK${col_NORMAL}" ${OUT}
}

error() {
    eval echo -e "${me}: $2: ${col_ERROR}$1${col_NORMAL}" >&2
    exit 1
}

# Gather arguments
me="$0"
src_file="$1"
dmp_folder="$2"

# Check if the variables are empty
heading "sub" "Checking arguments for nullified values"
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
heading "sub" "Checking for file & folder existence"
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
heading "sub" "Creating directories"
for dir in "${dirs[@]}"; do
    mkdir -p "$dir"
    ret=$?
    if [ ${ret} -eq 0 ]; then
        ok "$dir"
    else
        error "mkdir returned not code 0." "$dir"
    fi
done
