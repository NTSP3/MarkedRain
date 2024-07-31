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
#  --[ Others ]--  #
val_current_dir	:= $(shell pwd)#               # Gets the current working director
val_temp		:=#                            # Temporary variable
#  --[ User's configuration (overrides vars with same name) ]--  #
-include .config.mk#                           # Include .config.mk
# Extraversion is here - read the comment in its previous location #
EXTRAVERSION	:= $(shell $(src_dir_scripts)/get_var.sh "latest_next" "$(src_dir_conf)/bcount.txt")

# ---[ Macros ]--- #
define stop
	@echo ""
	@echo "$(col_IMP)Error:$(col_NORMAL)$(col_ERROR)$(1)$(col_NORMAL)"
	@echo ""
	$(val_nul_ttycmd)false
endef

define save_hash
	@echo "$(col_SUBINFO)     / Saving hash of$(2) as$(1)= /$(col_NORMAL)"
	$(val_nul_ttycmd)$(src_dir_scripts)/set_var.sh $(1) `shasum $(2) | cut -d ' ' -f 1` $(src_dir_conf)/hashes.txt
endef

define update_count
	$(val_nul_ttycmd)$(src_dir_scripts)/count_increment.sh latest_next $(src_dir_conf)/bcount.txt $(EXTRAVERSION) "$(col_SUBINFO)" $(val_nul_outcmd)
endef

# ---[ Global ]--- #
val_temp := \n$(col_INFO)               +++++++++++++++++ MRain Operating System +++++++++++++++++               $(col_NORMAL)
ifeq ($(bool_show_cmd), y)
    val_temp += \n$(col_TRUE)               !**     ShowCommand (bool_show_cmd) is set to true     **!               $(col_NORMAL)
    export val_nul_ttycmd :=
else
    val_temp += \n$(col_FALSE)               !**        ShowCommand (bool_show_cmd) is false        **!               $(col_NORMAL)
    export val_nul_ttycmd := @
endif
ifeq ($(bool_show_cmd_out), y)
    val_temp += \n$(col_TRUE)               !**  ShowAppOutput (bool_show_cmd_out) is set to true  **!               $(col_NORMAL)
else
    val_temp += \n$(col_FALSE)               !**     ShowAppOutput (bool_show_cmd_out) is false     **!               $(col_NORMAL)
    export val_nul_outcmd = > /dev/null
    ifeq ($(findstring --no-print-directory,$(MAKEFLAGS)), )
        MAKEFLAGS += --no-print-directory
    endif
endif
ifeq ($(bool_use_sylin_exlin), y)#             # Export val_nul_superuser now because we can't do it later
    export val_nul_superuser = sudo
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
val_nul_conf-yn := $(firstword $(MAKECMDGOALS))
ifneq ($(and $(val_nul_conf-yn), $(filter %config,$(val_nul_conf-yn)), $(val_nul_conf-yn)), )
    val_temp += \n$(col_INFO)               !**              Preparing config manager              **!               $(col_NORMAL)
    export srctree := $(if $(KBUILD_SRC),$(KBUILD_SRC),$(CURDIR))
    export HOSTCC = gcc
    include $(srctree)/make/Kbuild.include
endif

# Go to 'all' if nothing is specified #
.DEFAULT_GOAL := all

# ---[ Menuconfig interface setup ]--- #
KERNELVERSION	:= $(VERSION).$(PATCHLEVEL).$(SUBLEVEL).$(EXTRAVERSION)-$(RELEASE_TAG)

.PHONY: config
config:
	@echo "$(val_temp)"
	$(val_nul_ttycmd)$(MAKE) $(build)=make/kconfig $@

%config:
	@echo "$(val_temp)"
	$(val_nul_ttycmd)$(MAKE) $(build)=make/kconfig $@

# +++[ Random shortners (no need to be changed) ]+++ #
rsh_grub_conf	:= $(bin_dir_tmp)/boot/grub/grub.cfg
rsh_sylin_conf	:= $(bin_dir_tmp)/boot/syslinux/syslinux.cfg
rsh_exlin_conf	:= $(bin_dir_tmp)/boot/extlinux/syslinux.cfg
rsh_env_conf	:= $(src_dir_conf)/$(src_name_envconf)
rsh_get_script	:= $(src_dir_scripts)/$(src_name_script_get)

