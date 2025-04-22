define main_compile
	$(S) clone https://github.com/fff7d1bc/better-initramfs.git "$(src_dir_initramfs)/initramfs"
	$(call sub, Patching Makefile to use x64)
	$(Q)patch -N -r - -s "$(src_dir_initramfs)/initramfs/Makefile" < "$(src_dir_initramfs)/Makefile.patch" || true
	$(Q)if [ ! -f "$(src_dir_initramfs)/initramfs/.bootstrapped" ]; then \
	    $(subst @$(S_CMD),$(S_CMD),$(call sub, Bootstrapping)); \
	    $(MAKE) -C "$(src_dir_initramfs)/initramfs" bootstrap-all $(OUT); \
	    echo "This initramfs had been bootstrapped once. Delete this file to bootstrap again when the folder hash changes." > "$(src_dir_initramfs)/initramfs/.bootstrapped"; \
	fi
	$(call sub, Installing hooks)
	$(Q)cp -r "$(src_dir_initramfs)/hooks" "$(src_dir_initramfs)/initramfs/sourceroot/"
	$(call sub, Preparing)
	$(Q)fakeroot $(MAKE) -C "$(src_dir_initramfs)/initramfs" prepare $(OUT)
	$(call sub, Imaging)
	$(Q)$(MAKE) -C "$(src_dir_initramfs)/initramfs" image $(OUT)
endef

define main_install
	$(call sub, Installing Initramfs)
	$(Q)cp "$(src_dir_initramfs)/initramfs/output/initramfs.cpio.gz" "$(bin_dir_tmp)$(sys_dir_initramfs)"
endef
