#!/bin/bash
# Contains some functions

# Gather arguments
me="$0"
me_dir="$(dirname "$0")"

# Source main
source "${me_dir}/main"

# Fancy output functions
heading() {
	echo -e "${col_HEADING}>>> $1 ${col_NORMAL}"
}

error() {
	echo ""
	echo -e "${col_ERROR}>>> $1${col_NORMAL}." >&2
	echo ""
	exit 1
}

# Clones GitHub repository
clone() {
	if [ -z "$1" ]; then
		error "Source git link is empty"
	elif [ -z "$2" ]; then
		error "Destination path is empty"
	elif ! command -v git &> /dev/null; then
		error "Git is not installed."
	fi

	# Add directory to github's safe list
	git config --global --get-all safe.directory | grep -Fxq "${val_mkfile_dir}/${2}" || git config --global --add safe.directory "${val_mkfile_dir}/${2}"

	# If directory exists and is a git repo, verify URL.
	if [ -d "$2/.git" ]; then
		cd "$2" || error "Failed to enter directory $2."
		CUR=$(git config --get remote.origin.url)
		if [ "$CUR" != "$1" ]; then
			error "Repo URL mismatch ($CUR vs $1)."
		fi
	# If directory exists but not initialized OR directory doesn't exist, check if empty.
	elif [ ! -d "$2" ] || [ -z "$(ls -A "$2" 2>/dev/null)" ]; then
		[ -d "$2" ] && rmdir "$2"
		heading "Cloning $1 into $2..."
		git clone --progress "$1" "$2" || error "Cloning $1 into $2 failed."
	else
		error "'$2' is uninitialized and not empty."
	fi
}

# Code to jump to functions
if declare -f "$1" > /dev/null; then
	func="$1"
	shift
	"$func" "$@"
else
	error "Function not found."
fi
