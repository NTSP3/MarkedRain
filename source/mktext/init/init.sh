#!/bin/sh
# Text file creation: '<src>/initramfs/source/init'

cat <<EOF
#!/bin/sh
##
## MarkedRain Linux [18-10-2024 @ 5:12PM]
##
## This init script mounts the .squashfs compressed archive
## into a tmpfs folder, meaning that its contents will stay
## on the memory itself and not make any changes to the
## real disk, allowing it to have read/write access, even
## if it is booting from a read-only file system
## (effectively acting like a live-cd)
##

#
# Functions
#

# This calls 'error' if given command returns false.
cmd() {
    eval "\$1"
    if [ \$? -ne 0 ]; then
        error "\$2"
    fi
}

error() {
    echo ""
    echo "Error: \$1"
    echo "Launching busybox emergency init system..."
    echo ""
    exec /sbin/init
}

info() {
    echo "-> \$1"
}

#
# Make directories
#

mkdir -p /dev /proc /sys /mnt /mnt/lower /mnt/upper /mnt/disk /mnt/overlay

#
# Mount required directories (proc, dev, sys)
#

info "Initializing system paths"
cmd "mount -t devtmpfs devtmpfs /dev" "Failed mounting /dev"
cmd "mount -t proc proc /proc" "Failed mounting /proc"
cmd "mount -t sysfs sysfs /sys" "Failed mounting /sys"

#
# Mount the root partition (the one that the user passed as 'root=' on boot)
#

info "Mounting root partition"

cmdline=\$(cat /proc/cmdline)

for word in \$cmdline; do
  case "\$word" in
    root=*)
      root=\${word#root=}
      break
      ;;
  esac
done

case "\$root" in
    /dev/*)
        cmd "mount \"\$root\" \"/mnt/disk\"" "Failed mounting device '\$root' on /mnt/disk."
        ;;
    UUID=*)
        uuid=\${root#UUID=}
        cmd "mount \"/dev/disk/by-uuid/\$uuid\" \"/mnt/disk\"" "Failed mounting disk UUID '\$uuid' on /mnt/disk."
        ;;
    auto_cd)
        info "Detecting intended boot CD-ROM..."

        found_root=""
        tmp_mount="/mnt/tmpcd"
        mkdir -p "\$tmp_mount"

        for dev in /dev/sr* /dev/cdrom /dev/dvd /dev/scd*; do
            if [ -b "\$dev" ] && blkid -t TYPE="iso9660" "\$dev" >/dev/null 2>&1; then
                # Temporarily mount to check for system image
                if mount -o ro "\$dev" "\$tmp_mount"; then
                    if [ -f "\$tmp_mount/boot/system.squashfs" ]; then
                        found_root="\$dev"
                        umount "\$tmp_mount"
                        break
                    fi
                    umount "\$tmp_mount"
                fi
            fi
        done

        if [ -z "$\found_root" ]; then
            error "Could not find boot CD-ROM containing the required system.squashfs file."
        fi

        root="\$found_root"
        info "Mounting device: \$root"
        cmd "mount \\"\$root\\" \\"/mnt/disk\\"" "Failed mounting device '\$root' on /mnt/disk."
        ;;
    *)
        error "Value of 'root' (\$root) does not start with '/dev/', or is an invalid UUID."
        ;;
esac

#
# To create a memory-based system, we need to mount the
# squashfs image onto a folder & use overlayfs with a
# tmpfs folder to allow reading from the image while
# writing takes place in the tmpfs folder.
#

info "Preparing to transfer control"
cmd "mount -t squashfs -o ro \"/mnt/disk/$sys_dir_squashfs\" /mnt/lower" "Failed mounting SquashFS image on /mnt/lower"
cmd "mount -t tmpfs -o rw tmpfs /mnt/upper" "Failed to mount /mnt/upper as tmpfs"
cmd "mkdir /mnt/upper/upper" "Failed to create /mnt/upper/upper"
cmd "mkdir /mnt/upper/work" "Failed to create /mnt/upper/work"
cmd "mount -t overlay overlay -o lowerdir=/mnt/lower,upperdir=/mnt/upper/upper,workdir=/mnt/upper/work /mnt/overlay" "Failed creating an overlay between SquashFS image and tmpfs folder!"

#
# Now execute the real init from the squashfs image
#

info "Transferring control to /sbin/init"
exec switch_root /mnt/overlay /sbin/init
EOF
