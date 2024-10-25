#!/bin/sh
# Text file creation: 'source/initramfs/source/init'

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
    echo "\e[1;91mError: \$1\e[0m"
    exit 1
}

info() {
    echo "\e[1;32m\$1\e[0m"
}

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
        cmd "mount \"\$root\" \"/mnt/sda\"" "Failed mounting device '\$root' on /mnt/sda."
        ;;
    UUID=*)
        uuid=\${root#UUID=}
        cmd "mount \"/dev/disk/by-uuid/\$uuid\" \"/mnt/sda\"" "Failed mounting disk UUID '\$uuid' on /mnt/sda."
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
cmd "mount -t squashfs -o ro \"$sys_dir_squashfs\" /mnt/lower" "Failed mounting SquashFS image on /mnt/lower"
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
