#==--[ Makefile for MRainOS - Linux based ]--==#
# ---[ Menuconfig interface setup ]--- # (idk what they do)
VERSION = 0
PATCHLEVEL = 0
SUBLEVEL = 1
EXTRAVERSION = bruh

-include .config.mk#                           # Include .config.mk (added by me)
.DEFAULT_GOAL := all#                          # Jump to 'all' if nothing is specified (also added by me)

srctree		:= $(if $(KBUILD_SRC),$(KBUILD_SRC),$(CURDIR))
export

HOSTCC  	= gcc
include $(srctree)/make/Kbuild.include

KERNELVERSION = $(VERSION).$(PATCHLEVEL).$(SUBLEVEL)-$(EXTRAVERSION)

.PHONY: config
config:
	@$(MAKE) $(build)=make/kconfig $@ --no-print-directory

%config:
	@$(MAKE) $(build)=make/kconfig $@ --no-print-directory

# ---[ Makefile required variable configuration ]--- #
val_current_dir=$(shell pwd)#                  # Gets the current working directory
val_nul_ttycmd=@#                              # Customizable variable used to show/hide commands being sent to the tty (@ is here to hide cmds being shown in 'make clean' and stuff)

# +++[ Random shortners (no need to be changed) ]+++ #
rsh_grub_conf=$(bin_dir_tmp)/boot/grub/grub.cfg
rsh_sylin_conf=$(bin_dir_tmp)/boot/syslinux/syslinux.cfg
rsh_exlin_conf=$(bin_dir_tmp)/boot/extlinux/syslinux.cfg
rsh_env_conf=$(src_dir_conf)/$(src_name_envconf)
rsh_get_script=$(src_dir_scripts)/$(src_name_script_get)

# --- Default --- #
.PHONY: all
all: setvars
	@echo "\e[92m"
	@echo "    -------------------------------------------------------------------------------"
	@echo "    // The iso is now ready. You can find it in '$(bin_dir_iso)' //"
	@echo "    // If you want to run this iso image now, use 'make run' //"
	@echo "    // If you want to automatically open the iso in $(util_vm), use 'make runs' //"
	@echo "\e[0m"

