#
# MarkedRain script to auto-detect appropriate CD-ROM device
# 4/4/2024 8:43PM
#

tmp_mount="/temporary"

if [ "$root" = "auto_cd" ]; then
	einfo "Auto-detecting ISO9660 CD-ROM containing squashFS image..."
	found_root=""
	run dodir "$tmp_mount"

	for dev in /dev/sr* /dev/cdrom /dev/dvd /dev/scd*; do
		if [ -b "$dev" ] && blkid -t TYPE="iso9660" "$dev" >/dev/null 2>&1; then
			# Temporarily mount to check for system image
			if mount -o ro "$dev" "$tmp_mount"; then
				if [ -f "$tmp_mount/boot/.MARKEDRAIN_ISO" ]; then
					found_root="$dev"
					run umount "$tmp_mount"
					break
				fi
				run umount "$tmp_mount"
			fi
		fi
	done

	if [ -z "$found_root" ]; then
		eerror "Could not find the boot CD-ROM drive."
	else
		root="$found_root"
		einfo "Found CD-ROM device: $root"
	fi
fi