# --- Default --- #
.PHONY: all
all: setvars
	@echo "$(col_DONE)"
	@echo "    -------------------------------------------------------------------------------"
	@echo "    // The iso is now ready. You can find it in '$(bin_dir_iso)' //"
	@echo "    // If you want to run this iso image now, use 'make run' //"
	@echo "    // If you want to automatically open the iso in $(util_vm), use 'make runs' //"
	@echo "$(col_NORMAL)"

# --- Variable Construction --- #
.PHONY: setvars
setvars:
	@echo "$(val_temp)"
    ifeq ($(shell [ -f ".config.mk" ] && echo y), y)
	    @echo "$(col_TRUE)               !**              Configuration file found              **!               $(col_NORMAL)"
    else
	    @echo "$(col_FALSE)               !**           Configuration file isn't found           **!               $(col_NORMAL)"
	    $(call stop, .config.mk is not found. Run 'make menuconfig', save it & try again)
    endif
    ifeq ($(bool_use_sylin_exlin), y)
	    @echo "$(col_TRUE)           (1) !** BootSyslinux (bool_use_sylin_exlin) is set to true **! (1)           $(col_NORMAL)"
	    @echo "$(col_INFO)               !**          BootSyslinux: Calling CleanStart          **!               $(col_NORMAL)"
	    $(val_nul_ttycmd)$(MAKE) cleancode
	    @echo "$(col_TRUE)    // Creating '$(bin_dir_tmp)' //$(col_NORMAL)"
	    $(val_nul_ttycmd)mkdir -p $(bin_dir_tmp)
	    @echo "$(col_INFO)               !**           BootSyslinux: Calling part one           **!               $(col_NORMAL)"
	    $(val_nul_ttycmd)$(MAKE) dev_iso_sylin_one
	    @echo "$(col_INFO)    // Superuser variable likely already exported //$(col_NORMAL)"
	    @echo "$(col_IMP)    !! From this point on, you may get more requests for admin privileges !!    $(col_NORMAL)"
	    @echo "$(col_INFO)               !**        BootSyslinux - Calling Autodirectory        **!               $(col_NORMAL)"
	    $(val_nul_ttycmd)$(MAKE) dirs
    else
	    @echo "$(col_FALSE)           (1) !**    BootSyslinux (bool_use_sylin_exlin) is false    **! (1)           $(col_NORMAL)"
        ifeq ($(bool_clean_start), y)
	        @echo "$(col_TRUE)               !**    CleanStart (bool_clean_start) is set to true    **!               $(col_NORMAL)"
	        $(val_nul_ttycmd)$(MAKE) cleancode
	        @echo "$(col_INFO)               !**         CleanStart - Calling Autodirectory         **!               $(col_NORMAL)"
	        $(val_nul_ttycmd)$(MAKE) dirs
        else
	        @echo "$(col_FALSE)               !**       CleanStart (bool_clean_start) is false       **!               $(col_NORMAL)"
            ifeq ($(bool_auto_dir), y)
	            @echo "$(col_TRUE)               !**    Autodirectory (bool_auto_dir) is set to true    **!               $(col_NORMAL)"
	            $(val_nul_ttycmd)$(MAKE) dirs
            else
	            @echo "$(col_FALSE)               !**       Autodirectory (bool_auto_dir) is false       **!               $(col_NORMAL)"
            endif
        endif
    endif
	@echo "$(col_INFO)               !**        Executing common structural sections        **!               $(col_NORMAL)"
	$(val_nul_ttycmd)$(MAKE) $(val_common_struct)
    ifeq ($(bool_use_sylin_exlin), y)
	    @echo "$(col_TRUE)           (2) !** BootSyslinux (bool_use_sylin_exlin) is set to true **! (2)           $(col_NORMAL)"
	    $(val_nul_ttycmd)$(MAKE) dev_iso_sylin_two
    else
	    @echo "$(col_FALSE)           (2) !**    BootSyslinux (bool_use_sylin_exlin) is false    **! (2)           $(col_NORMAL)"
	    @echo "$(col_INFO)               !**           Executing Makefile to use grub           **!               $(col_NORMAL)"
	    $(val_nul_ttycmd)$(MAKE) iso
    endif
    ifeq ($(bool_del_tmp_dir), y)
	    @echo "$(col_TRUE)               !**RemoveTmpDirectory (bool_del_tmp_dir) is set to true**!               $(col_NORMAL)"
	    $(val_nul_ttycmd)$(MAKE) rm_tmp
    else
	    @echo "$(col_FALSE)               !**   RemoveTmpDirectory (bool_del_tmp_dir) is false   **!               $(col_NORMAL)"
    endif