# --- Variable Construction --- #
.PHONY: setvars
setvars:
	@echo ""
	@echo "\e[36m               +++++++++++++++++ MRain Operating System +++++++++++++++++               \e[0m"
	@if [ -f .config.mk ]; then \
	    echo "\e[32m               !**              Configuration file found              **!               \e[0m"; \
	else \
	    echo "\e[91m               !**           Configuration file isn't found           **!               \e[0m"; \
	    echo ".config.mk is not found. Run 'make menuconfig', save it & try again"; \
		false; \
	fi
    ifeq ($(bool_show_cmd), y)
	    @echo "\e[32m               !**     ShowCommand (bool_show_cmd) is set to true     **!               \e[0m"
	    $(eval val_nul_ttyopt = dev_setcmd_show)
	    $(eval val_nul_ttycmd := )
    else
	    @echo "\e[91m               !**        ShowCommand (bool_show_cmd) is false        **!               \e[0m"	
    endif
    ifeq ($(bool_show_cmd_out), y)
	    @echo "\e[32m               !**  ShowAppOutput (bool_show_cmd_out) is set to true  **!               \e[0m"
    else
	    @echo "\e[91m               !**     ShowAppOutput (bool_show_cmd_out) is false     **!               \e[0m"	
		$(eval val_nul_outopt = dev_setcmd_show_out)
	    $(eval val_nul_outcmd = > /dev/null)
	    $(eval val_nul_mkfile_variables += --no-print-directory)
    endif
    ifeq ($(bool_show_notice), y)
	    @echo "\e[32m               !**    ShowNotice (bool_show_notice) is set to true    **!               \e[0m"
		$(val_nul_ttycmd)$(MAKE) $(val_nul_ttyopt) $(val_nul_outopt) notice $(val_nul_mkfile_variables)
    else
	    @echo "\e[91m               !**       ShowNotice (bool_show_notice) is false       **!               \e[0m"
    endif
    ifeq ($(bool_use_sylin_exlin), y)
	    @echo "\e[32m           (1) !** BootSyslinux (bool_use_sylin_exlin) is set to true **! (1)           \e[0m"
	    @echo "\e[36m               !**          BootSyslinux: Calling CleanStart          **!               \e[0m"
	    $(val_nul_ttycmd)$(MAKE) $(val_nul_ttyopt) $(val_nul_outopt) clean $(val_nul_mkfile_variables)
	    @echo "\e[32m    // Creating '$(bin_dir_tmp)' //\e[0m"
	    $(val_nul_ttycmd)mkdir -p $(bin_dir_tmp)
	    @echo "\e[36m               !**           BootSyslinux: Calling part one           **!               \e[0m"
	    $(val_nul_ttycmd)$(MAKE) $(val_nul_ttyopt) $(val_nul_outopt) dev_iso_sylin_one $(val_nul_mkfile_variables)
	    @echo "\e[32m    // Updating superuser variable //\e[0m"
	    $(eval val_nul_superuseropt = dev_use_sudo)
	    $(eval val_nul_superuser = sudo )
	    @echo "\e[1;30;41m    !! From this point on, you may get more requests for admin privileges !!    \e[0m"
	    @echo "\e[36m               !**        BootSyslinux - Calling Autodirectory        **!               \e[0m"
	    $(val_nul_ttycmd)$(MAKE) $(val_nul_ttyopt) $(val_nul_outopt) $(val_nul_superuseropt) dirs $(val_nul_mkfile_variables)
    else
	    @echo "\e[91m           (1) !**    BootSyslinux (bool_use_sylin_exlin) is false    **! (1)           \e[0m"
        ifeq ($(bool_clean_start), y)
	        @echo "\e[32m               !**    CleanStart (bool_clean_start) is set to true    **!               \e[0m"
	        $(val_nul_ttycmd)$(MAKE) $(val_nul_ttyopt) $(val_nul_outopt) clean $(val_nul_mkfile_variables)
	        @echo "\e[36m               !**         CleanStart - Calling Autodirectory         **!               \e[0m"
	        $(val_nul_ttycmd)$(MAKE) $(val_nul_ttyopt) $(val_nul_outopt) dirs $(val_nul_mkfile_variables)
        else
	        @echo "\e[91m               !**       CleanStart (bool_clean_start) is false       **!               \e[0m"
            ifeq ($(bool_auto_dir), y)
	            @echo "\e[32m               !**    Autodirectory (bool_auto_dir) is set to true    **!               \e[0m"
	            $(val_nul_ttycmd)$(MAKE) $(val_nul_ttyopt) $(val_nul_outopt) dirs $(val_nul_mkfile_variables)
            else
	            @echo "\e[91m               !**       Autodirectory (bool_auto_dir) is false       **!               \e[0m"
            endif
        endif
    endif
	@echo "\e[36m               !**        Executing common structural sections        **!               \e[0m"
	$(val_nul_ttycmd)$(MAKE) $(val_nul_ttyopt) $(val_nul_outopt) $(val_nul_superuseropt) $(val_common_struct) $(val_nul_mkfile_variables)
    ifeq ($(bool_use_sylin_exlin), y)
	    @echo "\e[32m           (2) !** BootSyslinux (bool_use_sylin_exlin) is set to true **! (2)           \e[0m"
	    $(val_nul_ttycmd)$(MAKE) $(val_nul_ttyopt) $(val_nul_outopt) $(val_nul_superuseropt) dev_iso_sylin_two $(val_nul_mkfile_variables)
    else
	    @echo "\e[91m           (2) !**    BootSyslinux (bool_use_sylin_exlin) is false    **! (2)           \e[0m"
	    @echo "\e[36m               !**           Executing Makefile to use grub           **!               \e[0m"
	    $(val_nul_ttycmd)$(MAKE) $(val_nul_ttyopt) $(val_nul_outopt) iso $(val_nul_mkfile_variables)
    endif
    ifeq ($(bool_del_tmp_dir), y)
	    @echo "\e[32m               !**RemoveTmpDirectory (bool_del_tmp_dir) is set to true**!               \e[0m"
	    $(val_nul_ttycmd)$(MAKE) $(val_nul_ttyopt) $(val_nul_outopt) rm_tmp $(val_nul_mkfile_variables)
    else
	    @echo "\e[91m               !**   RemoveTmpDirectory (bool_del_tmp_dir) is false   **!               \e[0m"
    endif

