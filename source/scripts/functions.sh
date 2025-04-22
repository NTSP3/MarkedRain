#!/bin/bash
# Contains some functions

# Gather arguments
me="$0"
me_dir="$(dirname "$0")"

# Source main
source "${me_dir}/main"

# Fancy output functions
imp() {
	echo -e "${col_IMP} O.o !! $1 !! o.O ${col_NORMAL}"
}

heading() {
	echo ""
	echo -e "${col_HEADING}---[ $1 ]---${col_NORMAL}"
}

sub() {
	echo -e "${col_SUBHEADING}> $1 ${col_NORMAL}"
}

sub2() {
	echo -e "${col_SUBHEADING}>> $1 ${col_NORMAL}"
}

info() {
	echo -e "${col_INFOHEADING} ++ $1${col_INFOHEADING} ++ ${col_NORMAL}"
}

error() {
	echo ""
	echo -e "${col_ERROR}x_x >>> $1 <<< x_x${col_NORMAL}." >&2
	echo ""
	exit 1
}

# Clones GitHub repository
clone() {
	if [ -z "$1" ]; then
		error "Clonable .git link (second parameter) is empty."
	elif [ -z "$2" ]; then
		error "Destination path (third parameter) is empty"
	elif ! command -v git &> /dev/null; then
		error "git is not installed."
	fi

	# Add directory to git's safe list
	git config --global --get-all safe.directory | grep -Fxq "${CURDIR}/${2}" || git config --global --add safe.directory "${CURDIR}/${2}"

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
		info "Cloning $1 into $2..."
		git clone --depth 1 --progress "$1" "$2" || error "Cloning $1 into $2 failed."
	else
		error "'$2' is uninitialized and not empty."
	fi
}

# Downloads an internet item using curl
download() {
	if [ -z "$1" ]; then
		error "File's downloadable link (second parameter) is empty"
	elif [ -z "$2" ]; then
		error "Destination path (third parameter) is empty"
	elif ! command -v curl &> /dev/null; then
		error "curl is not installed."
	fi

	# If directory/file exists, exit
	if [ -e "$2" ]; then
		info "$2 already exists"
		exit
	fi

	# Start downloading the item
	info "Downloading $1 into $2..."
	curl -L "$1" -o "$2"

	if [ $? -ne 0 ]; then 
		error "While trying to download the item, curl failed!"
	fi
}

# Downloads and auto-extracts
download_and_extract() {
	if [ -z "$1" ]; then
		error "File's downloadable link (second parameter) is empty"
	elif [ -z "$2" ]; then
		error "Destination path (third parameter) is empty"
	elif ! command -v curl &> /dev/null; then
		error "curl is not installed."
	elif ! command -v zip &> /dev/null; then
		error "unzip is not installed."
	fi

	echo $2

	# If directory/file exists, exit
	if [ -e "$2" ]; then
		info "$2 already exists"
		exit
	fi

	# Check for temporary directory
	if [ ! -d "/tmp" ]; then
		error "/tmp does not exist"
	else
		[ -e "/tmp/markedrain_archive_to_extract" ] && rm -rf "/tmp/markedrain_archive_to_extract"
	fi

	# Download the archive
	download "$1" "/tmp/markedrain_archive_to_extract"

	# Extract the archive
	file_type=$(file "/tmp/markedrain_archive_to_extract")

	case "$file_type" in
		*"Zip archive data"*)
			# Extract the ZIP Archive
			info "Extracting $1 into $2..."
	    	unzip "/tmp/markedrain_archive_to_extract" -d "$2"
			if [ $? -ne 0 ]; then
				error "While extracting the item, unzip failed!"
			fi
			;;
		*)
			error "The file is of type '$file_type', which isn't recognized yet."
			;;
	esac

	# Delete the temp files
	[ -e "/tmp/markedrain_archive_to_extract" ] && rm -rf "/tmp/markedrain_archive_to_extract"
}

# Shorter way to get a variable's value using get_var.sh
get() {
	if [ -z "$1" ]; then
		error "Variable name is empty"
	elif [ -z "$2" ]; then
		error "Configuration filename is empty"
	fi

	${me_dir}/get_var.sh "$1" "$2"
}

# Shorter way to set a variable's value using set_var.sh
set() {
	if [ -z "$1" ]; then
		error "Variable name is empty"
	elif [ -z "$2" ]; then
		error "Variable value is empty"
	elif [ -z "$3" ]; then
		error "Configuration filename is empty"
	fi

	${me_dir}/set_var.sh "$1" "$2" "$3"
}

# Code to jump to functions
if declare -f "$1" > /dev/null; then
	func="$1"
	shift
	"$func" "$@"
else
	error "Function not found."
fi