# --- Directories --- #
.PHONY: dirs
dirs:
	@echo ""
	@echo "$(col_TRUE)    // Creating directories //$(col_NORMAL)"
	$(val_nul_ttycmd)$(val_nul_superuser) mkdir -p $(bin_dir_tmp)
	$(val_nul_ttycmd)$(val_nul_superuser) $(src_dir_scripts)/mk_sys_dir.sh $(src_dir_conf)/dir.txt $(bin_dir_tmp) $(val_nul_outcmd)
	@echo ""

# --- Buildroot --- #
.PHONY: buildroot
buildroot:
	@echo ""
	@echo "$(col_HEADING)    // Adding buildroot into the image //$(col_NORMAL)"
    ifneq ($(shell [ -f "$(src_dir_buildroot)/output/images/rootfs.tar" ] && echo y), y)
	    @echo "$(col_SUBINFO)     / rootfs.tar does not exist, making Buildroot /$(col_NORMAL)"
	    $(val_nul_ttycmd)$(MAKE) -C $(src_dir_buildroot) || exit 1
	    $(call save_hash, buildroot, $(src_dir_buildroot)/.config)
	    $(call update_count)
    else
	    @echo "$(col_SUBINFO)     / Comparing .config hash /$(col_NORMAL)"
        ifneq ($(shell $(src_dir_scripts)/get_var.sh buildroot $(src_dir_conf)/hashes.txt),$(shell shasum $(src_dir_buildroot)/.config | cut -d ' ' -f 1))
	        @echo "$(col_SUBINFO)     / Hashes don't match, making Buildroot /$(col_NORMAL)"
	        $(val_nul_ttycmd)$(MAKE) -C $(src_dir_buildroot) $(val_nul_outcmd) || exit 1
	        $(call save_hash, buildroot, $(src_dir_buildroot)/.config)
	        $(call update_count)
        endif
    endif
	@echo "$(col_SUBINFO)     / Extracting rootfs archive to '$(bin_dir_tmp)' /$(col_NORMAL)"
	$(val_nul_ttycmd)$(val_nul_superuser) tar xf $(src_dir_buildroot)/output/images/rootfs.tar -C $(bin_dir_tmp) $(val_nul_outcmd)