# --- Notice --- #
.PHONY: notice
notice:
	@echo "\e[91m"
	@echo "    ------------------------------------"
	@echo "    \/ MRAIN-LINUX COMPILATION SCRIPT \/"
	@echo "     ++++++++++++++++++++++++++++++++++"
	@echo ""
	@echo "    If this is your first time compiling, or the output directories:"
	@echo "    '$(bin_dir_iso)', '$(bin_dir_tmp)' and its sub-dirs doesn't exist, run this:"
	@echo ""
	@echo "        make dirs"
	@echo ""
	@echo "    and then run Makefile again. You can also use 'make clean' to delete those dirs."
	@echo ""
	@echo "    If you configured the makefile to auto-create all dirs everytime, you can ignore this message by"
	@echo "    setting the variable 'bool_show_notice' to false in the menuconfig."
	@echo ""
	@echo "     ++++++++++++++++++++++++++++++++++"
	@echo "    /\ MRAIN-LINUX COMPILATION SCRIPT /\ "
	@echo "    ------------------------------------\e[0m"
	@echo ""

# --- Directories --- #
.PHONY: dirs
dirs:
	@echo ""
	@echo "\e[32m    // Creating directories //\e[0m"
	$(val_nul_ttycmd)$(val_nul_superuser)mkdir -p $(bin_dir_tmp)
	$(val_nul_ttycmd)$(val_nul_superuser)$(src_dir_scripts)/mk_sys_dir.sh $(src_dir_conf)/dir.txt $(bin_dir_tmp) $(val_nul_outcmd)
	@echo ""

# --- Buildroot --- #
.PHONY: buildroot
buildroot:
	@echo ""
	@echo "\e[95m    // Adding buildroot into the image //\e[0m"
	$(val_nul_ttycmd)if [ ! -f "$(src_dir_buildroot)/.config" ]; then \
	    echo "\e[38;5;206m     / rootfs.tar does not exist, making Buildroot /\e[0m"; \
	    $(MAKE) -C $(src_dir_buildroot) $(val_nul_outcmd); \
	    echo "\e[38;5;206m     / Saving hash of .config /\e[0m"; \
	    shasum $(src_dir_buildroot)/.config | cut -d ' ' -f 1 > $(src_dir_conf)/hash_buildroot_conf.txt; \
	else \
	    echo "\e[38;5;206m     / Comparing .config hash /\e[0m"; \
	    tmp_sh_brold=$$(cat $(src_dir_conf)/hash_buildroot_conf.txt); \
	    tmp_sh_brnew=$$(shasum $(src_dir_buildroot)/.config | cut -d ' ' -f 1); \
	    if [ "$$tmp_sh_brold" != "$$tmp_sh_brnew" ]; then \
	        echo "\e[38;5;206m     / Hashes don't match, making Buildroot /\e[0m"; \
	        $(MAKE) -C $(src_dir_buildroot) $(val_nul_outcmd); \
	        echo "\e[38;5;206m     / Saving hash of .config /\e[0m"; \
	        shasum $(src_dir_buildroot)/.config | cut -d ' ' -f 1 > $(src_dir_conf)/hash_buildroot_conf.txt; \
	    fi \
	fi
	@echo "\e[38;5;206m     / Extracting rootfs archive to '$(bin_dir_tmp)$(sys_dir_sys)/rootfs' //\e[0m"
	$(val_nul_ttycmd)$(val_nul_superuser)tar xf $(src_dir_buildroot)/output/images/rootfs.tar -C $(bin_dir_tmp)$(sys_dir_sys)/rootfs $(val_nul_outcmd)

# --- Kernel --- #
.PHONY: kernel
kernel:
	@echo ""
	@echo "\e[95m    // Copying linux as '$(bin_dir_tmp)$(sys_dir_linux)' //\e[0m"
	$(val_nul_ttycmd)$(val_nul_superuser)cp $(src_dir_linux) $(bin_dir_tmp)$(sys_dir_linux) $(val_nul_outcmd)

# --- Finalization --- #
.PHONY: final
final:
	@echo ""
	@echo "\e[95m    // Doing finalization procedures //\e[0m"
	@echo "\e[38;5;206m     / Grub boot config /\e[0m"
	$(val_nul_ttycmd)$(val_nul_superuser)bash -c 'echo default=$(val_grub-boot_default) > $(rsh_grub_conf)'
	$(val_nul_ttycmd)$(val_nul_superuser)bash -c 'echo timeout=$(val_grub-boot_timeout) >> $(rsh_grub_conf)'
	$(val_nul_ttycmd)$(val_nul_superuser)bash -c 'echo gfxpayload=$(val_grub-boot_resolution) >> $(rsh_grub_conf)'
	$(val_nul_ttycmd)$(val_nul_superuser)bash -c 'echo >> $(rsh_grub_conf)'
	$(val_nul_ttycmd)$(val_nul_superuser)bash -c 'echo menuentry \"$(val_grub-entry-one_name)\" { >> $(rsh_grub_conf)'
	$(val_nul_ttycmd)$(val_nul_superuser)bash -c 'echo "    linux $(sys_dir_linux) root=$(val_grub-entry-one_li_root) $(val_grub-entry-one_li_params)" >> $(rsh_grub_conf)'
	$(val_nul_ttycmd)$(val_nul_superuser)bash -c 'echo } >> $(rsh_grub_conf)'
	$(val_nul_ttycmd)$(val_nul_superuser)bash -c 'echo "" >> $(rsh_grub_conf)'
	@echo "\e[38;5;206m     / Syslinux config /\e[0m"
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
#COMPILE ROOTINIT AND ADD IT INTO THE DIR AND ALSO CREATE SYMLINK FOR LIB64

