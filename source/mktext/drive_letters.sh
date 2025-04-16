#!/bin/bash
# Text file appending: '<os>/etc/zprofile'

cat << EOF
export disk_path="/boot/disks"
mkdir -p "\$disk_path"

# Link root directory '/' with C: for linux kernel mod compatibility
[ ! -e "\$disk_path/C:" ] && ln -s / "\$disk_path/C:"

# Check if the user wants to switch drives
preexec() {
    # Get the command entered by the user
    local cmd="\$1"

    # Check if the command begins with the pattern '<letter>:'
    if [[ \$cmd =~ ^[a-zA-Z]: ]]; then
        local drive=\$(echo "\${cmd[1]}" | tr '[:lower:]' '[:upper:]')

        if [[ "\$drive" = "C" ]]; then
            builtin cd /
        else
            # Escape the colon to make sure it's treated literally
            local mount_point="\$disk_path/\${drive}:"

            # Change to the mount point, if it is actually a mount point
            if [ -d "\${mount_point}" ] && mountpoint -q "\${mount_point}"; then
                builtin cd "\${mount_point}"
            else
                echo "Invalid drive '\$drive'."
            fi
        fi
    fi
}

# Run before displaying prompt: Check if we are in the <disks> directory.
precmd() {
    if [[ "\$PWD" =~ ^\$disk_path/([A-Z]:)(/.*)?\$ ]]; then
        # Extract the path, excluding mount folder
        local cur_drive_path=\${PWD#\$disk_path}
        # Remove any trailing '/'
        cur_drive_path=\${cur_drive_path#/}
        # Add a trailing '/' if we are in root of the drive
        [[ \$cur_drive_path =~ ^[A-Z]:\$ ]] && cur_drive_path=\${cur_drive_path}/
        PROMPT=\$prompt_start\$cur_drive_path\$prompt_end

        # lol fun easter egg 16th april 2025 10:04pm
        if [[ \$cur_drive_path =~ ^C: ]]; then
            echo ""
            echo "Hehe you are trapped."
            echo "Try changing to any directory using 'cd' lol."
            echo "Or, you can type 'unstuck_me' to teleport to your home :)"
            echo "I guess just doing 'C:' works too :P"
            echo ""
        fi
    else
        PROMPT=\${prompt_start}C:'%~'\$prompt_end
    fi
}

#
# If the command wasn't found (file with some name like 'c:helloworld' or something)
# & begins with '<letter>:', then execute whatever is after it ('helloworld' in 'c:helloworld').
#
# The command after the letter does not affect the shell itself (eg. "c:cd etc" will not auto-switch the shell to /etc)
#
command_not_found_handler() {
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

# new cd() command that doesn't go beyond drive letter
function cd() {
    local newpath="\$1"

    # Check if we are currently in "/boot/disks/<letter>:"
    if [[ "\${PWD}/" =~ "^\${disk_path}/[a-zA-Z]:/" ]]; then
        # Capture drive letter
        local current_drive="\${match[1]}"

        # If it is null, set it to 'C:'
        [ -z \$current_drive ] && \$current_drive="C:"

        # Capture the destination
        newpath="\$(realpath -m "\$1" || echo)"

        # If the destination goes outside "disk_path/letter", set the path to the current drive
        if [[ ! "\${newpath}/" =~ ^\${disk_path}/[a-zA-Z]:/ ]]; then
            newpath="\${disk_path}/\${current_drive}"
        fi
    fi

    # Change directory
    builtin cd "\$newpath"
}

# fun
function unstuck_me {
    echo ""
    echo "Okay buddy, you're going to Home whether you like it or not."
    echo ""
    builtin cd "\$HOME"
}

EOF
