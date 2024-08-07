#!/bin/bash
#
# This shell script is used to increment a numeric value specified
# in <argument-1> and also add the timestamp of the value in the
# file specified by <argument-2>. It also asks for the build's
# description.
#
# This file expects 'get_var.sh' to be in the same dir as this one is.
#
# Part of the MRain scripts source code.
#

# Fancy output functions
subinfo() {
    echo -e "${col_subinfo}     / $1 / ${col_normal}"
}

info() {
    echo -e "${col_info} ++ $1 ++${col_normal}  ::  ${col_false}${me}${col_normal}"
}

error() {
    echo -e "${me}: $2: ${col_error}$1${col_normal}"
    exit 1
}

# Set variables
me="$0"
src_str="$1"
out_file="$2"
me_dir=$(dirname "$0")
time=$(date '+%Y-%m-%d %H:%M:%S')

# Check if the variables are empty
if [ -z "$src_str" ]; then
    error "Variable cannot be empty. Check the first argument." "src_str"
elif [ -z "$out_file" ]; then
    error "Variable cannot be empty. Check the second argument." "out_file"
elif ! [[ $mkfile_EXTRAVERSION =~ ^[0-9]+$ ]]; then
    error "Value of the third argument contains non-numeric characters or is empty." "mkfile_EXTRAVERSION"
fi

# Check if the file exist
if [ ! -f "$out_file" ]; then
    error "The specified file doesn't exist." "$out_file"
fi

# Call get_var.sh to get the value of $src_str
current_number=$($me_dir/get_var.sh "$src_str" "$out_file")

# Check if the variable contains only numbers
if ! [[ $current_number =~ ^[0-9]+$ ]]; then
    error "Returned value contains non-numeric characters." "current_number - $current_number"
fi

echo -ne " ${col_info} Build description ${col_normal}[${col_false}NULL = Cancel${col_normal}] : "
read desc

if [ -z $desc ]; then
    info "Cancelled"
    exit 0
fi

# Display what is happening
subinfo "Invoking build number updater"

# Increment the value
new_number=$((current_number + 1))

# Call set_var.sh to set the value of $src_str
$me_dir/set_var.sh "$src_str" "$new_number" "$out_file"

# Use sed to put the os count information stuff
sed -i "/^$src_str=$new_number/a\\
$current_number - $time : $desc" "$out_file"