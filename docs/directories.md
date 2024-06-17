## Adding new directories

_21st of May, 2024: 11:11_

To add a new directory to the OS structure, do the following:

# Steps

1. Open "source/configs/dir.txt" in your favourite text editor.
2. Read the information displayed at the top.
3. Add your directory at the end of the file following the theme.

# Notes

The directory entry must look like this:

    root/<directory>

Examples:

    root/dir_in_root
    root/awesome/folder
    root/System/folder with Space
    root/Here's 1 with!Symbolssss

During compilation, if the folder was created correctly & command outputs are enabled, you would see this:

    ---[Creating directories]---
    <directory>: OK

if it failed, you would see this:

    ---[Creating directories]---
    mkdir: <error message>
    <directory>: mkdir returned not code 0.

## X--- End of the file ---X