# --- Kernel --- #
.PHONY: kernel
kernel:
	@echo ""
	@echo "$(col_HEADING)    // Adding the linux kernel //$(col_NORMAL)"
	@echo "$(col_SUBINFO)     / Checking if kernel exists /$(col_NORMAL)"
    ifneq ($(shell [ -f "$(src_dir_linux)" ] && echo y), y)
	    $(call stop, Kernel file doesn't exist in $(src_dir_linux). Ensure you gave the correct path to it by running menuconfig.)
    else
	    @echo "$(col_SUBINFO)     / Checking kernel hash /$(col_NORMAL)"
        ifneq ($(shell $(src_dir_scripts)/get_var.sh kernel $(src_dir_conf)/hashes.txt), $(shell shasum $(src_dir_linux) | cut -d ' ' -f 1))
	        $(call save_hash, kernel, $(src_dir_linux))
	        $(call update_count)
        endif
    endif
	@echo "$(col_SUBINFO)     / Copying kernel to '$(bin_dir_tmp)$(sys_dir_linux)' /$(col_NORMAL)"
	$(val_nul_ttycmd)$(val_nul_superuser) cp $(src_dir_linux) $(bin_dir_tmp)$(sys_dir_linux) $(val_nul_outcmd)

# --- Finalization --- #
.PHONY: final
final:
	@echo ""
	@echo "$(col_HEADING)    // Doing finalization procedures //$(col_NORMAL)"
	@echo "$(col_SUBINFO)     / Grub boot config /$(col_NORMAL)"
	$(val_nul_ttycmd)$(val_nul_superuser) bash -c 'echo default=$(val_grub-boot_default) > $(rsh_grub_conf)'
	$(val_nul_ttycmd)$(val_nul_superuser) bash -c 'echo timeout=$(val_grub-boot_timeout) >> $(rsh_grub_conf)'
	$(val_nul_ttycmd)$(val_nul_superuser) bash -c 'echo gfxpayload=$(val_grub-boot_resolution) >> $(rsh_grub_conf)'
	$(val_nul_ttycmd)$(val_nul_superuser) bash -c 'echo >> $(rsh_grub_conf)'
	$(val_nul_ttycmd)$(val_nul_superuser) bash -c 'echo menuentry \"$(val_grub-entry-one_name)\" { >> $(rsh_grub_conf)'
	$(val_nul_ttycmd)$(val_nul_superuser) bash -c 'echo "    linux $(sys_dir_linux) root=$(val_grub-entry-one_li_root) $(val_grub-entry-one_li_params)" >> $(rsh_grub_conf)'
	$(val_nul_ttycmd)$(val_nul_superuser) bash -c 'echo } >> $(rsh_grub_conf)'
	$(val_nul_ttycmd)$(val_nul_superuser) bash -c 'echo "" >> $(rsh_grub_conf)'
	@echo "$(col_SUBINFO)     / Syslinux config /$(col_NORMAL)"
	$(val_nul_ttycmd)$(val_nul_superuser) bash -c 'echo "DEFAULT $(val_grub-boot_default)" > $(rsh_sylin_conf)'
	$(val_nul_ttycmd)$(val_nul_superuser) bash -c 'echo "PROMPT 1" >> $(rsh_sylin_conf)'
	$(val_nul_ttycmd)if [ $(val_grub-boot_timeout) -gt 0 ]; then \
	    $(val_nul_superuser) bash -c 'echo "TIMEOUT $(val_grub-boot_timeout)0" >> $(rsh_sylin_conf)'; \
	else \
	    $(val_nul_superuser) bash -c 'echo "TIMEOUT 01" >> $(rsh_sylin_conf)'; \
	fi
	$(val_nul_ttycmd)$(val_nul_superuser) bash -c 'echo "" >> $(rsh_sylin_conf)'
	$(val_nul_ttycmd)$(val_nul_superuser) bash -c 'echo "LABEL $(val_grub-boot_default)" >> $(rsh_sylin_conf)'
	$(val_nul_ttycmd)$(val_nul_superuser) bash -c 'echo "    MENU LABEL $(val_grub-entry-one_name)" >> $(rsh_sylin_conf)'
	$(val_nul_ttycmd)$(val_nul_superuser) bash -c 'echo "    KERNEL $(sys_dir_linux)" >> $(rsh_sylin_conf)'
	$(val_nul_ttycmd)$(val_nul_superuser) bash -c 'echo "    APPEND root=$(val_grub-entry-one_li_root) $(val_grub-entry-one_li_params) vga=$(val_sylin-entry-one_li_vga_mode)" >> $(rsh_sylin_conf)'

# --- Clean Temporary Directory --- #
.PHONY: rm_tmp
rm_tmp:
	@echo ""
	@echo "$(col_FALSE)    // Cleaning temporary files //$(col_NORMAL)"
	$(val_nul_ttycmd)rm -rf $(bin_dir_tmp)

# --- GRUB --- #
.PHONY: iso
iso:
	@echo ""
	@echo "$(col_HEADING)    // Creating new disc image with GRUB //$(col_NORMAL)"
	$(val_nul_ttycmd)grub-mkrescue -o $(bin_dir_iso) $(bin_dir_tmp) $(val_nul_outcmd)

# --- Run --- #
.PHONY: run runs
run:
	@echo ""
	@echo "$(col_INFO)    // Now running '$(bin_dir_iso)' using '$(util_vm)' //$(col_NORMAL)"
	$(val_nul_ttycmd)$(util_vm) $(util_vm_params) $(bin_dir_iso) $(val_nul_outcmd)

runs: setvars run

# --- Clean --- #
.PHONY: clean cleancode
clean:
	@echo "$(val_temp)"
	$(val_nul_ttycmd)$(MAKE) cleancode

cleancode:
	@echo ""
	$(val_nul_ttycmd)if mountpoint -q "$(bin_dir_tmp)"; then \
		echo "$(col_FALSE)    // Unmounting '$(bin_dir_tmp)' (May ask for superuser access) //$(col_NORMAL)"; \
		sudo umount "$(bin_dir_tmp)" $(val_nul_outcmd); \
	fi
	@echo "$(col_FALSE)    // Deleting directories and image //$(col_NORMAL)"
	$(val_nul_ttycmd)rm -rf $(bin_dir_tmp) $(bin_dir_iso) $(bin_dir)
	@echo ""

# --- Clean all stuff --- #
.PHONY: cleanall
cleanall:
	@echo "$(val_temp)"
	@echo ""
	@echo "$(col_FALSE)  WARNING: Doing 'cleanall' will run clean on ALL the source files,"
	@echo "  which may make them take longer to compile.$(col_NORMAL)"
	@echo ""
	@echo "$(col_SUBINFO)  Press "Y" and enter to continue, any other key will terminate.$(col_NORMAL)"
	$(val_nul_ttycmd)read choice; \
	if [ "$$choice" = "Y" ] || [ "$$choice" = "y" ]; then \
	    $(MAKE) cleancode || exit 1; \
	    echo "$(col_FALSE)    // Cleaning buildroot //$(col_NORMAL)"; \
	    $(MAKE) -C $(src_dir_buildroot) clean || exit 1; \
		echo ""; \
	    echo "$(col_TRUE)  Done. Run 'make' to re-compile. Be prepared to wait a long time. $(col_NORMAL)"; \
		echo ""; \
	else \
	    echo "$(col_TRUE)  Cancelled. $(col_NORMAL)"; \
	    echo ""; \
	fi

# ---[ Developer testing stuff + more ]--- #
# +++ Dev phony +++ #
.PHONY: yo dev_iso_sylin_one dev_iso_sylin_two dev_stop wipe
# --- Stuff --- #
yo:
	@echo "yo the dir is $(val_current_dir)"

dev_iso_sylin_one:
	@echo ""
	@echo "$(col_HEADING)    // Creating new disc image with syslinux as bootloader //$(col_NORMAL)"
	@echo "$(col_SUBINFO)     / Creating an empty file ($(val_dev_iso_size)MB) /$(col_NORMAL)"
	$(val_nul_ttycmd)truncate -s $(val_dev_iso_size)M $(bin_dir_iso) $(val_nul_outcmd)
	@echo "$(col_SUBINFO)     / Creating an ext4 filesystem /$(col_NORMAL)"
	$(val_nul_ttycmd)mkfs.ext4 $(bin_dir_iso) $(val_nul_outcmd)
	@echo "$(col_SUBINFO)     / Mounting iso image to '$(bin_dir_tmp)' (May ask for superuser access) /$(col_NORMAL)"
	$(val_nul_ttycmd)sudo mount $(bin_dir_iso) $(bin_dir_tmp) $(val_nul_outcmd)

dev_iso_sylin_two:
	@echo "$(col_SUBINFO)     / Installing syslinux (May ask for superuser access) /$(col_NORMAL)"
	$(val_nul_ttycmd)sudo extlinux --install $(bin_dir_tmp) $(val_nul_outcmd)
	@echo "$(col_SUBINFO)     / Unmounting '$(bin_dir_tmp)' (May ask for superuser access) /$(col_NORMAL)"
	$(val_nul_ttycmd)sudo umount $(bin_dir_tmp) $(val_nul_outcmd)

dev_stop:
	false

wipe: clean
	$(val_nul_ttycmd)clear
