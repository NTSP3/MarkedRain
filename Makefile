#==--[ Makefile for MRainOS - Linux based ]--==#
# ---[ Makefile variable configuration ]--- #
#  --[ Version info ]-- #
VERSION			:= 0
PATCHLEVEL		:= 0
SUBLEVEL		:= 0
# Extraversion is declared after "-include .config.mk" so it can get values of src_dir_(conf & scripts)
RELEASE_TAG		:= unknown
#  --[ Escape sequence for colour values ]--  #
col_HEADING		:= \e[95m
col_INFO		:= \e[36m
col_SUBINFO		:= \e[38;5;206m
col_DONE		:= \e[92m
col_TRUE		:= \e[32m
col_FALSE		:= \e[91m
col_ERROR		:= \e[1;91m
col_IMP			:= \e[1;37;41m
col_NORMAL		:= \e[0m
export col_HEADING col_INFO col_SUBINFO col_DONE col_TRUE col_FALSE col_ERROR col_IMP col_NORMAL
#  --[ Command shell ]-- #
SHELL := /bin/bash
#  --[ Others ]--  #
val_current_dir	:= $(shell pwd)#               # Gets the current working director
val_temp		:=#                            # Temporary variable
#  --[ User's configuration (overrides vars with same name) ]--  #
-include .config.mk#                           # Include .config.mk
# Extraversion is here - read the comment in its previous location #
EXTRAVERSION	:= $(shell $(src_dir_scripts)/get_var.sh "latest_next" "$(src_dir_conf)/bcount.txt")

# ---[ Macros ]--- #
define stop
	@echo -e ""
	@echo -e "$(col_IMP)Error:$(col_NORMAL)$(col_ERROR)$(1)$(col_NORMAL)"
	@echo -e ""
	$(Q)false
endef

define save_hash
	@echo -e "$(col_SUBINFO)     / Saving hash of$(2) as$(1)= /$(col_NORMAL)"
	$(Q)$(src_dir_scripts)/set_var.sh $(1) `shasum $(2) | cut -d ' ' -f 1` $(src_dir_conf)/hashes.txt
endef

# ---[ Global ]--- #
val_temp := \n$(col_INFO)               +++++++++++++++++ MRain Operating System +++++++++++++++++               $(col_NORMAL)
ifeq ($(bool_show_cmd), y)
    val_temp += \n$(col_TRUE)               !**     ShowCommand (bool_show_cmd) is set to true     **!               $(col_NORMAL)
    export Q :=
else
    val_temp += \n$(col_FALSE)               !**        ShowCommand (bool_show_cmd) is false        **!               $(col_NORMAL)
    export Q ?= @
endif
ifeq ($(bool_show_cmd_out), y)
    val_temp += \n$(col_TRUE)               !**  ShowAppOutput (bool_show_cmd_out) is set to true  **!               $(col_NORMAL)
else
    val_temp += \n$(col_FALSE)               !**     ShowAppOutput (bool_show_cmd_out) is false     **!               $(col_NORMAL)
    export OUT = > /dev/null
    ifeq ($(findstring --no-print-directory,$(MAKEFLAGS)), )
        MAKEFLAGS += --no-print-directory
    endif
endif
val_temp += \n$(col_INFO)               !**          Checking variable 'EXTRAVERSION'          **!               $(col_NORMAL)
ifeq ($(shell echo $(EXTRAVERSION) | grep -Eq '^[0-9]+$$' && echo 1 || echo 0), 0)
    val_temp += \n\n$(col_FALSE)  Variable 'EXTRAVERSION' expected numeric value, but it's nothing like that.
    val_temp += \n  Contents of the variable at this time {
    val_temp += \n$(EXTRAVERSION)
    val_temp += \n  }
    val_temp += \n  Using value '0' instead - make sure bconfig.txt is correct.\n$(col_NORMAL)
    $(eval EXTRAVERSION = 0)
endif
val_conf-yn := $(firstword $(MAKECMDGOALS))
ifneq ($(and $(val_conf-yn), $(filter %config,$(val_conf-yn)), $(val_conf-yn)), )
    val_temp += \n$(col_INFO)               !**              Preparing config manager              **!               $(col_NORMAL)
    export srctree := $(if $(KBUILD_SRC),$(KBUILD_SRC),$(CURDIR))
    export HOSTCC = gcc
    include $(srctree)/make/Kbuild.include
else ifeq ($(bool_use_sylin_exlin), y)#        # Export val_superuser now because we can't do it later
    val_temp += \n\n$(col_INFO)    // Exporting superuser variable //$(col_NORMAL)\n
    export val_superuser = sudo
endif

# Go to 'all' if nothing is specified #
.DEFAULT_GOAL := all

# ---[ Menuconfig interface setup ]--- #
export FINALVERSION	:= $(VERSION).$(PATCHLEVEL).$(SUBLEVEL).$(EXTRAVERSION)-$(RELEASE_TAG)

.PHONY: config %config scripts_basic
config: scripts_basic
	@echo -e "$(val_temp)"
	$(Q)$(MAKE) $(build)=make/kconfig $@

%config: scripts_basic
	@echo -e "$(val_temp)"
	$(Q)$(MAKE) $(build)=make/kconfig $@

scripts_basic:
	$(Q)$(MAKE) $(build)=make/basic

# +++[ Random shortners (no need to be changed) ]+++ #
rsh_grub_conf	:= $(bin_dir_tmp)/boot/grub/grub.cfg
rsh_sylin_conf	:= $(bin_dir_tmp)/boot/syslinux/syslinux.cfg
rsh_exlin_conf	:= $(bin_dir_tmp)/boot/extlinux/syslinux.cfg
rsh_env_conf	:= $(src_dir_conf)/$(src_name_envconf)
rsh_get_script	:= $(src_dir_scripts)/$(src_name_script_get)

# --- Default --- #
.PHONY: all
all: setvars
	@echo -e "$(col_DONE)"
	@echo -e "    -------------------------------------------------------------------------------"
	@echo -e "    // The iso is now ready. You can find it in '$(bin_dir_iso)' //"
	@echo -e "    // If you want to run this iso image now, use 'make run' //"
	@echo -e "    // If you want to automatically open the iso in $(util_vm), use 'make runs' //"
	@echo -e "$(col_NORMAL)"

# --- Variable Construction --- #
.PHONY: setvars
setvars:
	@echo -e "$(val_temp)"
    ifeq ($(shell [ -f ".config.mk" ] && echo y), y)
	    @echo -e "$(col_TRUE)               !**              Configuration file found              **!               $(col_NORMAL)"
    else
	    @echo -e "$(col_FALSE)               !**           Configuration file isn't found           **!               $(col_NORMAL)"
	    $(call stop, .config.mk is not found. Run 'make menuconfig', save it & try again)
    endif
    ifeq ($(shell [ -f "$(bin_dir_iso)" ] && echo y), y)
        ifeq ($(bool_do_timeout), y)
	        @echo -e "$(col_TRUE)               !**   Wait a minute (bool_do_timeout) is set to true   **!               $(col_NORMAL)"
	        @echo -e ""
	        @echo -e "$(col_INFO) The file specified in 'bin_dir_iso' is $(bin_dir_iso), which is a file that already exists."
	        @echo -e " Some grace time has been given for you, if you need to save the current file for whatever purpose."
	        @echo -e " Press $(col_NORMAL)$(col_ERROR)CTRL-C$(col_NORMAL)$(col_INFO) to cancel NOW. Pressing literally any other key will skip this countdown."
	        @echo -e ""
	        @echo -e " You can turn this off by setting 'bool_do_timeout' to false, or you can set 'val_timeout_num'"
		    @echo -e " to a lower number, if you find this annoying (which it probably is, but I want it)."
	        @echo -e ""
	        $(Q)for i in $$(seq $(val_timeout_num) -1 1); do \
	            echo -en "\r$(col_INFO) You have $(col_NORMAL)$(col_ERROR)$$i$(col_NORMAL)$(col_INFO) seconds left $(col_NORMAL)"; \
	            if ( read -n 1 -t 1 key </dev/tty 2>/dev/null ); then \
	                break; \
	            fi; \
	        done
	        @echo -e ""
        else
	        @echo -e "$(col_FALSE)               !**      Wait a minute (bool_do_timeout) is false      **!               $(col_NORMAL)"
        endif
    endif
	$(call cleancode)
    ifeq ($(bool_use_sylin_exlin), y)
	    @echo -e "$(col_TRUE)           (1) !** BootSyslinux (bool_use_sylin_exlin) is set to true **! (1)           $(col_NORMAL)"
	    @echo -e "$(col_TRUE)    // Creating '$(bin_dir_tmp)' //$(col_NORMAL)"
	    $(Q)mkdir -p $(bin_dir_tmp)
	    @echo -e ""
	    @echo -e "$(col_HEADING)    // Creating new disc image with syslinux as bootloader //$(col_NORMAL)"
	    @echo -e "$(col_SUBINFO)     / Creating an empty file ($(val_dev_iso_size)MB) /$(col_NORMAL)"
	    $(Q)truncate -s $(val_dev_iso_size)M $(bin_dir_iso) $(OUT)
	    @echo -e "$(col_SUBINFO)     / Creating an ext4 filesystem /$(col_NORMAL)"
	    $(Q)mkfs.ext4 $(bin_dir_iso) $(OUT)
	    @echo -e "$(col_SUBINFO)     / Mounting iso image to '$(bin_dir_tmp)' (May ask for superuser access) /$(col_NORMAL)"
	    $(Q)sudo mount $(bin_dir_iso) $(bin_dir_tmp) $(OUT)
	    @echo -e "$(col_IMP)    !! From this point on, you may get more requests for admin privileges !!    $(col_NORMAL)"
    else
	    @echo -e "$(col_FALSE)               !**    BootSyslinux (bool_use_sylin_exlin) is false    **!               $(col_NORMAL)"
    endif
#  -- Directories --  #
	@echo -e ""
	@echo -e "$(col_TRUE)    // Creating directories //$(col_NORMAL)"
	$(Q)$(val_superuser) mkdir -p "$(bin_dir_tmp)"
	$(Q)$(val_superuser) "$(src_dir_scripts)/mk_sys_dir.sh" "$(src_dir_conf)/dir.txt" "$(bin_dir_tmp)" $(OUT)
	@echo -e ""
#  -- Buildroot --  #
	@echo -e ""
	@echo -e "$(col_HEADING)    // Adding buildroot into the image //$(col_NORMAL)"
    ifneq ($(shell [ -f "$(src_dir_buildroot)/output/images/rootfs.tar" ] && echo y), y)
	    @echo -e "$(col_SUBINFO)     / rootfs.tar does not exist, making Buildroot /$(col_NORMAL)"
	    $(Q)$(MAKE) -C $(src_dir_buildroot) || exit 1
	    $(call save_hash, buildroot, $(src_dir_buildroot)/.config)
	    $(eval val_do_update_count := y)
    else
	    @echo -e "$(col_SUBINFO)     / Comparing .config hash /$(col_NORMAL)"
        ifneq ($(shell $(src_dir_scripts)/get_var.sh buildroot $(src_dir_conf)/hashes.txt),$(shell shasum $(src_dir_buildroot)/.config | cut -d ' ' -f 1))
	        @echo -e "$(col_SUBINFO)     / Hashes don't match, making Buildroot /$(col_NORMAL)"
	        $(Q)$(MAKE) -C $(src_dir_buildroot) $(OUT) || exit 1
	        $(call save_hash, buildroot, $(src_dir_buildroot)/.config)
	        $(eval val_do_update_count := y)
        endif
    endif
	@echo -e "$(col_SUBINFO)     / Extracting rootfs archive to '$(bin_dir_tmp)' /$(col_NORMAL)"
	$(Q)$(val_superuser) tar xf $(src_dir_buildroot)/output/images/rootfs.tar -C $(bin_dir_tmp) $(OUT)
#  -- Kernel --  #
	@echo -e ""
	@echo -e "$(col_HEADING)    // Adding the linux kernel //$(col_NORMAL)"
	@echo -e "$(col_SUBINFO)     / Checking if kernel exists /$(col_NORMAL)"
    ifneq ($(shell [ -f "$(src_dir_linux)" ] && echo y), y)
	    $(call stop, Kernel file doesn't exist in $(src_dir_linux). Ensure you gave the correct path to it by running menuconfig.)
    else
	    @echo -e "$(col_SUBINFO)     / Checking kernel hash /$(col_NORMAL)"
        ifneq ($(shell $(src_dir_scripts)/get_var.sh kernel $(src_dir_conf)/hashes.txt), $(shell shasum $(src_dir_linux) | cut -d ' ' -f 1))
	        $(call save_hash, kernel, $(src_dir_linux))
	        $(eval val_do_update_count := y)
        endif
    endif
	@echo -e "$(col_SUBINFO)     / Copying kernel to '$(bin_dir_tmp)$(sys_dir_linux)' /$(col_NORMAL)"
	$(Q)$(val_superuser) cp $(src_dir_linux) $(bin_dir_tmp)$(sys_dir_linux) $(OUT)
#  -- Finalization --  #
	@echo -e ""
	@echo -e "$(col_HEADING)    // Doing finalization procedures //$(col_NORMAL)"
#   - GNU/Grub conf -   #
	@echo -e "$(col_SUBINFO)     / Grub boot config /$(col_NORMAL)"
	$(Q)echo -e "\
	default=$(val_grub-boot_default) \n\
	timeout=$(val_grub-boot_timeout) \n\
	gfxpayload=$(val_grub-boot_resolution) \n\
	\n\
	menuentry \"$(val_grub-entry-one_name)\" { \n\
	    linux $(sys_dir_linux) root=$(val_grub-entry-one_li_root) $(val_grub-entry-one_li_params) \n\
	}" | $(val_superuser) tee $(rsh_grub_conf) $(OUT)
#   - Syslinux conf -   #
	@echo -e "$(col_SUBINFO)     / Syslinux config /$(col_NORMAL)"
	$(Q)echo -e "\
	DEFAULT $(val_grub-boot_default) \n\
	PROMPT 1" \
	| $(val_superuser) tee $(rsh_sylin_conf) $(OUT)
	$(Q)if [ $(val_grub-boot_timeout) -gt 0 ]; then \
	    $(val_superuser) bash -c 'echo "TIMEOUT $(val_grub-boot_timeout)0" >> $(rsh_sylin_conf)'; \
	else \
	    $(val_superuser) bash -c 'echo "TIMEOUT 01" >> $(rsh_sylin_conf)'; \
	fi
	$(Q)echo -e "\
	LABEL $(val_grub-boot_default) \n\
	    MENU LABEL $(val_grub-entry-one_name) \n\
	    KERNEL $(sys_dir_linux) \n\
	    APPEND root=$(val_grub-entry-one_li_root) $(val_grub-entry-one_li_params) vga=$(val_sylin-entry-one_li_vga_mode)" \
	| $(val_superuser) tee -a $(rsh_sylin_conf) $(OUT)
    ifeq ($(bool_use_sylin_exlin), y)
	    @echo -e "$(col_TRUE)           (2) !** BootSyslinux (bool_use_sylin_exlin) is set to true **! (2)           $(col_NORMAL)"
	    @echo -e "$(col_SUBINFO)     / Installing syslinux (May ask for superuser access) /$(col_NORMAL)"
	    $(Q)sudo extlinux --install $(bin_dir_tmp) $(OUT)
	    @echo -e "$(col_SUBINFO)     / Unmounting '$(bin_dir_tmp)' (May ask for superuser access) /$(col_NORMAL)"
	    $(Q)sudo umount $(bin_dir_tmp) $(OUT)
    else
	    @echo -e "$(col_INFO)               !**             Making iso image with GRUB             **!               $(col_NORMAL)"
	    @echo -e ""
	    @echo -e "$(col_HEADING)    // Creating new disc image with GRUB //$(col_NORMAL)"
	    $(Q)grub-mkrescue -o $(bin_dir_iso) $(bin_dir_tmp) $(OUT)
    endif
    ifeq ($(val_do_update_count), y)
	    echo $(Q)"$(src_dir_scripts)/count_increment.sh" "latest_next" "$(src_dir_conf)/bcount.txt" "$(EXTRAVERSION)"" "$(col_SUBINFO)"
    endif
	    @echo -e ""
	    @echo -e "$(col_FALSE)    // Cleaning temporary files //$(col_NORMAL)"
	    $(Q)rm -rf $(bin_dir_tmp)

# --- Run --- #
.PHONY: run runs
run:
	@echo -e ""
	@echo -e "$(col_INFO)    // Now running '$(bin_dir_iso)' using '$(util_vm)' //$(col_NORMAL)"
	$(Q)$(util_vm) $(util_vm_params) $(bin_dir_iso) $(OUT)

runs: setvars run

# --- Clean --- #
.PHONY: clean
clean:
	@echo -e "$(val_temp)"
	$(call cleancode)

define cleancode
	@echo -e ""
	$(Q)if mountpoint -q "$(bin_dir_tmp)"; then \
		echo -e "$(col_FALSE)    // Unmounting '$(bin_dir_tmp)' (May ask for superuser access) //$(col_NORMAL)"; \
		sudo umount "$(bin_dir_tmp)" $(OUT); \
	fi
	@echo -e "$(col_FALSE)    // Deleting directories and image //$(col_NORMAL)"
	$(Q)rm -rf $(bin_dir_tmp) $(bin_dir_iso) $(bin_dir)
	@echo -e ""
endef

# --- Clean all stuff --- #
.PHONY: cleanall
cleanall:
	@echo -e "$(val_temp)"
	@echo -e ""
	@echo -e "$(col_FALSE)  WARNING: Doing 'cleanall' will run clean on ALL the source files,"
	@echo -e "  which may make them take longer to compile.$(col_NORMAL)"
	@echo -e ""
	@echo -e "$(col_SUBINFO)  Press "Y" and enter to continue, any other key will terminate.$(col_NORMAL)"
	$(Q)read choice; \
	if [ "$$choice" = "Y" ] || [ "$$choice" = "y" ]; then \
	    @echo -e ""; \
	    $(Q)if mountpoint -q "$(bin_dir_tmp)"; then \
	        echo -e "$(col_FALSE)    // Unmounting '$(bin_dir_tmp)' (May ask for superuser access) //$(col_NORMAL)"; \
	        sudo umount "$(bin_dir_tmp)" $(OUT); \
	    fi; \
	    @echo -e "$(col_FALSE)    // Deleting directories and image //$(col_NORMAL)"; \
	    $(Q)rm -rf $(bin_dir_tmp) $(bin_dir_iso) $(bin_dir); \
	    @echo -e ""; \
	    echo -e "$(col_FALSE)    // Cleaning buildroot //$(col_NORMAL)"; \
	    $(MAKE) -C $(src_dir_buildroot) clean || exit 1; \
		echo -e ""; \
	    echo -e "$(col_TRUE)  Done. Run 'make' to re-compile. Be prepared to wait a long time. $(col_NORMAL)"; \
		echo -e ""; \
	else \
	    echo -e "$(col_TRUE)  Cancelled. $(col_NORMAL)"; \
	    echo -e ""; \
	fi

# ---[ Developer testing stuff + more ]--- #
# +++ Dev phony +++ #
.PHONY: yo dev_stop wipe
# --- Stuff --- #
yo:
	@echo -e "yo the dir is $(val_current_dir)"

dev_stop:
	false

wipe: clean
	$(Q)clear
