#!/bin/bash

cat << EOF

# Load /etc/profile
[[ -f /etc/profile ]] && source /etc/profile

# Set prompt style
if [[ \$EUID -eq 0 ]]; then
    export PS1='%n@%m:%~>> '
else
    export PS1='%n@%m:%~> '
fi

EOF
