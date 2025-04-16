#
# MarkedRain script to mount squashfs image before switching root
# 31/3/2025 9:03pm
#

if [ ! -z "$squashfs_file" ]; then
    run dodir /lower /upper /overlay

    if [ ! -f "/newroot/$squashfs_file" ]; then
        eerror "Specified SquashFS file '$squashfs_file' does not exist on device $root mounted at /newroot"
    fi

    einfo "Moving /newroot to $tmp_mount"
    run mount --move /newroot "$tmp_mount"
    einfo "Mounting $tmp_mount/$squashfs_file on /overlay"
    run mount -t squashfs -o ro "$tmp_mount/$squashfs_file" /lower
    run mount -t tmpfs -o rw tmpfs /upper
    run dodir /upper/upper /upper/work
    run mount -t overlay overlay -o lowerdir=/lower,upperdir=/upper/upper,workdir=/upper/work /overlay
    einfo "Moving $tmp_mount/dev to /overlay/dev"
    run mount --move "$tmp_mount/dev" /overlay/dev
    einfo "Moving /overlay to /newroot"
    run mount --move /overlay /newroot
fi