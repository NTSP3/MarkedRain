#!/bin/bash

cat << EOF
# Load /etc/profile
[[ -f /etc/profile ]] && source /etc/profile

# Set prompt style
if [[ \$EUID -eq 0 ]]; then
    export prompt_start=''
    export prompt_end='>> '
    export PS1=\$prompt_start'%~'\$prompt_end
    export PS1_OG=\$prompt_start'%~'\$prompt_end
else
    export prompt_start='%n@%m:'
    export prompt_end='> '
    export PS1=\$prompt_start'%~'\$prompt_end
    export PS1_OG=\$prompt_start'%~'\$prompt_end
fi

# Fix 'del' character issue
bindkey '^[[3~' delete-char

EOF
