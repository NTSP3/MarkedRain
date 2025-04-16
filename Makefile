# Makefile re-written for MarkedRain: 14th March 2025 8:00PM
# For code showcasing compiling procedure of the OS,
# view make_os.mk

# ---[ Makefile Setup ] --- #
ifeq ($(wildcard Default.in),)
    $(error Required default settings 'Default.in' not found. Please ensure it exists before continuing)
endif

# Default.in contains default settings for use
# with the Makefile.
include Default.in

#
# The USER_CONFIG file (.config.in) contains settings
# that can be changed via menuconfig.
#
# This function adds USER_CONFIG file if it exists, and
# creates an exception if it or .config doesn't but the
# user asked to open configuration (config, menuconfig, ...)
# If the file doesn't exist and user didn't ask to open
# configuration, then Makefile will exit.
ifeq ($(or $(filter %config,$(MAKECMDGOALS)),$(filter 2,$(words $(wildcard $(USER_CONFIG) .config)))),)
    $(error Please run 'make menuconfig' before running 'make')
else ifneq ($(wildcard $(USER_CONFIG)),)
    include $(USER_CONFIG)
endif

# The scripts.mk file contains definitions that
# the Makefile can use later.
#
# The make_os.mk file contains code used to
# compile the Operating system
#
# Only include these if no configuration utilities
# are asked to run
ifeq ($(and $(MAKECMDGOALS), $(filter %config,$(MAKECMDGOALS)), $(MAKECMDGOALS)), )
    include $(SCRIPTS)/scripts.mk
    include make_os.mk
endif

# Exports color settings to makefile shell
export col_HEADING col_SUBHEADING col_INFOHEADING col_INFO col_TRUE col_FALSE col_DONE col_ERROR col_IMP col_NORMAL

# Display Heading
$(info )
$(info $(shell echo "$(col_INFO)         ++++++++++++++++++++++ MRain Operating System ++++++++++++++++++++++         $(col_NORMAL)"))

# Other early settings
ifeq ($(bool_show_cmd), y)
    $(info $(shell $(S_CMD) info "Makefile shell commands will be shown."))
    Q :=
else
	Q := @
endif
ifneq ($(bool_show_cmd_out), y)
    ifeq ($(bool_show_cmd_out_err), y)
        $(info $(shell $(S_CMD) info "Makefile shell applications output will be hidden."))
        export OUT := > /dev/null
    else
        $(info $(shell $(S_CMD) info "ALL Makefile shell applications output will be hidden."))
        export OUT := > /dev/null 2>&1
    endif
endif
ifeq ($(bool_hide_mkfile_dir_entry), y)
    $(info $(shell $(S_CMD) info "Makefile directory entries will be hidden."))
    MAKEFLAGS += --no-print-directory
endif

export HOME CURDIR Q OUT

# MarkedRain system version
EXTRAVERSION			:= $(shell "$(S_CMD)" get "latest_next" "$(CONF)/bcount.txt")
export MRAIN_VERSION	:= $(VERSION).$(PATCHLEVEL).$(SUBLEVEL).$(EXTRAVERSION)-$(RELEASE_TAG)
$(info )
$(info $(shell $(S_CMD) info "MarkedRain Version $(MRAIN_VERSION)"))
$(info )

# ---[ Menuconfig ] --- #
export srctree := $(CURDIR)
include $(srctree)/make/Kbuild.include
export HOSTCC := $(CC)

# This code runs if user typed anything
# that ends in 'onfig', eg: 'config',
# 'menuconfig'
%onfig:
	$(Q)$(MAKE) $(build)=make/basic
	$(Q)$(MAKE) $(build)=make/kconfig $@ 
	@echo "$(col_INFO)Generating configuration...$(col_NORMAL)"
	$(Q)sed -n 's/^CONFIG_\([^\=]*\)=\("\([^"]*\)"\|\([^"]*\)\)/\1=\3\4/p' .config > $(USER_CONFIG)

# --- ISO Image --- #
.PHONY: iso prepare-iso
iso: all
prepare-iso:
#  -- Create SquashFS image --  #
	$(call heading, Generating compressed SquashFS image)
	$(Q)mksquashfs "$(bin_dir_tmp_squashfs)" "$(bin_dir_tmp)$(sys_dir_squashfs)" -noappend -quiet -comp zstd
#  -- Generate disc image using GRUB --  #
	$(call heading, Creating new disc image with GRUB)
    ifeq ($(ISO), y)
	    $(Q)grub-mkrescue -o "$(bin_dir_iso)" "$(bin_dir_tmp)" $(OUT)
    else
	    $(Q)grub-mkrescue -o "$(bin_dir)/boot.iso" "$(bin_dir_tmp)" $(OUT)
    endif

