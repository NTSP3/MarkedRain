#!/bin/bash
#
# This shell script is used to create the directories specified in
# <argument-1> using format "root/<directory>" in the directory
# specified by <argument-2>
#
# Part of the MRain scripts source code.
#
# Todo: Add this into makefile so the dirs can be created using menuconfig (else error when changing sys dir)

# Colour codes
info='\e[30;46m'
subinfo='\e[36m'
ok='\e[1;32m'
error='\e[1;91m'
default='\e[0m'

# Fancy output functions
info() {
    echo -e "${info}---[$1]---${default}"
}

subinfo() {
    if [ "$2" = "wait" ]; then
        echo -e -n "${subinfo}$1... ${default}"
    elif [ "$1" = "ok" ]; then
        if [ -z $2 ]; then
            echo -e "${ok}OK${default}"
        else
            echo -e "${ok}OK: $2${default}"
        fi
    elif [ "$3" = "stop" ]; then
        echo -e "${error}Fail${default}"
        error "$1" "$2"
    else
        error "Specify an argument to me!" "subinfo"
    fi
}

ok() {
    echo -e "$1: ${ok}OK${default}"
}

error() {
    echo -e "$2: ${error}$1${default}"
    exit 1
}

# Gather arguments
src_file=$1
dmp_folder=$2

# Check if the variables are empty
info "Checking arguments for nullified values"
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
info "Checking for file & folder existence"
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

# Gather info from the file
subinfo "Gathering directories to create" "wait"
lines=$(grep '^root' "$src_file")
subinfo "ok"

# Replace 'root' with the bin directory
subinfo "Replacing 'root' with the bin directory" "wait"
dirs=()
while IFS= read -r line; do
    dir="${dmp_folder}${line:4}"
    dirs+=("$dir")
done <<< "$lines"
subinfo "ok"

# Start creating the directories
info "Creating directories"
for dir in "${dirs[@]}"; do
    mkdir -p "$dir"
    ret=$?
    if [ ${ret} -eq 0 ]; then
        ok "$dir"
    else
        error "mkdir returned not code 0." "$dir"
    fi
done