# --- Clean Temporary Directory --- #
.PHONY: rm_tmp
rm_tmp:
	@echo ""
	@echo "\e[91m    // Cleaning temporary files //\e[0m"
	$(val_nul_ttycmd)rm -rf $(bin_dir_tmp)

# --- GRUB --- #
.PHONY: iso
iso:
	@echo ""
	@echo "\e[95m    // Creating new disc image with GRUB //\e[0m"
	$(val_nul_ttycmd)grub-mkrescue -o $(bin_dir_iso) $(bin_dir_tmp) $(val_nul_outcmd)

# --- Run --- #
.PHONY: run runs
run:
	@echo ""
	@echo "\e[36m    // Now running '$(bin_dir_iso)' using '$(util_vm)' //\e[0m"
	$(val_nul_ttycmd)$(util_vm) $(util_vm_params) $(bin_dir_iso) $(val_nul_outcmd)

runs: setvars run

# --- Clean --- #
.PHONY: clean
clean:
	@echo ""
	$(val_nul_ttycmd)if mountpoint -q "$(bin_dir_tmp)"; then \
		echo "\e[91m    // Unmounting '$(bin_dir_tmp)' (May ask for superuser access) //\e[0m"; \
		sudo umount "$(bin_dir_tmp)" $(val_nul_outcmd); \
	fi
	@echo "\e[91m    // Deleting directories and image //\e[0m"
	$(val_nul_ttycmd)rm -rf $(bin_dir_tmp) $(bin_dir_iso) $(bin_dir)
	@echo ""

# ---[ Developer testing stuff + more ]--- #
# +++ Dev phony +++ #
.PHONY: yo dev_iso_sylin_one dev_iso_sylin_two dev_setcmd_show dev_setcmd_show_out dev_use_sudo wipe
# --- Stuff --- #
yo:
	@echo "yo the dir is $(val_current_dir)"

dev_iso_sylin_one:
	@echo ""
	@echo "\e[95m    // Creating new disc image with syslinux as bootloader //\e[0m"
	@echo "\e[38;5;206m     / Creating an empty file ($(val_dev_iso_size)MB) /\e[0m"
	$(val_nul_ttycmd)truncate -s $(val_dev_iso_size)M $(bin_dir_iso) $(val_nul_outcmd)
	@echo "\e[38;5;206m     / Creating an ext4 filesystem /\e[0m"
	$(val_nul_ttycmd)mkfs.ext4 $(bin_dir_iso) $(val_nul_outcmd)
	@echo "\e[38;5;206m     / Mounting iso image to '$(bin_dir_tmp)' (May ask for superuser access) /\e[0m"
	$(val_nul_ttycmd)sudo mount $(bin_dir_iso) $(bin_dir_tmp) $(val_nul_outcmd)

dev_iso_sylin_two:
	@echo "\e[38;5;206m     / Installing syslinux (May ask for superuser access) /\e[0m"
	$(val_nul_ttycmd)sudo extlinux --install $(bin_dir_tmp) $(val_nul_outcmd)
	@echo "\e[38;5;206m     / Unmounting '$(bin_dir_tmp)' (May ask for superuser access) /\e[0m"
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

wipe: clean
	@clear

unused_commented_code:
# Following stuff is commented code not available in Makefile.old that I put here because I feel like it.
# Everything below the first two lines of a commented section is the original commented stuff.
# Eg: "Section: <section> \n"

# Section: "config" & "%config" after line "$(MAKE) $(build)=make/kconfig $@ --no-print-directory":
#
#       MOVED TO MCONF.C:
#       @if [ -f ".config" ]; then \
#           echo "\e[36m    // Generating '.config.mk' from '.config' //\e[0m\n"; \
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