# --- Disk Image --- #
.PHONY: image prepare-image
image: main prepare-image finalize
	@echo ""
	@width=$$(tput cols); \
	for i in $$(seq 1 $$width); do \
	    printf "$(col_DONE)-"; \
	done; \
	printf "$(col_NORMAL)\n"
	@echo ""
    ifeq ($(ISO), y)
	    $(call ok,    // The Disk Image is now ready. You can find it in '$(bin_dir_iso)' //    )
	    @echo "$(col_FALSE)    // 'make run' & 'make runs' do not have support for ISO image in '$(bin_dir_iso)' by default //    $(col_NORMAL)"
    else
	    $(call ok,    // The temporary Disk Image image is now ready. You can find it as '$(bin_dir)/boot.iso' //    )
	    $(call ok,    // Use 'make ir' or 'make imagerun' if you want to run this ISO image now  //    )
	    $(call ok,    // Use 'make irs' or 'make imageruns' if you want to automatically open the Disk Image in $(util_vm) //    )
	    @echo ""
	    $(call ok,    // Run 'make' with parameter 'ISO=y' if you want to create a persistant ISO image in '$(bin_dir_iso)' //    )
		@echo "$(col_FALSE)    // 'make run' & 'make runs' do not have support for ISO image in '$(bin_dir_iso)' by default //    $(col_NORMAL)"
    endif
	@echo ""

prepare-image:
#  -- Move root files into image dir --  #
	$(call inf, Moving contents of $(bin_dir_tmp) into $(bin_dir_tmp_squashfs))
	$(Q)rsync -a --ignore-existing "$(bin_dir_tmp)/" "$(bin_dir_tmp_squashfs)/"
#  -- Make writable image --  #
	$(call heading, Creating the writable & portable image)
	$(call sub, Creating an empty file ($(val_portable_size)MB))
	$(Q)truncate -s $$(expr $$(du -sB1 "$(bin_dir_tmp_squashfs)" | awk '{print int($$1 / 1024 / 1024)}') + 1 + $(val_portable_size_extension))M "$(bin_dir)/boot.iso" $(OUT)
	$(call imp, Please provide password to perform operations on this image)
	$(Q)sudo losetup -fP --show "$(bin_dir)/boot.iso" > "$(bin_dir)/.tmp"
	$(call sub, Creating partition table)
	$(Q)echo ',,83,*' | sudo sfdisk "$$(cat $(bin_dir)/.tmp)"
	$(Q)sudo partprobe "$$(cat $(bin_dir)/.tmp)"
	$(call sub, Formatting using the ext4 filesystem)
	$(Q)sudo mkfs.ext4 "$$(cat $(bin_dir)/.tmp)p1" | grep -oP 'UUID: \K[\w-]+' > "$(bin_dir)/.uuid"
	$(call sub, Mounting partition)
	$(Q)sudo mount "$$(cat $(bin_dir)/.tmp)p1" "$(bin_dir_tmp)"
	$(call sub, Installing GRUB Bootloader)
	$(Q)sudo grub-install --target=i386-pc --boot-directory="$(bin_dir_tmp)/boot" "$$(cat $(bin_dir)/.tmp)"
	$(call sub2, Updating root= value)
	$(Q)sed -i "s/root=auto_cd/root=UUID=$$(cat '$(bin_dir)/.uuid')/g" "$(bin_dir_tmp_squashfs)/boot/grub/grub.cfg"
	$(call sub2, Removing squashfs_file= value)
	$(Q)sed -Ei 's/squashfs_file=[^[:space:]"]+(")/\1/g; s/squashfs_file=[^[:space:]"]+ ?//g' "$(bin_dir_tmp_squashfs)/boot/grub/grub.cfg"
	$(call sub, Copying system into the image)
	$(Q)sudo cp -r "$(bin_dir_tmp_squashfs)/"* "$(bin_dir_tmp)"
	$(call sub, Unmounting image)
	$(Q)sudo umount "$(bin_dir_tmp)"
	$(call sub, Deleting loopback device and temporary files)
	$(Q)sudo losetup -d "$$(cat $(bin_dir)/.tmp)"
	$(Q)rm "$(bin_dir)/.tmp" "$(bin_dir)/.uuid"
    ifeq ($(ISO), y)
		$(call heading, Creating persistant image)
	    $(Q)cp "$(bin_dir)/boot.iso" "$(bin_dir_iso)"
    endif

# --- Image Finalization --- #
.PHONY: finalize
finalize:
#  -- Version updation --  #
	$(Q)if [ "$(bool_ver_change)" = "y" ]; then \
	    $(subst @$(S_CMD), $(S_CMD), $(call inf, Saving version: $(MRAIN_VERSION))); \
	    "$(SCRIPTS)/set_var.sh" "ver_previous_mrain-sys" "$(MRAIN_VERSION)" "$(CONF)/variables.txt"; \
	fi
	$(Q)if [ "$(bool_do_update_count)" = "y" ] || [ "$(update)" = "true" ]; then \
	    echo "$(col_TRUE)Summary of items changed"; \
	    echo "$(col_TRUE)--------------------------$(col_NORMAL)"; \
	    echo -n " $(val_changes)"; \
	    if [ "$(update)" = "true" ]; then \
	        echo "$(col_INFO)Variable 'update' is set to true."; \
	    fi; \
	    "$(SCRIPTS)/count_increment.sh" "latest_next" "$(CONF)/bcount.txt"; \
	fi
#  -- Automatic cleaning --  #
    ifeq ($(bool_clean_dir_tmp), y)
	    $(call inf, $(col_FALSE)Cleaning temporary files)
	    $(Q)rm -rf "$(bin_dir_tmp)"/* "$(bin_dir_tmp_squashfs)"
    endif

.PHONY: all
all: main prepare-iso finalize
	@echo ""
	@width=$$(tput cols); \
	for i in $$(seq 1 $$width); do \
	    printf "$(col_DONE)-"; \
	done; \
	printf "$(col_NORMAL)\n"
	@echo ""
    ifeq ($(ISO), y)
	    $(call ok,    // The ISO is now ready. You can find it in '$(bin_dir_iso)' //    )
    else
	    $(call ok,    // The temporary ISO image is now ready. You can find it as '$(bin_dir)/boot.iso' //    )
	    $(call ok,    // Use 'make run' if you want to run this ISO image now  //    )
	    $(call ok,    // Use 'make runs' if you want to automatically open the ISO in $(util_vm) //    )
	    @echo ""
	    $(call ok,    // Run 'make' with parameter 'ISO=y' if you want to create a persistant ISO image in '$(bin_dir_iso)' //    )
    endif
	@echo "$(col_FALSE)    // 'make run' & 'make runs' do not have support for ISO image in '$(bin_dir_iso)' by default //    $(col_NORMAL)"
	@echo ""

# --- Run --- #
.PHONY: run runs imagerun imageruns ir irs
#  -- ISO9660 --  #
run:
    ifeq ($(bool_use_qemu_kvm), y)
	    $(eval util_vm_params += -enable-kvm -cpu host)
    endif
	$(eval util_vm_params += -cdrom $(bin_dir)/boot.iso)
	$(Q)if [ -f "$(bin_dir)/boot.iso" ]; then \
	    echo ""; \
	    $(subst @echo, echo, $(call ok,    // Now running CD image \"$(bin_dir)/boot.iso\" using \"$(util_vm)\" and parameters \"$(util_vm_params)\" //    )); \
	    "$(util_vm)" $(shell echo -n $(util_vm_params)); \
	else \
	    $(subst @$(S_CMD), $(S_CMD), $(call stop, Supplied file \"$(bin_dir)/boot.iso\" doesn't exist. Make sure you ran \"make\" and try again.)); \
	fi
	@echo ""

runs: main prepare-iso finalize run

#  -- ext4 img --  #
imagerun:
    ifeq ($(bool_use_qemu_kvm), y)
	    $(eval util_vm_params += -enable-kvm -cpu host)
    endif
	$(eval util_vm_params += -hda $(bin_dir)/boot.iso)
	$(Q)if [ -f "$(bin_dir)/boot.iso" ]; then \
	    echo ""; \
	    $(subst @echo, echo, $(call ok,    // Now running hdd image \"$(bin_dir)/boot.iso\" using \"$(util_vm)\" and parameters \"$(util_vm_params)\" //    )); \
	    "$(util_vm)" $(shell echo -n $(util_vm_params)); \
	else \
	    $(subst @$(S_CMD), $(S_CMD), $(call stop, Supplied file \"$(bin_dir)/boot.iso\" doesn't exist. Make sure you ran \"make\" and try again.)); \
	fi
	@echo ""

ir: imagerun
imageruns: main prepare-image finalize imagerun
irs: imageruns

# --- Clean --- #
.PHONY: clean
clean:
	@$(call cleancode)

# --- Clean all stuff --- #
.PHONY: cleanall
cleanall:
	@echo ""
	$(call imp, This function will reset the source code to minimum and will take longer to compile.)
	@echo ""
	@echo "$(col_INFO)  Press "Y" and enter to continue, any other key will terminate.$(col_NORMAL)"
	$(Q)read choice; \
	if [ "$$choice" = "Y" ] || [ "$$choice" = "y" ]; then \
	    $(call cleancode); \
	    $(subst @$(S_CMD), $(S_CMD), $(call inf, $(col_FALSE)Removing downloaded application source code)); \
	    find "$(src_dir_applications)" -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} +; \
	    $(subst @$(S_CMD), $(S_CMD), $(call inf, $(col_FALSE)Cleaning buildroot)); \
	    echo ""; \
	    $(subst @echo, echo, $(call ok,  Done. Run 'make' to re-compile. Be prepared to wait a long time.  )); \
	    echo ""; \
	else \
	    $(subst @echo, echo, $(call ok,  Cancelled.  )); \
	    echo ""; \
	fi

# --- Help --- #
.PHONY: help
help:
	$(Q)cat $(HELPFILE)
