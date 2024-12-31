#==--[ Makefile for MRainOS - Linux based ]--==#
# ---[ Makefile variable configuration ]--- #
#  --[ Default version info ]-- #
VERSION					:= 0
PATCHLEVEL				:= 0
SUBLEVEL				:= 0
# Extraversion is declared after "-include .config.mk" so it can get values of src_dir_(conf & scripts)
RELEASE_TAG				:= unknown
#  --[ Default escape sequence for colour values ]--  #
col_HEADING				:= \e[1;37;45m
col_SUBHEADING			:= \e[1;35;40m
col_INFOHEADING			:= \e[37;44m
col_INFO				:= \e[36m
col_TRUE				:= \e[32m
col_FALSE				:= \e[91m
col_DONE				:= \e[92m
col_ERROR				:= \e[1;91m
col_IMP					:= \e[1;37;41m
col_NORMAL				:= \e[0m
export col_HEADING col_SUBHEADING col_INFOHEADING col_INFO col_TRUE col_FALSE col_DONE col_ERROR col_IMP col_NORMAL
#  --[ Others ]--  #
val_target				:= $(MAKECMDGOALS)#    # Gets the target that the user invoked
val_current_dir			:= $(shell pwd)#       # Gets the current working director
val_temp				:=#                    # Temporary variable
#  --[ User's configuration (overrides vars with same name) ]--  #
-include .config.mk#                           # Include .config.mk
# Extraversion is here - read the comment in its previous location #
EXTRAVERSION	:= $(shell "$(src_dir_scripts)/get_var.sh" "latest_next" "$(src_dir_conf)/bcount.txt")

# ---[ Macros ]--- #
#  --[ Definitions that do something ]--  #
define get_hash
	shasum "$(strip $(1))" | cut -d ' ' -f 1
endef

define save_hash
	@$(call heading, info, Saving hash of file '$(strip $(2))' as '$(strip $(1))=')
	$(Q)"$(src_dir_scripts)/set_var.sh" "$(strip $(1))" `$(call get_hash, $(2))` "$(src_dir_conf)/hashes.txt"
endef

define get_hash_dir
	find "$(strip $(1))" -type f -exec stat --format="%s %Y %n" {} + | sort | shasum | cut -d ' ' -f 1
endef

define save_hash_dir
	@$(call heading, info, Saving hash of directory '$(strip $(2))' as '$(strip $(1))=')
	$(Q)"$(src_dir_scripts)/set_var.sh" "$(strip $(1))" `$(call get_hash_dir, $(2))` "$(src_dir_conf)/hashes.txt"
endef

#  --[ Exceptional message printers ]--  #
define stop
	@echo "\n$(col_IMP)STOP:$(col_NORMAL)$(col_ERROR) $(strip $(1))$(col_NORMAL)\n" >&2; \
	false
endef

define warn
	@echo "$(col_ERROR)  Warning:$(col_NORMAL)$(col_FALSE) $(strip $(1))$(col_NORMAL)" >&2
endef

define ok
	@echo "$(col_DONE)$(1)$(col_NORMAL)"
endef

#  --[ Common message printers ]--  #
define stat
	@echo -n; \
	val_temp='$(strip $(1))'; \
	val_temp2=$${#val_temp}; \
	if [ $$val_temp2 -gt 60 ] || [ $$((val_temp2 % 2)) -ne 0 ]; then \
	    $(subst @echo, echo, $(call warn, Total length of characters ($$val_temp2) supplied to definition \"$(0)\" is greater than 60 or is not even.)); \
	else \
	    val_temp2=$$(((60 - (val_temp2)) / 2)); \
	    val_temp2=$$(printf '%*s' "$$val_temp2"); \
	    echo "$(col_INFO)         !** $$val_temp2$$val_temp$$val_temp2 **!         $(col_NORMAL)"; \
	fi
endef

define true
	@echo -n; \
	val_temp='$(strip $(1))'; \
	val_temp2=$${#val_temp}; \
	val_temp3='$(strip $(2))'; \
	val_temp4=$${#val_temp3}; \
	val_temp2=$$((val_temp2 + val_temp4)); \
	if [ $$val_temp2 -gt 42 ] || [ $$((val_temp2 % 2)) -ne 0 ]; then \
	    $(subst @echo, echo, $(call warn, Total length of characters ($$val_temp2) supplied to definition \"$(0)\" is greater than 42 or is not even.)); \
	else \
	    val_temp2=$$(((60 - (val_temp2 + 4 + 14)) / 2)); \
	    val_temp2=$$(printf '%*s' "$$val_temp2"); \
	    echo "$(col_TRUE)         !** $$val_temp2$$val_temp ($$val_temp3) is set to true$$val_temp2 **!         $(col_NORMAL)"; \
	fi
endef

define false
	@echo -n; \
	val_temp='$(strip $(1))'; \
	val_temp2=$${#val_temp}; \
	val_temp3='$(strip $(2))'; \
	val_temp4=$${#val_temp3}; \
	val_temp2=$$((val_temp2 + val_temp4)); \
	if [ $$val_temp2 -gt 48 ] || [ $$((val_temp2 % 2)) -ne 0 ]; then \
	    $(subst @echo, echo, $(call warn, Total length of characters ($$val_temp2) supplied to definition \"$(0)\" is greater than 48 or is not even.)); \
	else \
	    val_temp2=$$(((60 - (val_temp2 + 4 + 8)) / 2)); \
	    val_temp2=$$(printf '%*s' "$$val_temp2"); \
	    echo "$(col_FALSE)         !** $$val_temp2$$val_temp ($$val_temp3) is false$$val_temp2 **!         $(col_NORMAL)"; \
	fi
endef

ifeq ($(bool_use_old_headings), y)
    define heading
	    @echo -n; \
	    if [ "$(strip $(1))" = "imp" ]; then \
	        echo "\e[1;37;41m    !! $(strip $(2)) !!    \e[0m"; \
	    elif [ "$(strip $(1))" = "main" ]; then \
	        echo "\e[95m    // $(strip $(2)) //\e[0m"; \
	    elif [ "$(strip $(1))" = "sub" ]; then \
	        echo "\e[38;5;206m     / $(strip $(2)) /\e[0m"; \
	    elif [ "$(strip $(1))" = "sub2" ]; then \
	        echo "$(col_SUBHEADING)  -+ $(strip $(2)) +-  $(col_NORMAL)"; \
	    elif [ "$(strip $(1))" = "info" ]; then \
	        echo "\e[36m    // $(strip $(2))\e[36m //\e[0m"; \
	    else \
	        $(subst @echo, echo, $(call warn, Definition \"$(0)\" doesn't know what '$(strip $(1))' means.)); \
	    fi
    endef
else
    define heading
	    @echo -n; \
	    if [ "$(strip $(1))" = "imp" ]; then \
	        echo "$(col_IMP) !! $(strip $(2)) !! $(col_NORMAL)"; \
	    elif [ "$(strip $(1))" = "main" ]; then \
	        echo "$(col_HEADING)---[ $(strip $(2)) ]---$(col_NORMAL)"; \
	    elif [ "$(strip $(1))" = "sub" ]; then \
	        echo "$(col_SUBHEADING) --+ $(strip $(2)) +-- $(col_NORMAL)"; \
	    elif [ "$(strip $(1))" = "sub2" ]; then \
	        echo "$(col_SUBHEADING)  -+ $(strip $(2)) +-  $(col_NORMAL)"; \
	    elif [ "$(strip $(1))" = "info" ]; then \
	        echo "$(col_INFOHEADING) ++ $(strip $(2))$(col_NORMAL)$(col_INFOHEADING) ++ $(col_NORMAL)"; \
	    else \
	        $(subst @echo, echo, $(call warn, Definition \"$(0)\" doesn't know what '$(strip $(1))' means.)); \
	    fi
    endef
endif

# ---[ Global ]--- #
$(info $(shell echo "$(col_INFO)         ++++++++++++++++++++++ MRain Operating System ++++++++++++++++++++++         $(col_NORMAL)"))
ifeq ($(bool_show_cmd), y)
    $(info $(shell $(subst @echo, echo, $(call true, ShowCommand, bool_show_cmd))))
    export Q :=
else
    $(info $(shell $(subst @echo, echo, $(call false, ShowCommand, bool_show_cmd))))
    export Q ?= @
endif
ifeq ($(bool_show_cmd_out), y)
    $(info $(shell $(subst @echo, echo, $(call true, ShowAppOutput, bool_show_cmd_out))))
else
    $(info $(shell $(subst @echo, echo, $(call false, ShowAppOutput, bool_show_cmd_out))))
    ifeq ($(bool_show_cmd_out_err), y)
        $(info $(shell $(subst @echo, echo, $(call true, ShowAppErrors, bool_show_cmd_out_err))))
        export OUT := > /dev/null
    else
        $(info $(shell $(subst @echo, echo, $(call false, ShowAppErrors, bool_show_cmd_out_err))))
        export OUT := > /dev/null 2>&1
    endif
    ifeq ($(findstring --no-print-directory,$(MAKEFLAGS)), )
        MAKEFLAGS += --no-print-directory
    endif
endif
ifeq ($(filter $(val_target),$(val_unmain_sect)),)
    $(info $(shell $(subst @echo, echo, $(call stat, Checking variable 'EXTRAVERSION'))))
    ifeq ($(shell echo "$(EXTRAVERSION)" | grep -Eq '^[0-9]+$$' && echo 1 || echo 0), 0)
        $(info )
        $(info $(shell $(subst @echo, echo, $(call warn, Variable 'EXTRAVERSION' is not a numeric value.))))
        $(info + Contents of the variable at this time:)
        $(info + $(EXTRAVERSION))
        $(info )
        $(info $(shell $(subst @echo, echo, $(call warn, Using value '0' instead - make sure bconfig.txt is correct.))))
        $(eval EXTRAVERSION = 0)
    endif
    ifneq ($(and $(val_target), $(filter %config,$(val_target)), $(val_target)), )
        # menuconfig
        $(info $(shell $(subst @echo, echo, $(call stat, Preparing config manager))))
        export srctree := $(if $(KBUILD_SRC),$(KBUILD_SRC),$(CURDIR))
        export HOSTCC := gcc
        include $(srctree)/make/Kbuild.include
    else
        # non-menuconfig
        $(info $(shell $(subst @echo, echo, $(call heading, info, Sanitizing PATH))))
        export PATH := $(shell echo $$PATH | tr -d '[:space:]')# Remove paths with spaces in variable PATH
        -include $(src_dir_apps)/applications.mk
    endif
    # Put stuff meant for menuconfig and non-menuconfig here
    $(info $(shell $(subst @echo, echo, $(call heading, info, Exporting MRain System version))))
    export MRAIN_VERSION := $(VERSION).$(PATCHLEVEL).$(SUBLEVEL).$(EXTRAVERSION)-$(RELEASE_TAG)
endif
# Go to 'all' if nothing is specified #
.DEFAULT_GOAL := all

# ---[ Menuconfig interface setup ]--- #
.PHONY: config
config:
	$(Q)$(MAKE) $(build)=make/basic
	$(Q)$(MAKE) $(build)=make/kconfig $@

%config:
	$(Q)$(MAKE) $(build)=make/basic
	$(Q)$(MAKE) $(build)=make/kconfig $@

# --- Default --- #
.PHONY: all
all: main
	@echo ""
	@width=$$(tput cols); \
	for i in $$(seq 1 $$width); do \
	    printf "$(col_DONE)-"; \
	done; \
	printf "$(col_NORMAL)\n"
	@echo ""
    ifeq ($(ISO), y)
	    $(call ok,    // The ISO is now ready. You can find it in '$(bin_dir_iso)' //    )
	    @echo "$(col_FALSE)    // 'make run' & 'make runs' do not have support for ISO image in '$(bin_dir_iso)' by default //    $(col_NORMAL)"
    else
	    $(call ok,    // The temporary image is now ready. You can find it as '$(bin_dir)/boot.iso' //    )
	    $(call ok,    // Use 'make run' if you want to run this ISO image now  //    )
	    $(call ok,    // Use 'make runs' if you want to automatically open the ISO in $(util_vm) //    )
	    @echo ""
	    $(call ok,    // Run 'make' with parameter 'ISO=y' if you want to create a persistant ISO image in '$(bin_dir_iso)' //    )
		@echo "$(col_FALSE)    // 'make run' & 'make runs' do not have support for ISO image in '$(bin_dir_iso)' by default //    $(col_NORMAL)"
    endif
	@echo ""

# --- Main compiling procedure --- #
.PHONY: main
main:
    ifneq ($(shell [ -f ".config" ] && echo y), y)
	    $(call warn, .config file is not found. Settings in menuconfig may not reflect the current settings.)
    endif
    ifeq ($(shell [ -f ".config.mk" ] && echo y), y)
	    @echo "$(col_TRUE)         !**                   Configuration file found                   **!         $(col_NORMAL)"
    else
	    @echo "$(col_FALSE)         !**                Configuration file isn't found                **!         $(col_NORMAL)"
	    $(call stop, .config.mk is not found. Run 'make menuconfig', save it & try again)
    endif
#  -- Compare MRain version --  #
	$(call stat, Comparing MarkedRain version)
    ifneq ($(shell "$(src_dir_scripts)/get_var.sh" "ver_previous_mrain-sys" "$(src_dir_conf)/variables.txt"), $(MRAIN_VERSION))
	    $(call heading, info, Version change detected)
	    $(eval bool_ver_change := y)
    endif
#  -- Clean --  #
	$(Q)$(call cleancode)
#  -- Directories --  #
	$(call heading, info, $(col_OK)Setting up temporary directories)
	$(Q)mkdir -p "/dev/shm/mrain-bin"
	$(Q)ln -s /dev/shm/mrain-bin "$(bin_dir)"
	$(Q)mkdir -p "$(bin_dir_tmp)" "$(bin_dir_tmp_squashfs)"
	$(call heading, main, Creating system directories)
	$(Q)mkdir -p "$(bin_dir_tmp)/boot" "$(bin_dir_tmp)/boot/grub" "$(bin_dir_tmp)/boot/syslinux"
	$(Q)"$(src_dir_scripts)/mk_sys_dir.sh" "$(src_dir_conf)/dir.txt" "$(bin_dir_tmp_squashfs)"
#  -- Buildroot --  #
	@echo ""
	$(call heading, main, Adding buildroot into the image)
    # Delete .recombr if it exists
    ifeq ($(shell [ -f ".recombr" ] && echo y), y)
	    $(Q)rm .recombr
    endif
    # Can't put BR make here and do the ifneq conditions because bash 'if' conditions
    # doesn't seem to work with makefile, and can't make those ifeq and ifneq conditions into bash
    # because it cannot do $(eval). Can't make these bash commands into Makefile because
    # the 'ifeq' conditions doesn't seem to recognise changes to variables
	$(Q)if [ "$(bool_ver_change)" = "y" ] && [ "$(strip $(val_remake_br_pack))" != "" ]; then \
	    val_temp="$(val_remake_br_pack)"; \
	    for val_temp2 in $$val_temp; do \
	        if [ "$$repeat" = "y" ]; then \
	            $(subst @echo, echo, $(call heading, sub, Re-making package: $$val_temp2)); \
	            fakeroot $(MAKE) -C "$(src_dir_buildroot)" "$${val_temp2}-reconfigure"; \
	            continue; \
	        fi; \
	        echo -n "$(col_FALSE)[Version changed] $(col_INFO)Do you want to re-compile package '$$val_temp2'? $(col_NORMAL)[$(col_DONE)[Y]es$(col_NORMAL)/$(col_FALSE)[N]o$(col_NORMAL)/$(col_INFO)[A]ll$(col_NORMAL)]"; \
	        while true; do \
	            read choice; \
	            if [ "$$choice" = "N" ] || [ "$$choice" = "n" ]; then \
	                break; \
	            elif [ "$$choice" = "Y" ] || [ "$$choice" = "y" ] || [ "$$choice" = "A" ] || [ "$$choice" = "a" ]  ; then \
	                $(subst @echo, echo, $(call heading, sub, Re-making package: $$val_temp2)); \
	                fakeroot $(MAKE) -C "$(src_dir_buildroot)" "$${val_temp2}-reconfigure"; \
	                echo > .recombr; \
	                if [ "$$choice" = "A" ] || [ "$$choice" = "a" ] ; then \
	                    repeat=y; \
	                fi; \
	                break; \
	            fi; \
	            echo -n "$(col_FALSE)Invalid option. Available options: $(col_NORMAL)[$(col_DONE)[Y]es$(col_NORMAL)/$(col_FALSE)[N]o$(col_NORMAL)/$(col_INFO)[A]ll$(col_NORMAL)]"; \
	        done; \
	    done; \
	fi
    ifneq ($(shell [ -f "$(src_dir_buildroot)/output/images/rootfs.tar" ] && echo y), y)
	    $(call heading, sub, rootfs.tar does not exist; making Buildroot)
	    $(Q)fakeroot $(MAKE) -C "$(src_dir_buildroot)" $(OUT) || exit 1
	    $(call save_hash, hash_buildroot, $(src_dir_buildroot)/.config)
	    $(eval bool_do_update_count := y)
	    $(eval val_changes += rootfs.tar did not exist\n)
    else
	    $(call heading, sub, Comparing .config hash)
        ifneq ($(shell "$(src_dir_scripts)/get_var.sh" "hash_buildroot" "$(src_dir_conf)/hashes.txt"),$(shell $(call get_hash, $(src_dir_buildroot)/.config)))
	        $(call heading, sub, Hashes didn't match; making Buildroot)
	        $(Q)fakeroot $(MAKE) -C "$(src_dir_buildroot)" $(OUT) || exit 1
	        $(call save_hash, hash_buildroot, $(src_dir_buildroot)/.config)
	        $(eval bool_do_update_count := y)
	        $(eval val_changes += Buildroot's configuration (.config) changed\n)
        else
            # Invoke BR make if version changed & all other checks are clear
            ifeq ($(shell [ -f ".recombr" ] && echo y), y)
	            $(call heading, sub, Making Buildroot (version changed))
	            $(Q)fakeroot $(MAKE) -C "$(src_dir_buildroot)" $(OUT) || exit 1
            endif
        endif
    endif
    ifeq ($(shell [ -f ".recombr" ] && echo y), y)
	    $(Q)rm .recombr
    endif
	$(call heading, sub, Extracting rootfs archive to '$(bin_dir_tmp_squashfs)')
	$(Q)pv -i 0.01 "$(src_dir_buildroot)/output/images/rootfs.tar" | tar -xf "-" -C "$(bin_dir_tmp_squashfs)"
#  -- Kernel --  #
	@echo ""
	$(call heading, main, Adding the linux kernel)
    ifneq ($(shell [ -f "$(src_dir_linux)" ] && echo y), y)
	    $(call stop, Kernel file doesn't exist in $(src_dir_linux). Ensure you gave the correct path to it by running menuconfig.)
    else
	    $(call heading, sub, Comparing kernel hash)
        ifneq ($(shell "$(src_dir_scripts)/get_var.sh" "hash_kernel" "$(src_dir_conf)/hashes.txt"), $(shell $(call get_hash, $(src_dir_linux))))
	        $(call save_hash, hash_kernel, $(src_dir_linux))
	        $(eval bool_do_update_count := y)
	        $(eval val_changes += Kernel file changed\n)
        endif
    endif
	$(call heading, sub, Copying kernel as '$(bin_dir_tmp)$(sys_dir_linux)')
	$(Q)cp "$(src_dir_linux)" "$(bin_dir_tmp)$(sys_dir_linux)" $(OUT)
#  -- Modules --  #
	@echo ""
	$(call heading, main, Adding modules)
	$(Q)cp -r "$(src_dir_modules)" "$(bin_dir_tmp_squashfs)/usr/lib"
#  -- Text files --  #
	@echo ""
	$(call heading, main, Generating/Appending to text files in the InitRamFS archive)
    ifneq ($(shell "$(src_dir_scripts)/get_var.sh" "hash_mktext_init" "$(src_dir_conf)/hashes.txt"), $(shell $(call get_hash_dir, $(src_dir_mktext)/init)))
	    $(call save_hash_dir, hash_mktext_init, $(src_dir_mktext)/init)
	    $(eval bool_do_update_count := y)
	    $(eval val_changes += Text files created in [init archive] changed\n)
    endif
	$(Q)export sys_dir_squashfs="$(sys_dir_squashfs)"; \
	"$(src_dir_scripts)/make_text_files.sh" "$(src_dir_mktext)/init" "$(src_dir_initramfs)/source"
	@echo ""
	$(call heading, main, Generating/Appending to text files in the SquashFS image)
    ifneq ($(shell "$(src_dir_scripts)/get_var.sh" "hash_mktext_root" "$(src_dir_conf)/hashes.txt"), $(shell $(call get_hash_dir, $(src_dir_mktext)/root)))
	    $(call save_hash_dir, hash_mktext_root, $(src_dir_mktext)/root)
	    $(eval bool_do_update_count := y)
	    $(eval val_changes += Text files created in [SquashFS archive] changed\n)
    endif
	$(Q)"$(src_dir_scripts)/make_text_files.sh" "$(src_dir_mktext)/root" "$(bin_dir_tmp_squashfs)"
	@echo ""
	$(call heading, main, Generating/Appending to text files in the final image)
    ifneq ($(shell "$(src_dir_scripts)/get_var.sh" "hash_mktext_image" "$(src_dir_conf)/hashes.txt"), $(shell $(call get_hash_dir, $(src_dir_mktext)/image)))
	    $(call save_hash_dir, hash_mktext_image, $(src_dir_mktext)/image)
	    $(eval bool_do_update_count := y)
	    $(eval val_changes += Text files created in [Final ISO image] changed\n)
    endif
	$(Q)export boot_resolution="$(val_grub-boot_resolution)"; \
	export boot_default="$(val_grub-boot_default)"; \
	export boot_timeout="$(val_grub-boot_timeout)"; \
	export entry_name="$(val_grub-entry-one_name)"; \
	export sys_dir_linux="$(sys_dir_linux)"; \
	export linux_root="$(val_grub-entry-one_li_root)"; \
	export linux_params=$(val_grub-entry-one_li_params); \
	export sys_dir_initramfs="$(sys_dir_initramfs)"; \
	"$(src_dir_scripts)/make_text_files.sh" "$(src_dir_mktext)/image" "$(bin_dir_tmp)"
#  -- Initramfs --  #
	@echo ""
	$(call heading, main, Adding initramfs)
	$(call heading, sub, Making 'init' executable)
	$(Q)chmod +x "$(src_dir_initramfs)/source/init"
	$(call heading, sub, Creating init archive)
	$(Q)cd "$(src_dir_initramfs)/source"; \
	find . | cpio -o -H newc --quiet | pv -i 0.01 -s $$(du -sb . | awk '{print $$1}') | zstd --force --quiet -o "$(val_current_dir)/$(bin_dir_tmp)$(sys_dir_initramfs)"
#  -- Applications --  #
	@echo ""
	$(call heading, main, Installing applications)
	$(call applications)
    ifneq ($(shell "$(src_dir_scripts)/get_var.sh" "hash_apps" "$(src_dir_conf)/hashes.txt"), $(shell $(call get_hash_dir, $(src_dir_apps))))
	    $(call save_hash_dir, hash_apps, $(src_dir_apps))
	    $(eval bool_do_update_count := y)
	    $(eval val_changes += Applications directory changed\n)
    endif
#  -- Finalization --  #
	@echo ""
	$(call heading, main, Doing finalization procedures)
#   - Branding -   #
	$(call heading, sub, Adding branding image)
	$(Q)cp "$(src_dir_media)/branding/flat.png" "$(bin_dir_tmp_squashfs)/usr/share/branding/mrain-flat.png"
#   - Convenient aliases & Functions -   #
    ifeq ($(bool_include_aliases), y)
	    $(call heading, sub, Convenient aliases & functions)
	    $(Q)"$(src_dir_mktext)/aliases.sh" >> "$(bin_dir_tmp_squashfs)/etc/profile"
    endif
#   - Drive letters -   #
    ifeq ($(bool_use_drive_letters), y)
	    $(call heading, sub, Drive letters)
	    $(Q)export val_disks_path="$(val_disks_path)"; \
	    "$(src_dir_mktext)/drive_letters.sh" >> "$(bin_dir_tmp_squashfs)/etc/zprofile"
    endif
#   - OpenRC Bootlogging -   #
	$(call heading, sub, OpenRC bootlogging services)
	$(Q)sed -i 's/^#\?rc_logger=.*$$/rc_logger="YES"/' "$(bin_dir_tmp_squashfs)/etc/rc.conf"
#   - Watchdog daemon startup script fix -   #
	$(call heading, sub, Watchdog daemon script (if exist) timer delay)
	$(Q)file="bin/squashfs/etc/init.d/S15watchdog"; \
	if [ -f "$$file" ]; then \
			delay_time=$$(awk '/^[[:space:]]*watchdog/ && /-t [0-9]+/ { for (i=1; i<=NF; i++) if ($$i == "-t") print $$(i+1) }' "$$file"); \
			if [ -n "$$delay_time" ]; then \
					sed -i 's/ -t [0-9]*//g' "$$file"; \
			fi; \
	fi
#  -- Create SquashFS image --  #
	@echo ""
	$(call heading, main, Generating compressed SquashFS image)
	$(Q)mksquashfs "$(bin_dir_tmp_squashfs)" "$(bin_dir_tmp)$(sys_dir_squashfs)" -noappend -quiet -comp zstd
#  -- Installing GRUB --  #
	@echo ""
	$(call heading, main, Creating new disc image with GRUB)
    ifeq ($(ISO), y)
	    $(Q)grub-mkrescue -o "$(bin_dir_iso)" "$(bin_dir_tmp)" $(OUT)
    else
	    $(Q)grub-mkrescue -o "$(bin_dir)/boot.iso" "$(bin_dir_tmp)" $(OUT)
    endif
#  -- Version updation --  #
    # Makefile's 'ifeq' conditions ain't working here for some reason
	$(Q)if [ "$(bool_ver_change)" = "y" ]; then \
	    $(subst @echo, echo, $(call heading, info, Saving version: $(MRAIN_VERSION))); \
	    "$(src_dir_scripts)/set_var.sh" "ver_previous_mrain-sys" "$(MRAIN_VERSION)" "$(src_dir_conf)/variables.txt"; \
	fi
	$(Q)if [ "$(bool_do_update_count)" = "y" ] || [ "$(update)" = "true" ]; then \
	    echo "$(col_TRUE)Summary of items changed"; \
	    echo "$(col_TRUE)--------------------------$(col_NORMAL)"; \
	    echo -n " $(val_changes)"; \
	    if [ "$(update)" = "true" ]; then \
	        echo "$(col_INFO)Variable 'update' is set to true."; \
	    fi; \
	    "$(src_dir_scripts)/count_increment.sh" "latest_next" "$(src_dir_conf)/bcount.txt"; \
	fi
#  -- Automatic cleaning --  #
    ifeq ($(bool_clean_dir_tmp), y)
	    $(call true, Wipe temporary directory, bool_clean_dir_tmp)
	    $(call heading, info, $(col_FALSE)Cleaning temporary files)
	    $(Q)rm -rf "$(bin_dir_tmp)"/* "$(bin_dir_tmp_squashfs)"
    else
	    $(call false, Wipe temporary directory, bool_clean_dir_tmp)
    endif

# --- Run --- #
.PHONY: run runs
run:
    ifeq ($(bool_use_qemu_kvm), y)
	    $(eval util_vm_params += -enable-kvm -cpu host)
    endif
	$(Q)if [ -f "$(bin_dir)/boot.iso" ]; then \
	    echo ""; \
	    $(subst @echo, echo, $(call ok,    // Now running "$(bin_dir)/boot.iso" using "$(util_vm)" and parameters "$(util_vm_params)" //    )); \
	    "$(util_vm)" "$(bin_dir)/boot.iso" $(shell echo -n $(util_vm_params)); \
	else \
	    $(subst @echo, echo, $(call stop, Supplied file "$(bin_dir)/boot.iso" doesn't exist. Make sure you ran "make"; and try again.)); \
	fi
	@echo ""

runs: main run

# --- Clean --- #
.PHONY: clean
clean:
	@$(call cleancode)

define cleancode
	$(subst @echo, echo, $(call heading, info, $(col_FALSE)Deleting directories and image)); \
	rm -rf "$(bin_dir_tmp)" "$(bin_dir)/boot.iso" "$(bin_dir)"/* "$(bin_dir)"
endef

# --- Clean all stuff --- #
.PHONY: cleanall
cleanall:
	@echo ""
	$(call warn, Doing 'cleanall' will run clean on ALL of the source files and may take longer to compile.)
	@echo ""
	@echo "$(col_INFO)  Press "Y" and enter to continue, any other key will terminate.$(col_NORMAL)"
	$(Q)read choice; \
	if [ "$$choice" = "Y" ] || [ "$$choice" = "y" ]; then \
	    $(call cleancode); \
	    $(subst @echo, echo, $(call heading, info, $(col_FALSE)Cleaning buildroot)); \
	    $(MAKE) -C "$(src_dir_buildroot)" clean $(OUT) || exit 1; \
	    echo ""; \
	    $(subst @echo, echo, $(call ok,  Done. Run 'make' to re-compile. Be prepared to wait a long time.  )); \
	    echo ""; \
	else \
	    $(subst @echo, echo, $(call ok,  Cancelled.  )); \
	    echo ""; \
	fi
