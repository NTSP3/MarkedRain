mrlshidefunction() {
    # Check if .hidden exists
    if [ -f .hidden ]; then
        # Get list of files, replace spaces with '\ ', and convert to hex
        list=$(ls -F | sed 's/ /\\ /g' | xxd -p | tr -d '\n')
        list="0a$list"

        # Read .hidden line-by-line
        while IFS= read -r word; do
            # Convert word to hex
            word=$(printf "%s" "$word" | xxd -p | tr -d '\n')

            # Check if word exist in list (might save some cycles)
            if [[ "$list" =~ "0a$word" ]]; then
                # Remove patterns
                for symbol in '2a' '2f' '3d' '3e' '40' '7c'; do
                    list="${list//0a${word}${symbol}/}"
                done
            fi
        done < .hidden

        # Convert hex to ASCII and replace newlines with spaces & remove '/'
        list=$(printf "%s" "$list" | xxd -r -p | tr '\n' ' ' | tr -d '/')

        # Execute the command with the modified list
        eval ls "$@" -d $list
    else
        ls "$@"
    fi
}
