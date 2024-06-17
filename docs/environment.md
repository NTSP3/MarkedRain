## Editing the System environment

_21st of May, 2024: 12:52_

You can edit the variables that point to the system directories used when making the Operating System to point to different things with a single file. This file is located within the source configuration folder, typically "source/configs" (very creative). It houses the purpose of each folders as needed by the makefile. For example, you can change "system_directory" to "toothbrush" and have the system point to that as its directory. Although, changing that is not recommended.

# Steps

1. Open "source/configs/environment.txt" in your favourite text editor.
2. Read the information displayed at the top.
3. Change a definition, or add in your own.
4. If added, you need to update Makefile to make use of that. Get the value by doing:

    source/scripts/get_sys_dir.sh <entry> source/configs/environment.txt

# Notes

The definition must look like this:

    <entry>=<value>

Examples:

    kitty=meow.====these-equals-would-be-shown-too====
    best_human_in_world=You.
    Tux=Linux ate my lunch
    Jack off leader=has-not-had-much-success

If the value has spaces, they are not an issue, as the output would look like:

    OK: Linux ate my lunch

& if the variable itself has spaces, you want the command to be:

    get_sys_dir.sh Jack\ off\ leader environment.txt

If it found the correct value & Makefile's command outputs are enabled, you would see this:

    OK: <value_of_the_variable>

if it failed, you would see this:

    get_sys_dir.sh: <section>: <error>

## X--- End of the file ---X