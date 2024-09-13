# Check if .hidden exists
if [ -f .hidden ]; then
    # List files with symbols (*/=>@|), replace spaces with '\ ', convert to hex
    list=$(ls -F | sed -e 's/ /\\ /g' | xxd -p | tr -d '\n')
    list=0a$list

    # Read .hidden line by line
    while IFS= read -r word; do
        # Convert word to hex
        word=$(echo -n "$word" | xxd -p | tr -d '\n')

        # Make hex patterns w/ symbols
        for symbol in '2a' '2f' '3d' '3e' '40' '7c'; do
            pattern="0a${word}${symbol}"

            # Remove the matching pattern from the hex-encoded list
            list=$(echo "$list" | sed "s/$pattern//g")
        done
    done < .hidden

    # Convert hex to ASCII
    list=$(echo "$list" | xxd -r -p)

    # Replace newlines with spaces
    list=$(echo "$list" | tr '\n' ' ')

    # Execute the command with the modified list
    eval ls $@ -d $list
else
    ls $@
fi
