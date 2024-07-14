#==--[ Makefile for MRainOS - Linux based ]--==#
# ---[ Makefile variable configuration ]--- #
#  --[ Version info ]-- #
VERSION=0
PATCHLEVEL=0
SUBLEVEL=0
EXTRAVERSION=$(shell $(src_dir_scripts)/get_var.sh "latest_next" "$(src_dir_conf)/bcount.txt")
RELEASE_TAG=unknown
#  --[ Escape sequence for colour values ]--  #
col_INFO=\e[36m
col_TRUE=\e[32m
col_FALSE=\e[91m
col_IMP=\e[1;30;41m
col_HEADING=\e[95m
col_SUBINFO=\e[38;5;206m
col_DONE=\e[92m
col_NORMAL=\e[0m
#  --[ Others ]--  #
val_current_dir=$(shell pwd)#                  # Gets the current working director
#  --[ User's configuration (overrides vars with same name) ]--  #
-include .config.mk#                           # Include .config.mk

# ---[ Global ]--- #
.PHONY: init init1 init2
init: init1 init2

init1:
	@echo ""
	@echo "$(col_INFO)               +++++++++++++++++ MRain Operating System +++++++++++++++++               $(col_NORMAL)"
    ifeq ($(bool_show_cmd), y)
	    @echo "$(col_TRUE)               !**     ShowCommand (bool_show_cmd) is set to true     **!               $(col_NORMAL)"
	    $(eval val_nul_ttyopt = dev_setcmd_show)
	    $(eval val_nul_ttycmd := )
    else
	    @echo "$(col_FALSE)               !**        ShowCommand (bool_show_cmd) is false        **!               $(col_NORMAL)"	
	    $(eval val_nul_ttycmd := @)
    endif
    ifeq ($(bool_show_cmd_out), y)
	    @echo "$(col_TRUE)               !**  ShowAppOutput (bool_show_cmd_out) is set to true  **!               $(col_NORMAL)"
    else
	    @echo "$(col_FALSE)               !**     ShowAppOutput (bool_show_cmd_out) is false     **!               $(col_NORMAL)"	
	    $(eval val_nul_outopt = dev_setcmd_show_out)
	    $(eval val_nul_outcmd = > /dev/null)
	    $(eval val_nul_mkfile_variables += --no-print-directory)
    endif

init2:
	@echo "$(col_INFO)               !**          Checking variable 'EXTRAVERSION'          **!               $(col_NORMAL)"
    ifeq ($(shell echo $(EXTRAVERSION) | grep -Eq '^[0-9]+$$' && echo 1 || echo 0), 0)
	    @echo "$(col_FALSE)  Variable 'EXTRAVERSION' expected numeric value, but it's nothing like that."
	    @echo "  Contents of the variable at this time {"
	    @echo "$(EXTRAVERSION)"
	    @echo "  }"
	    @echo "  Using value '0' instead - make sure source script and/or bconfig.txt are correct.\n$(col_NORMAL)"
	    $(eval EXTRAVERSION = 0)
    endif

# Go to 'all' if nothing is specified
.DEFAULT_GOAL := all

# ---[ Menuconfig interface setup ]--- #
srctree		:= $(if $(KBUILD_SRC),$(KBUILD_SRC),$(CURDIR))
export

HOSTCC  	= gcc
include $(srctree)/make/Kbuild.include

KERNELVERSION = $(VERSION).$(PATCHLEVEL).$(SUBLEVEL).$(EXTRAVERSION)-$(RELEASE_TAG)

.PHONY: config
config: init 
	$(MAKE) $(build)=make/kconfig $@ $(val_nul_mkfile_variables)

%config: init
	$(MAKE) $(build)=make/kconfig $@ $(val_nul_mkfile_variables)

# +++[ Random shortners (no need to be changed) ]+++ #
rsh_grub_conf=$(bin_dir_tmp)/boot/grub/grub.cfg
rsh_sylin_conf=$(bin_dir_tmp)/boot/syslinux/syslinux.cfg
rsh_exlin_conf=$(bin_dir_tmp)/boot/extlinux/syslinux.cfg
rsh_env_conf=$(src_dir_conf)/$(src_name_envconf)
rsh_get_script=$(src_dir_scripts)/$(src_name_script_get)

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
setvars: init
	@if [ -f .config.mk ]; then \
	    echo "$(col_TRUE)               !**              Configuration file found              **!               $(col_NORMAL)"; \
	else \
	    echo "$(col_FALSE)               !**           Configuration file isn't found           **!               $(col_NORMAL)"; \
	    echo ".config.mk is not found. Run 'make menuconfig', save it & try again"; \
		false; \
	fi
    ifeq ($(bool_use_sylin_exlin), y)
	    @echo "$(col_TRUE)           (1) !** BootSyslinux (bool_use_sylin_exlin) is set to true **! (1)           $(col_NORMAL)"
	    @echo "$(col_INFO)               !**          BootSyslinux: Calling CleanStart          **!               $(col_NORMAL)"
	    $(val_nul_ttycmd)$(MAKE) $(val_nul_ttyopt) $(val_nul_outopt) cleancode $(val_nul_mkfile_variables)
	    @echo "$(col_TRUE)    // Creating '$(bin_dir_tmp)' //$(col_NORMAL)"
	    $(val_nul_ttycmd)mkdir -p $(bin_dir_tmp)
	    @echo "$(col_INFO)               !**           BootSyslinux: Calling part one           **!               $(col_NORMAL)"
	    $(val_nul_ttycmd)$(MAKE) $(val_nul_ttyopt) $(val_nul_outopt) dev_iso_sylin_one $(val_nul_mkfile_variables)
	    @echo "$(col_TRUE)    // Updating superuser variable //$(col_NORMAL)"
	    $(eval val_nul_superuseropt = dev_use_sudo)
	    $(eval val_nul_superuser = sudo )
	    @echo "$(IMP_NOTE)    !! From this point on, you may get more requests for admin privileges !!    $(col_NORMAL)"
	    @echo "$(col_INFO)               !**        BootSyslinux - Calling Autodirectory        **!               $(col_NORMAL)"
	    $(val_nul_ttycmd)$(MAKE) $(val_nul_ttyopt) $(val_nul_outopt) $(val_nul_superuseropt) dirs $(val_nul_mkfile_variables)
    else
	    @echo "$(col_FALSE)           (1) !**    BootSyslinux (bool_use_sylin_exlin) is false    **! (1)           $(col_NORMAL)"
        ifeq ($(bool_clean_start), y)
	        @echo "$(col_TRUE)               !**    CleanStart (bool_clean_start) is set to true    **!               $(col_NORMAL)"
	        $(val_nul_ttycmd)$(MAKE) $(val_nul_ttyopt) $(val_nul_outopt) cleancode $(val_nul_mkfile_variables)
	        @echo "$(col_INFO)               !**         CleanStart - Calling Autodirectory         **!               $(col_NORMAL)"
	        $(val_nul_ttycmd)$(MAKE) $(val_nul_ttyopt) $(val_nul_outopt) dirs $(val_nul_mkfile_variables)
        else
	        @echo "$(col_FALSE)               !**       CleanStart (bool_clean_start) is false       **!               $(col_NORMAL)"
            ifeq ($(bool_auto_dir), y)
	            @echo "$(col_TRUE)               !**    Autodirectory (bool_auto_dir) is set to true    **!               $(col_NORMAL)"
	            $(val_nul_ttycmd)$(MAKE) $(val_nul_ttyopt) $(val_nul_outopt) dirs $(val_nul_mkfile_variables)
            else
	            @echo "$(col_FALSE)               !**       Autodirectory (bool_auto_dir) is false       **!               $(col_NORMAL)"
            endif
        endif
    endif
	@echo "$(col_INFO)               !**        Executing common structural sections        **!               $(col_NORMAL)"
	$(val_nul_ttycmd)$(MAKE) $(val_nul_ttyopt) $(val_nul_outopt) $(val_nul_superuseropt) $(val_common_struct) $(val_nul_mkfile_variables)
    ifeq ($(bool_use_sylin_exlin), y)
	    @echo "$(col_TRUE)           (2) !** BootSyslinux (bool_use_sylin_exlin) is set to true **! (2)           $(col_NORMAL)"
	    $(val_nul_ttycmd)$(MAKE) $(val_nul_ttyopt) $(val_nul_outopt) $(val_nul_superuseropt) dev_iso_sylin_two $(val_nul_mkfile_variables)
    else
	    @echo "$(col_FALSE)           (2) !**    BootSyslinux (bool_use_sylin_exlin) is false    **! (2)           $(col_NORMAL)"
	    @echo "$(col_INFO)               !**           Executing Makefile to use grub           **!               $(col_NORMAL)"
	    $(val_nul_ttycmd)$(MAKE) $(val_nul_ttyopt) $(val_nul_outopt) iso $(val_nul_mkfile_variables)
    endif
    ifeq ($(bool_del_tmp_dir), y)
	    @echo "$(col_TRUE)               !**RemoveTmpDirectory (bool_del_tmp_dir) is set to true**!               $(col_NORMAL)"
	    $(val_nul_ttycmd)$(MAKE) $(val_nul_ttyopt) $(val_nul_outopt) rm_tmp $(val_nul_mkfile_variables)
    else
	    @echo "$(col_FALSE)               !**   RemoveTmpDirectory (bool_del_tmp_dir) is false   **!               $(col_NORMAL)"
    endif

# --- Directories --- #
.PHONY: dirs
dirs:
	@echo ""
	@echo "$(col_TRUE)    // Creating directories //$(col_NORMAL)"
	$(val_nul_ttycmd)$(val_nul_superuser)mkdir -p $(bin_dir_tmp)
	$(val_nul_ttycmd)$(val_nul_superuser)$(src_dir_scripts)/mk_sys_dir.sh $(src_dir_conf)/dir.txt $(bin_dir_tmp) $(val_nul_outcmd)
	@echo ""

# --- Buildroot --- #
.PHONY: buildroot
buildroot:
	@echo ""
	@echo "$(col_HEADING)    // Adding buildroot into the image //$(col_NORMAL)"
	$(val_nul_ttycmd)if [ ! -f "$(src_dir_buildroot)/output/images/rootfs.tar" ]; then \
	    echo "$(col_SUBINFO)     / rootfs.tar does not exist, making Buildroot /$(col_NORMAL)"; \
	    $(MAKE) -C $(src_dir_buildroot) $(val_nul_mkfile_variables) || exit 1; \
	    echo "$(col_SUBINFO)     / Saving hash of .config /$(col_NORMAL)"; \
	    shasum $(src_dir_buildroot)/.config | cut -d ' ' -f 1 > $(src_dir_conf)/hash_buildroot_conf.txt; \
	    echo "$(col_SUBINFO)     / Invoking count updater /$(col_NORMAL)"; \
	    $(src_dir_scripts)/count_increment.sh latest_next $(src_dir_conf)/bcount.txt; \
	else \
	    echo "$(col_SUBINFO)     / Comparing .config hash /$(col_NORMAL)"; \
	    tmp_sh_brold=$$(cat $(src_dir_conf)/hash_buildroot_conf.txt); \
	    tmp_sh_brnew=$$(shasum $(src_dir_buildroot)/.config | cut -d ' ' -f 1); \
	    if [ "$$tmp_sh_brold" != "$$tmp_sh_brnew" ]; then \
	        echo "$(col_SUBINFO)     / Hashes don't match, making Buildroot /$(col_NORMAL)"; \
	        $(MAKE) -C $(src_dir_buildroot) $(val_nul_mkfile_variables) || exit 1; \
	        echo "$(col_SUBINFO)     / Saving hash of .config /$(col_NORMAL)"; \
	        shasum $(src_dir_buildroot)/.config | cut -d ' ' -f 1 > $(src_dir_conf)/hash_buildroot_conf.txt; \
	        echo "$(col_SUBINFO)     / Invoking count updater /$(col_NORMAL)"; \
	        $(src_dir_scripts)/count_increment.sh latest_next $(src_dir_conf)/bcount.txt; \
	    fi \
	fi
	@echo "$(col_SUBINFO)     / Extracting rootfs archive to '$(bin_dir_tmp)' //$(col_NORMAL)"
	$(val_nul_ttycmd)$(val_nul_superuser)tar xf $(src_dir_buildroot)/output/images/rootfs.tar -C $(bin_dir_tmp) $(val_nul_outcmd)

# --- Kernel --- #
.PHONY: kernel
kernel:
	@echo ""
	@echo "$(col_HEADING)    // Copying linux as '$(bin_dir_tmp)$(sys_dir_linux)' //$(col_NORMAL)"
	$(val_nul_ttycmd)$(val_nul_superuser)cp $(src_dir_linux) $(bin_dir_tmp)$(sys_dir_linux) $(val_nul_outcmd)

# --- Finalization --- #
.PHONY: final
final:
	@echo ""
	@echo "$(col_HEADING)    // Doing finalization procedures //$(col_NORMAL)"
	@echo "$(col_SUBINFO)     / Grub boot config /$(col_NORMAL)"
	$(val_nul_ttycmd)$(val_nul_superuser)bash -c 'echo default=$(val_grub-boot_default) > $(rsh_grub_conf)'
	$(val_nul_ttycmd)$(val_nul_superuser)bash -c 'echo timeout=$(val_grub-boot_timeout) >> $(rsh_grub_conf)'
	$(val_nul_ttycmd)$(val_nul_superuser)bash -c 'echo gfxpayload=$(val_grub-boot_resolution) >> $(rsh_grub_conf)'
	$(val_nul_ttycmd)$(val_nul_superuser)bash -c 'echo >> $(rsh_grub_conf)'
	$(val_nul_ttycmd)$(val_nul_superuser)bash -c 'echo menuentry \"$(val_grub-entry-one_name)\" { >> $(rsh_grub_conf)'
	$(val_nul_ttycmd)$(val_nul_superuser)bash -c 'echo "    linux $(sys_dir_linux) root=$(val_grub-entry-one_li_root) $(val_grub-entry-one_li_params)" >> $(rsh_grub_conf)'
	$(val_nul_ttycmd)$(val_nul_superuser)bash -c 'echo } >> $(rsh_grub_conf)'
	$(val_nul_ttycmd)$(val_nul_superuser)bash -c 'echo "" >> $(rsh_grub_conf)'
	@echo "$(col_SUBINFO)     / Syslinux config /$(col_NORMAL)"
	$(val_nul_ttycmd)$(val_nul_superuser)bash -c 'echo "DEFAULT $(val_grub-boot_default)" > $(rsh_sylin_conf)'
	$(val_nul_ttycmd)$(val_nul_superuser)bash -c 'echo "PROMPT 1" >> $(rsh_sylin_conf)'
	$(val_nul_ttycmd)if [ $(val_grub-boot_timeout) -gt 0 ]; then \
	    $(val_nul_superuser)bash -c 'echo "TIMEOUT $(val_grub-boot_timeout)0" >> $(rsh_sylin_conf)'; \
	else \
	    $(val_nul_superuser)bash -c 'echo "TIMEOUT 01" >> $(rsh_sylin_conf)'; \
	fi
	$(val_nul_ttycmd)$(val_nul_superuser)bash -c 'echo "" >> $(rsh_sylin_conf)'
	$(val_nul_ttycmd)$(val_nul_superuser)bash -c 'echo "LABEL $(val_grub-boot_default)" >> $(rsh_sylin_conf)'
	$(val_nul_ttycmd)$(val_nul_superuser)bash -c 'echo "    MENU LABEL $(val_grub-entry-one_name)" >> $(rsh_sylin_conf)'
	$(val_nul_ttycmd)$(val_nul_superuser)bash -c 'echo "    KERNEL $(sys_dir_linux)" >> $(rsh_sylin_conf)'
	$(val_nul_ttycmd)$(val_nul_superuser)bash -c 'echo "    APPEND root=$(val_grub-entry-one_li_root) $(val_grub-entry-one_li_params) vga=$(val_sylin-entry-one_li_vga_mode)" >> $(rsh_sylin_conf)'

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
clean: init1 cleancode

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
cleanall: init1
	@echo ""
	@echo "$(col_FALSE)  WARNING: Doing 'cleanall' will run clean on ALL the source files,"
	@echo "  which may make them take longer to compile.$(col_NORMAL)"
	@echo ""
	@echo "$(col_SUBINFO)  Press "Y" and enter to continue, any other key will terminate.$(col_NORMAL)"
	$(val_nul_ttycmd)read choice; \
	if [ "$$choice" = "Y" ] || [ "$$choice" = "y" ]; then \
	    $(MAKE) cleancode $(val_nul_mkfile_variables) || exit 1; \
	    echo "$(col_FALSE)    // Cleaning buildroot //$(col_NORMAL)"; \
	    $(MAKE) -C $(src_dir_buildroot) clean $(val_nul_mkfile_variables) || exit 1; \
		echo ""; \
	    echo "$(col_TRUE)  Done. Run 'make' to re-compile. Be prepared to wait a long time. $(col_NORMAL)"; \
		echo ""; \
	else \
	    echo "$(col_TRUE)  Cancelled. $(col_NORMAL)"; \
	    echo ""; \
	fi

# ---[ Developer testing stuff + more ]--- #
# +++ Dev phony +++ #
.PHONY: yo dev_iso_sylin_one dev_iso_sylin_two dev_setcmd_show dev_setcmd_show_out dev_use_sudo dev_stop wipe
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

dev_setcmd_show:
	$(eval val_nul_ttycmd = )
	@echo "Makefile 'nothing to be done' msg fix" > /dev/null

dev_setcmd_show_out:
	$(eval val_nul_outcmd = > /dev/null)
	@echo "Makefile 'nothing to be done' msg fix" > /dev/null

dev_use_sudo:
	$(eval val_nul_superuser = sudo )
	@echo "Makefile 'nothing to be done' msg fix" > /dev/null

dev_stop:
	false

wipe: init1 clean
	$(val_nul_ttycmd)clear

unused_commented_code:
# Following stuff is commented code not available in Makefile.old that I put here because I feel like it.
# Everything below the first two lines of a commented section is the original commented stuff.
# Eg: "Section: <section> \n"

# Section: "config" & "%config" after line "$(MAKE) $(build)=make/kconfig $@ --no-print-directory":
#
#       MOVED TO MCONF.C:
#       @if [ -f ".config" ]; then \
#           echo "$(col_INFO)    // Generating '.config.mk' from '.config' //$(col_NORMAL)\n"; \
#           sed -n 's/^CONFIG_\(.*\)=\(\"\(.*\)\"\|\(.*\)\)/\1=\3\4/p' .config > .config.mk; \
#           if grep -q '^syslinux-vga_' .config.mk; then \
#               sed -n 's/^syslinux-vga_\([0-9]*\)=.*/val_sylin-entry-one_li_vga_mode=\1/p' .config.mk >> .config.mk; \
#           else \
#               echo "val_sylin-entry-one_li_vga_mode=792" >> .config.mk; \
#           fi; \
#           if ! grep -q '^val_grub-boot_resolution' .config.mk; then \
#               echo "val_grub-boot_resolution=1024x768" >> .config.mk; \
#           fi; \
#       fi

# Section: "init" after line "@echo "$(col_INFO)               !**          Checking variable 'EXTRAVERSION'          **!               $(col_NORMAL)"":
#
#    ifeq ($(shell echo $(VERSION) | grep -Eq '^[0-9]+$$' && echo 1 || echo 0), 0)
#	    @echo "$(col_FALSE)  Variable 'VERSION' expected numeric value, but it's nothing like that."
#	    @echo "  Contents of the variable at this time {"
#	    @echo "$(VERSION)"
#	    @echo "  }"
#	    @echo "  Using value '0' instead - please verify config file using menuconfig.\n$(col_NORMAL)"
#	    $(eval VERSION = 0)
#    endif
#    ifeq ($(shell echo $(PATCHLEVEL) | grep -Eq '^[0-9]+$$' && echo 1 || echo 0), 0)
#	    @echo "$(col_FALSE)  Variable 'PATCHLEVEL' expected numeric value, but it's nothing like that."
#	    @echo "  Contents of the variable at this time {"
#	    @echo "$(PATCHLEVEL)"
#	    @echo "  }"
#	    @echo "  Using value '0' instead - please verify config file using menuconfig.\n$(col_NORMAL)"
#	    $(eval PATCHLEVEL = 0)
#    endif
#    ifeq ($(shell echo $(SUBLEVEL) | grep -Eq '^[0-9]+$$' && echo 1 || echo 0), 0)
#	    @echo "$(col_FALSE)  Variable 'SUBLEVEL' expected numeric value, but it's nothing like that."
#	    @echo "  Contents of the variable at this time {"
#	    @echo "$(SUBLEVEL)"
#	    @echo "  }"
#	    @echo "  Using value '0' instead - please verify config file using menuconfig.\n$(col_NORMAL)"
#	    $(eval SUBLEVEL = 0)
#    endif