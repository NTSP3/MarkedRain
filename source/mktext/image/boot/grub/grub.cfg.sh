#!/bin/sh
# Text file appending: '<img>/boot/grub/grub.cfg'

# Function
splitnum() {
    i=$1
    n=$1
    while [ "$i" -gt 3 ]; do
        i=$((i - 1))
        n="${i} ${n}"
    done
    echo "$n"
}

# Gather column in form of [.... 'num - 2' 'num - 1' 'num'] until reach 0
total_column=$(echo "$boot_resolution" | cut -d'x' -f1)
total_column=$((total_column / 8))
column=$(splitnum $total_column)

# Gather progress bar percentages (integer only)
kernel_progress=$((total_column / 3))
kernel_remain=$((total_column - kernel_progress))
kernel_progress=$(splitnum $kernel_progress)
kernel_remain=$(splitnum $kernel_remain)
initrd_progress=$((total_column * 2 / 3))
initrd_remain=$((total_column - initrd_progress))
initrd_progress=$(splitnum $initrd_progress)
initrd_remain=$(splitnum $initrd_remain)
full_progress=$(splitnum $(($total_column - 2)))

# Gather row in same form until reach num - 5
row=$(echo "$boot_resolution" | cut -d'x' -f2)
row=$((row / 16))
i=$row
while [ "$i" -gt 7 ]; do
    i=$((i - 1))
    row="${i} ${row}"
done

cat << EOF
default=$boot_default
timeout=$boot_timeout
set gfxmode=$boot_resolution
set gfxpayload=keep
loadfont /boot/grub/fonts/unicode.pf2
insmod gfxterm
insmod all_video
terminal_output gfxterm

# This function works as 'progress "<text>" "<num-of-bars-to-fill>" "<num-of-remaining-bars>"'
function progress {
    clear
    for line in $row; do
        echo ""
    done
    echo \${1}...
    for column in \${2}; do
        echo -n "█"
    done
    for column in \${3}; do
        echo -n "▐"
    done
}

menuentry "$entry_name" {
    progress "Loading kernel" "$kernel_progress" "$kernel_remain"
    linux "$sys_dir_linux" root=$linux_root $linux_params
    progress "Loading initial ramdisk" "$initrd_progress" "$initrd_remain"
    initrd "$sys_dir_initramfs"
    progress "Booting system" "$full_progress" ""
}

EOF
