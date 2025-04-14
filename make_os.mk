# This file contains code that will compile
# the Operating system

# ---[ Create image contents ] --- #
.PHONY: main
main:
#  -- Update no. of times Make has been run --  #
	$(Q)"$(SCRIPTS)/base_count_increment.sh" "latest_next" "$(CONF)/mcount.txt"
#  -- Clean --  #
	$(call cleancode)
#  -- Initialize --  #
	$(call initialize)
#  -- Buildroot --  #
	$(call heading, Adding buildroot into the image)
    ifeq ($(shell [ -f ".recombr" ] && echo y), y)
	    $(Q)rm .recombr
    endif
	$(call buildroot_packages_to_be_remade)
    ifneq ($(shell [ -f "$(src_dir_buildroot)/output/images/rootfs.tar" ] && echo y), y)
	    $(call sub, rootfs.tar does not exist; making Buildroot)
	    $(Q)fakeroot $(MAKE) -C "$(src_dir_buildroot)" $(OUT) || exit 1
	    $(call save_hash, hash_buildroot, $(src_dir_buildroot)/.config)
	    $(eval bool_do_update_count := y)
	    $(eval val_changes += rootfs.tar did not exist\n)
    else
	    $(call sub, Comparing .config hash)
        ifneq ($(shell "$(SCRIPTS)/get_var.sh" "hash_buildroot" "$(CONF)/hashes.txt"),$(shell $(call get_hash, $(src_dir_buildroot)/.config)))
	        $(call sub, Hashes didn't match; making Buildroot)
	        $(Q)fakeroot $(MAKE) -C "$(src_dir_buildroot)" $(OUT) || exit 1
	        $(call save_hash, hash_buildroot, $(src_dir_buildroot)/.config)
	        $(eval bool_do_update_count := y)
	        $(eval val_changes += Buildroot's configuration (.config) changed\n)
        else
            # Invoke BR make if version changed & all other checks are clear
            ifeq ($(shell [ -f ".recombr" ] && echo y), y)
	            $(call sub, Making Buildroot (version changed))
	            $(Q)fakeroot $(MAKE) -C "$(src_dir_buildroot)" $(OUT) || exit 1
            endif
        endif
    endif
    ifeq ($(shell [ -f ".recombr" ] && echo y), y)
	    $(Q)rm .recombr
    endif
	$(call sub, Extracting rootfs archive to '$(bin_dir_tmp_squashfs)')
	$(Q)pv -i 0.01 "$(src_dir_buildroot)/output/images/rootfs.tar" | tar -xf "-" -C "$(bin_dir_tmp_squashfs)"
#  -- Applications --  #
	$(call applications)
#  -- Kernel --  #
	$(call heading, Adding the linux kernel)
    ifneq ($(shell [ -f "$(src_dir_linux)" ] && echo y), y)
	    $(call stop, Kernel file doesn't exist in $(src_dir_linux). Ensure you gave the correct path to it by running menuconfig.)
    else
	    $(call sub, Comparing kernel hash)
        ifneq ($(shell "$(SCRIPTS)/get_var.sh" "hash_kernel" "$(CONF)/hashes.txt"), $(shell $(call get_hash, $(src_dir_linux))))
	        $(call save_hash, hash_kernel, $(src_dir_linux))
	        $(eval bool_do_update_count := y)
	        $(eval val_changes += Kernel file changed\n)
        endif
    endif
	$(call sub, Copying kernel as '$(bin_dir_tmp)$(sys_dir_linux)')
	$(Q)cp "$(src_dir_linux)" "$(bin_dir_tmp)$(sys_dir_linux)" $(OUT)
	$(call sub, Copying kernel as '$(bin_dir_tmp_squashfs)$(sys_dir_linux)')
	$(Q)cp "$(src_dir_linux)" "$(bin_dir_tmp_squashfs)$(sys_dir_linux)" $(OUT)
#  -- Modules --  #
	$(call heading, Adding modules)
	$(Q)cp -r "$(src_dir_modules)" "$(bin_dir_tmp_squashfs)/usr/lib"
#  -- Text files --  #
	$(call heading, Generating/Appending to text files in the SquashFS/System image)
    ifneq ($(shell "$(SCRIPTS)/get_var.sh" "hash_mktext_root" "$(CONF)/hashes.txt"), $(shell $(call get_hash_dir, $(src_dir_mktext)/root)))
	    $(call save_hash_dir, hash_mktext_root, $(src_dir_mktext)/root)
	    $(eval bool_do_update_count := y)
	    $(eval val_changes += Text files created in [SquashFS/System archive] changed\n)
    endif
	$(Q)"$(SCRIPTS)/make_text_files.sh" "$(src_dir_mktext)/root" "$(bin_dir_tmp_squashfs)"
	$(call heading, Generating/Appending to text files in the final image)
    ifneq ($(shell "$(SCRIPTS)/get_var.sh" "hash_mktext_image" "$(CONF)/hashes.txt"), $(shell $(call get_hash_dir, $(src_dir_mktext)/image)))
	    $(call save_hash_dir, hash_mktext_image, $(src_dir_mktext)/image)
	    $(eval bool_do_update_count := y)
	    $(eval val_changes += Text files created in [Root of image] changed\n)
    endif
	$(Q)export boot_resolution="$(val_grub-boot_resolution)"; \
	export boot_default="$(val_grub-boot_default)"; \
	export boot_timeout="$(val_grub-boot_timeout)"; \
	export entry_name="$(val_grub-entry-one_name)"; \
	export sys_dir_linux="$(sys_dir_linux)"; \
	export linux_params="$(val_grub-entry-one_li_params)"; \
	export sys_dir_initramfs="$(sys_dir_initramfs)"; \
	"$(SCRIPTS)/make_text_files.sh" "$(src_dir_mktext)/image" "$(bin_dir_tmp)"
#  -- Clone initramfs --  #
	$(call heading, Adding initramfs)
# Add initramfs.mk here to give its main_compile and main_install priority
	$(eval include $(src_dir_initramfs)/initramfs.mk)
	$(call application_installer,src_dir_initramfs,$(src_dir_initramfs)/initramfs)
#  -- Finalization --  #
	$(call heading, Doing finalization procedures)
#   - Branding -   #
	$(call sub, Adding branding image)
	$(Q)cp "$(src_dir_media)/branding/flat.png" "$(bin_dir_tmp_squashfs)/usr/share/branding/mrain-flat.png"
#   - Convenient aliases & Functions -   #
    ifeq ($(bool_include_aliases), y)
	    $(call sub, Convenient aliases & functions)
	    $(Q)"$(src_dir_mktext)/aliases.sh" >> "$(bin_dir_tmp_squashfs)/etc/profile"
    endif
#   - Drive letters -   #
    ifeq ($(bool_use_drive_letters), y)
	    $(call sub, Drive letters)
	    $(Q)export val_disks_path="$(val_disks_path)"; \
	    "$(src_dir_mktext)/drive_letters.sh" >> "$(bin_dir_tmp_squashfs)/etc/zprofile"
    endif
#   - OpenRC Getty tty2,3,4,5,6 symlinks -   #
    ifeq ($(bool_tty_expansion), y)
	    $(call sub, OpenRC getty on tty2 - tty6 symlinks)
	    $(Q)cd "$(bin_dir_tmp_squashfs)"; \
	    ln -s "/etc/init.d/agetty" "etc/init.d/agetty.tty2"; \
	    ln -s "/etc/init.d/agetty" "etc/init.d/agetty.tty3"; \
	    ln -s "/etc/init.d/agetty" "etc/init.d/agetty.tty4"; \
	    ln -s "/etc/init.d/agetty" "etc/init.d/agetty.tty5"; \
	    ln -s "/etc/init.d/agetty" "etc/init.d/agetty.tty6"; \
	    ln -s "/etc/init.d/agetty.tty2" "etc/runlevels/default/agetty.tty2"; \
	    ln -s "/etc/init.d/agetty.tty3" "etc/runlevels/default/agetty.tty3"; \
	    ln -s "/etc/init.d/agetty.tty4" "etc/runlevels/default/agetty.tty4"; \
	    ln -s "/etc/init.d/agetty.tty5" "etc/runlevels/default/agetty.tty5"; \
	    ln -s "/etc/init.d/agetty.tty6" "etc/runlevels/default/agetty.tty6"
    endif
#   - Watchdog daemon startup script fix -   #
	$(call sub, Watchdog daemon script (if exist) timer delay)
	$(Q)file="bin/squashfs/etc/init.d/S15watchdog"; \
	if [ -f "$$file" ]; then \
	    delay_time=$$(awk '/^[[:space:]]*watchdog/ && /-t [0-9]+/ { for (i=1; i<=NF; i++) if ($$i == "-t") print $$(i+1) }' "$$file"); \
	    if [ -n "$$delay_time" ]; then \
	        sed -i 's/ -t [0-9]*//g' "$$file"; \
	    fi; \
	fi
#   - MarkedRain ISO Verification file -   #
	$(Q)echo "MarkedRain $(MRAIN_VERSION)" > "$(bin_dir_tmp)/boot/.MARKEDRAIN_ISO"
