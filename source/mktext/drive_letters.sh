#!/bin/bash
# Text file appending: '<os>/etc/zprofile'

cat << EOF
# Check if the user is asking to switch drives
export disk_path="$val_disks_path"
mkdir -p "\$disk_path/C:"
mount --bind / "\$disk_path/C:"

# Check if the user wants to switch drives
preexec() {
    # Get the command entered by the user
    local cmd="\$1"

    # Check if the command begins with the pattern '<letter>:'
    if [[ \$cmd =~ ^[a-zA-Z]: ]]; then
        local drive=\$(echo "\${cmd[1]}" | tr '[:lower:]' '[:upper:]')

        # Escape the colon to make sure it's treated literally
        local mount_point="\$disk_path/\${drive}:"

        # Change to the mount point, if it is actually a mount point
        if [ -d "\${mount_point}" ] && mountpoint -q "\${mount_point}"; then
            cd "\${mount_point}"
        else
            echo "Invalid drive '\$drive'."
        fi
    fi
}

# Run before displaying prompt: Check if we are in the /disks (val_disks_path) directory.
precmd() {
    if [[ "\$PWD" =~ ^\$disk_path/([A-Za-z]:)(/.*)?\$ ]]; then
        # Extract the path, excluding mount folder
        local cur_drive_path=\${PWD#\$disk_path}
        cur_drive_path=\${cur_drive_path#/}
        PROMPT=\$prompt_start\$cur_drive_path\$prompt_end
    else
        PROMPT=\$prompt_start'%~'\$prompt_end
    fi
}

# If the command wasn't found (file with some name like 'c:' or something)
# & begins with '<letter>:', then execute whatever is after it.
command_not_found_handler () {
    local string="\$*"
    if [[ \$string =~ ^[a-zA-Z]: ]]; then
        # Skip the '<letter>:' bit
        local cmd="\${string:2}"
        # Execute the command
        eval "\$cmd"
        # Return the status of cmd
        return \$?
    else
        echo "Bad command -" \${string}
        return 127
    fi
}
EOF