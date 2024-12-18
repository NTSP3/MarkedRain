#!/bin/bash

cat << EOF

# Set prompt style
if [[ \$EUID -eq 0 ]]; then
    export PS1='%n@%m:%~>> '
else
    export PS1='%n@%m:%~> '
fi

EOF