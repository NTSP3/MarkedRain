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

# Text to display progress
text_kernel="Loading kernel..."
text_initrd="Loading initial ramdisk..."
text_boot="Booting system..."

# Gather number of spaces needed for text to be centered
space_kernel=${#text_kernel}                    # Text's length
space_kernel=$((total_column - space_kernel))   # Subtract length of text
space_kernel=$((space_kernel / 2))              # Half of remaining space
space_kernel=$(splitnum $space_kernel)          # Split the numbers
space_initrd=${#text_initrd}
space_initrd=$((total_column - space_initrd))
space_initrd=$((space_initrd / 2))
space_initrd=$(splitnum $space_initrd)
space_boot=${#text_boot}
space_boot=$((total_column - space_boot))
space_boot=$((space_boot / 2))
space_boot=$(splitnum $space_boot)

cat << EOF
default=$boot_default
timeout=$boot_timeout
set gfxmode=$boot_resolution
set gfxpayload=keep
loadfont /boot/grub/fonts/unicode.pf2
insmod gfxterm
insmod all_video
terminal_output gfxterm

# This function works as 'progress "<text>" "<num-of-spaces-to-make-text-centered>" "<num-of-bars-to-fill>" "<num-of-remaining-bars>"'
function progress {
    for line in $row; do
        echo ""
    done
    for space in \${2}; do
        echo -n " "
    done
    echo \${1}
    for column in \${3}; do
        echo -n "█"
    done
    for column in \${4}; do
        echo -n "▐"
    done
}

menuentry "$entry_name [Pretty]" {
    clear
    progress "$text_kernel" "$space_kernel" "$kernel_progress" "$kernel_remain"
    linux "$sys_dir_linux" root=$linux_root $linux_params quiet
    clear
    progress "$text_initrd" "$space_initrd" "$initrd_progress" "$initrd_remain"
    initrd "$sys_dir_initramfs"
    clear
    progress "$text_boot" "$space_boot" "$full_progress" ""
}

menuentry "$entry_name [Noisy]" {
    clear
    echo -n "Kernel location at '$sys_dir_linux', parameters '$linux_params console=ttyS0 console=tty0' "
    progress "$text_kernel" "$space_kernel" "$kernel_progress" "$kernel_remain"
    linux "$sys_dir_linux" root=$linux_root $linux_params console=ttyS0 console=tty0
    clear
    echo -n "InitRD location at '$sys_dir_initramfs'"
    progress "$text_initrd" "$space_initrd" "$initrd_progress" "$initrd_remain"
    initrd "$sys_dir_initramfs"
    clear
    echo -n "Kernel output mirrored to Serial port. Booting..."
    progress "$text_boot" "$space_boot" "$full_progress" ""
}

menuentry "$entry_name [Control from Serial/Terminal]" {
    echo ":: View ttyS0 for output & control."
    linux "$sys_dir_linux" root=$linux_root $linux_params console=ttyS0
    echo ">> Loaded linux kernel"
    initrd "$sys_dir_initramfs"
    echo ">> Loaded initramfs"
    echo ">> Booting"
}

menuentry "Boot from Floppy Disk" {
    set root=(fd0)
    chainloader +1
}

menuentry "Re-start your system" {
    reboot
}

menuentry "Shutdown your system" {
    halt
}

EOF
