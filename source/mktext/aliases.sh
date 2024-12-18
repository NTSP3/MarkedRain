#!/bin/sh
# Text file appending: '<os>/etc/profile'

cat <<EOF

marked-rain-list-not-hidden-function() {
    # Check if .hidden exists
    if [ -f .hidden ]; then
        # Get list of files, replace spaces with '\ ', and convert to hex
        list=\$(command ls -F | sed 's/ /\\ /g' | xxd -p | tr -d '\n')
        list="0a\$list"

        # Read .hidden line-by-line
        while IFS= read -r word; do
            # Convert word to hex
            word=\$(printf "%s" "\$word" | xxd -p | tr -d '\n')

            # Check if word exists in list (might save some cycles)
            if [[ "\$list" =~ "0a\$word" ]]; then
                # Remove patterns
                for symbol in '2a' '2f' '3d' '3e' '40' '7c'; do
                    list="\${list//0a\$word\$symbol/}"
                done
            fi
        done < .hidden

        # Convert hex to ASCII and replace newlines with spaces & remove '/'
        list=\$(printf "%s" "\$list" | xxd -r -p | tr '\n' ' ' | tr -d '/')

        # Execute the command with the modified list
        eval command ls "\$@" -d \$list
    else
        command ls "\$@"
    fi
}

# Great command aliases
alias cd.='cd .'
alias cd..='cd ..'
alias cls='clear'
alias copy='cp'
alias del='rm -i'
alias dir='ls -l'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alF'
alias ls='marked-rain-list-not-hidden-function --color=auto'
alias md='mkdir'
alias move='mv'
alias pause='read'
alias rd='rm -ri'
alias vdir='vdir --color=auto'

EOF
