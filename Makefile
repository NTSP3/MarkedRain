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
#  --[ Command shell ]-- #
SHELL					:= /bin/bash
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
	$(Q)"$(src_dir_scripts)/set_var.sh" "$(strip $(1))" `$(call get_hash, $(2))` "$(src_dir_conf)/variables.txt"
endef

define get_hash_dir
	find "$(strip $(1))" -type f -exec stat --format="%s %Y %n" {} + | sort | shasum | cut -d ' ' -f 1
endef

define save_hash_dir
	@$(call heading, info, Saving hash of directory '$(strip $(2))' as '$(strip $(1))=')
	$(Q)"$(src_dir_scripts)/set_var.sh" "$(strip $(1))" `$(call get_hash_dir, $(2))` "$(src_dir_conf)/variables.txt"
endef

#  --[ Exceptional message printers ]--  #
define stop
	@echo -e "\n$(col_IMP)STOP:$(col_NORMAL)$(col_ERROR) $(strip $(1))$(col_NORMAL)\n" >&2
	$(Q)false
endef

define warn
	@echo -e "$(col_ERROR)  Warning:$(col_NORMAL)$(col_FALSE) $(strip $(1))$(col_NORMAL)" >&2
endef

define ok
	@echo -e "$(col_DONE)$(1)$(col_NORMAL)"
endef

#  --[ Common message printers ]--  #
define stat
	@echo -n; \
	val_temp='$(strip $(1))'; \
	val_temp2=$${#val_temp}; \
	if [ $$val_temp2 -gt 52 ] || [ $$((val_temp2 % 2)) -ne 0 ]; then \
	    $(subst @echo, echo, $(call warn, Total length of characters ($$val_temp2) supplied to definition \"$(0)\" is greater than 52 or is not even.)); \
	else \
	    val_temp2=$$(((52 - (val_temp2)) / 2)); \
	    val_temp2=$$(printf '%*s' "$$val_temp2"); \
	    echo -e "$(col_INFO)               !**$$val_temp2$$val_temp$$val_temp2**!               $(col_NORMAL)"; \
	fi
endef

define true
	@echo -n; \
	val_temp='$(strip $(1))'; \
	val_temp2=$${#val_temp}; \
	val_temp3='$(strip $(2))'; \
	val_temp4=$${#val_temp3}; \
	val_temp2=$$((val_temp2 + val_temp4)); \
	if [ $$val_temp2 -gt 34 ] || [ $$((val_temp2 % 2)) -ne 0 ]; then \
	    $(subst @echo, echo, $(call warn, Total length of characters ($$val_temp2) supplied to definition \"$(0)\" is greater than 34 or is not even.)); \
	else \
	    val_temp2=$$(((52 - (val_temp2 + 4 + 14)) / 2)); \
	    val_temp2=$$(printf '%*s' "$$val_temp2"); \
	    echo -e "$(col_TRUE)               !**$$val_temp2$$val_temp ($$val_temp3) is set to true$$val_temp2**!               $(col_NORMAL)"; \
	fi
endef

define false
	@echo -n; \
	val_temp='$(strip $(1))'; \
	val_temp2=$${#val_temp}; \
	val_temp3='$(strip $(2))'; \
	val_temp4=$${#val_temp3}; \
	val_temp2=$$((val_temp2 + val_temp4)); \
	if [ $$val_temp2 -gt 40 ] || [ $$((val_temp2 % 2)) -ne 0 ]; then \
	    $(subst @echo, echo, $(call warn, Total length of characters ($$val_temp2) supplied to definition \"$(0)\" is greater than 40 or is not even.)); \
	else \
	    val_temp2=$$(((52 - (val_temp2 + 4 + 8)) / 2)); \
	    val_temp2=$$(printf '%*s' "$$val_temp2"); \
	    echo -e "$(col_FALSE)               !**$$val_temp2$$val_temp ($$val_temp3) is false$$val_temp2**!               $(col_NORMAL)"; \
	fi
endef

ifeq ($(bool_use_old_headings), y)
    define script_heading
	    if [ "<type>" = "imp" ]; then \
	        echo -e "\e[1;37;41m    !! <message> !!    \e[0m"; \
	    elif [ "<type>" = "main" ]; then \
	        echo -e "\e[95m    // <message> //\e[0m"; \
	    elif [ "<type>" = "sub" ]; then \
	        echo -e "\e[38;5;206m     / <message> /\e[0m"; \
	    elif [ "<type>" = "sub2" ]; then \
	        echo -e "$(col_SUBHEADING)  -+ <message> +-  $(col_NORMAL)"; \
	    elif [ "<type>" = "info" ]; then \
	        echo -e "\e[36m    // <message>\e[36m //\e[0m"; \
	    else \
	        $(subst @echo, echo, $(call warn, Definition \"script_heading\" doesn't know what '<type>' means.)); \
	    fi
    endef
else
    define script_heading
	    if [ "<type>" = "imp" ]; then \
	        echo -e "$(col_IMP) !! <message> !! $(col_NORMAL)"; \
	    elif [ "<type>" = "main" ]; then \
	        echo -e "$(col_HEADING)---[ <message> ]---$(col_NORMAL)"; \
	    elif [ "<type>" = "sub" ]; then \
	        echo -e "$(col_SUBHEADING) --+ <message> +-- $(col_NORMAL)"; \
	    elif [ "<type>" = "sub2" ]; then \
	        echo -e "$(col_SUBHEADING)  -+ <message> +-  $(col_NORMAL)"; \
	    elif [ "<type>" = "info" ]; then \
	        echo -e "$(col_INFOHEADING) ++ <message>$(col_NORMAL)$(col_INFOHEADING) ++ $(col_NORMAL)"; \
	    else \
	        $(subst @echo, echo, $(call warn, Definition \"script_heading\" doesn't know what '<type>' means.)); \
	    fi
    endef
endif
# For scripts
export script_heading
# Normal
define heading
	@echo -n; \
	$(subst script_heading,$(0),$(subst <message>,$(strip $(2)),$(subst <type>,$(strip $(1)),$(call script_heading))))
endef

# ---[ Global ]--- #
$(info $(shell echo -e "$(col_INFO)               +++++++++++++++++ MRain Operating System +++++++++++++++++               $(col_NORMAL)"))
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
        $(info $(shell $(subst @echo, echo, $(call stat, Preparing config manager))))
        export srctree := $(if $(KBUILD_SRC),$(KBUILD_SRC),$(CURDIR))
        export HOSTCC := gcc
        include $(srctree)/make/Kbuild.include
    else ifeq ($(bool_use_sylin_exlin), y)#        # Export val_superuser now because we can't do it later
        $(info $(shell $(subst @echo, echo, $(call heading, info, Exporting superuser variable))))
        export val_superuser := sudo
    endif
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
	@echo -e ""
	@width=$$(tput cols); \
	for i in $$(seq 1 $$width); do \
	    printf "$(col_DONE)-"; \
	done; \
	printf "$(col_NORMAL)\n"
	@echo -e ""
	$(call ok,    // The iso is now ready. You can find it in '$(bin_dir_iso)' //    )
	$(call ok,    // Use 'make run' if you want to run this iso image now  //    )
	$(call ok,    // Use 'make runs' if you want to automatically open the iso in $(util_vm) //    )
	@echo -e ""

# --- Main compiling procedure --- #
.PHONY: main
main:
    ifneq ($(shell [ -f ".config" ] && echo y), y)
	    $(call warn, .config file is not found. Settings in menuconfig may not reflect the current settings.)
    endif
    ifeq ($(shell [ -f ".config.mk" ] && echo y), y)
	    @echo -e "$(col_TRUE)               !**              Configuration file found              **!               $(col_NORMAL)"
    else
	    @echo -e "$(col_FALSE)               !**           Configuration file isn't found           **!               $(col_NORMAL)"
	    $(call stop, .config.mk is not found. Run 'make menuconfig', save it & try again)
    endif
    ifeq ($(shell [ -f "$(bin_dir_iso)" ] && echo y), y)
        ifeq ($(bool_do_timeout), y)
	        $(call true, Wait a minute, bool_do_timeout)
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
	        $(call false, Wait a minute, bool_do_timeout)
        endif
    endif
#  -- Compare MRain version --  #
	$(call stat, Comparing MarkedRain version)
    ifneq ($(shell "$(src_dir_scripts)/get_var.sh" "ver_previous_mrain-sys" "$(src_dir_conf)/variables.txt"), $(MRAIN_VERSION))
	    $(call heading, info, Version change detected)
	    $(eval bool_ver_change := y)
    endif
#  -- Clean --  #
	$(call cleancode)
#  -- Directories --  #
	$(call heading, info, $(col_TRUE)Creating image directory)
	$(Q)mkdir -p "$(bin_dir)" "$(bin_dir_tmp)"
#  -- Syslinux check 1 --  #
    ifeq ($(bool_use_sylin_exlin), y)
	    $(call true, BootSyslinux, bool_use_sylin_exlin)
	    $(call heading, main, Creating new disc image with syslinux as bootloader)
	    $(call heading, sub, Creating an empty file ($(val_dev_iso_size)MB))
	    $(Q)truncate -s $(val_dev_iso_size)M "$(bin_dir_iso)" $(OUT)
	    $(call heading, sub, Creating an ext4 filesystem)
	    $(Q)mkfs.ext4 "$(bin_dir_iso)" $(OUT)
	    $(call heading, imp, From this point onward you may receive more requests for admin privileges)
	    $(call heading, sub, Mounting iso image to '$(bin_dir_tmp)')
	    $(Q)sudo mount "$(bin_dir_iso)" "$(bin_dir_tmp)" $(OUT)
    else
	    $(call false, BootSyslinux, bool_use_sylin_exlin)
    endif
	$(call heading, main, Creating system directories)
	$(Q)"$(src_dir_scripts)/mk_sys_dir.sh" "$(src_dir_conf)/dir.txt" "$(bin_dir_tmp)"
#  -- Buildroot --  #
	@echo -e ""
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
	            $(MAKE) -C "$(src_dir_buildroot)" "$${val_temp2}-reconfigure"; \
	            continue; \
	        fi; \
	        echo -en "$(col_FALSE)[Version changed] $(col_INFO)Do you want to re-compile package '$$val_temp2'? $(col_NORMAL)[$(col_DONE)[Y]es$(col_NORMAL)/$(col_FALSE)[N]o$(col_NORMAL)/$(col_INFO)[A]ll$(col_NORMAL)]"; \
	        while true; do \
	            read choice; \
	            if [ "$$choice" = "N" ] || [ "$$choice" = "n" ]; then \
	                break; \
	            elif [ "$$choice" = "Y" ] || [ "$$choice" = "y" ] || [ "$$choice" = "A" ] || [ "$$choice" = "a" ]  ; then \
	                $(subst @echo, echo, $(call heading, sub, Re-making package: $$val_temp2)); \
	                $(MAKE) -C "$(src_dir_buildroot)" "$${val_temp2}-reconfigure"; \
	                echo > .recombr; \
	                if [ "$$choice" = "A" ] || [ "$$choice" = "a" ] ; then \
	                    repeat=y; \
	                fi; \
	                break; \
	            fi; \
	            echo -en "$(col_FALSE)Invalid option. Available options: $(col_NORMAL)[$(col_DONE)[Y]es$(col_NORMAL)/$(col_FALSE)[N]o$(col_NORMAL)/$(col_INFO)[A]ll$(col_NORMAL)]"; \
	        done; \
	    done; \
	fi
    ifneq ($(shell [ -f "$(src_dir_buildroot)/output/images/rootfs.tar" ] && echo y), y)
	    $(call heading, sub, rootfs.tar does not exist; making Buildroot)
	    $(Q)$(MAKE) -C "$(src_dir_buildroot)" $(OUT) || exit 1
	    $(call save_hash, hash_buildroot, $(src_dir_buildroot)/.config)
	    $(eval bool_do_update_count := y)
	    $(eval val_changes += rootfs.tar did not exist\n)
    else
	    $(call heading, sub, Comparing .config hash)
        ifneq ($(shell "$(src_dir_scripts)/get_var.sh" "hash_buildroot" "$(src_dir_conf)/variables.txt"),$(shell $(call get_hash, $(src_dir_buildroot)/.config)))
	        $(call heading, sub, Hashes didn't match; making Buildroot)
	        $(Q)$(MAKE) -C "$(src_dir_buildroot)" $(OUT) || exit 1
	        $(call save_hash, hash_buildroot, $(src_dir_buildroot)/.config)
	        $(eval bool_do_update_count := y)
	        $(eval val_changes += Buildroot's configuration (.config) changed\n)
        else
            # Invoke BR make if version changed & all other checks are clear
            ifeq ($(shell [ -f ".recombr" ] && echo y), y)
	            $(call heading, sub, Making Buildroot (version changed))
	            $(MAKE) -C "$(src_dir_buildroot)" $(OUT) || exit 1
            endif
        endif
    endif
    ifeq ($(shell [ -f ".recombr" ] && echo y), y)
	    $(Q)rm ".recombr"
    endif
	$(call heading, sub, Extracting rootfs archive to '$(bin_dir_tmp)')
	$(Q)pv -i 0.01 "$(src_dir_buildroot)/output/images/rootfs.tar" | $(val_superuser) tar -xf "-" -C "$(bin_dir_tmp)"
#  -- Kernel --  #
	@echo -e ""
	$(call heading, main, Adding the linux kernel)
    ifneq ($(shell [ -f "$(src_dir_linux)" ] && echo y), y)
	    $(call stop, Kernel file doesn't exist in $(src_dir_linux). Ensure you gave the correct path to it by running menuconfig.)
    else
	    $(call heading, sub, Comparing kernel hash)
        ifneq ($(shell "$(src_dir_scripts)/get_var.sh" "hash_kernel" "$(src_dir_conf)/variables.txt"), $(shell $(call get_hash, $(src_dir_linux))))
	        $(call save_hash, hash_kernel, $(src_dir_linux))
	        $(eval bool_do_update_count := y)
	        $(eval val_changes += Kernel file changed\n)
        endif
    endif
	$(call heading, sub, Copying kernel as '$(bin_dir_tmp)$(sys_dir_linux)')
	$(Q)$(val_superuser) cp "$(src_dir_linux)" "$(bin_dir_tmp)$(sys_dir_linux)" $(OUT)
#  -- Initramfs --  #
	@echo -e ""
	$(call heading, main, Adding initramfs)
	$(call heading, sub, Checking hashes and file existance)
    ifneq ($(shell [ -f "$(src_dir_initramfs)/init.cpio.zst" ] && [ "$(shell $(call get_hash_dir, $(src_dir_initramfs)/source))" = "$(shell "$(src_dir_scripts)/get_var.sh" "hash_initramfs" "$(src_dir_conf)/variables.txt")" ] && echo y),y)
	    $(call heading, sub, Creating/re-creating init.cpio.zst)
	    $(Q)cd "$(src_dir_initramfs)/source"; \
	    find . | cpio -o -H newc --quiet | pv -i 0.01 -s $$(du -sb . | awk '{print $$1}') | zstd --force --quiet -o "../init.cpio.zst"
	    $(call save_hash_dir, hash_initramfs, $(src_dir_initramfs)/source)
	    $(eval bool_do_update_count := y)
	    $(eval val_changes += init.cpio.zst did not exist or hash of source/ changed\n)
    endif
	$(call heading, sub, Copying init.cpio.zst as '$(bin_dir_tmp)$(sys_dir_initramfs)')
	$(Q)$(val_superuser) cp "$(src_dir_initramfs)/init.cpio.zst" "$(bin_dir_tmp)$(sys_dir_initramfs)"
#  -- Applications --  #
	@echo -e ""
	$(call heading, main, Installing applications)
    ifneq ($(app_dir_ohmyzsh),)
	    $(call heading, main, Installing OhMyZSH)
	    $(Q)$(val_superuser) ZSH="$(app_dir_ohmyzsh)" src_dir_ohmyzsh="$(val_current_dir)/$(src_dir_ohmyzsh)" sh cd $(bin_dir_tmp) && $(src_dir_ohmyzsh)/tools/install.sh $(OUT)
    endif
#  -- Finalization --  #
	@echo -e ""
	$(call heading, main, Doing finalization procedures)
#   - Convenient aliases & Functions -   #
    ifeq ($(bool_include_aliases), y)
	    $(call heading, sub, Convenient aliases & functions)
	    $(call heading, sub2, Functions)
	    $(Q)echo -e "\
	    marked-rain-list-not-hidden-function() { \n\
	        # Check if .hidden exists \n\
	        if [ -f .hidden ]; then \n\
	            # Get list of files, replace spaces with '\\\\ ', and convert to hex \n\
	            list=\$$(command ls -F | sed 's/ /\\\\\\\\ /g' | xxd -p | tr -d '\\\\n') \n\
	            list=\"0a\$$list\" \n\
	    \n\
	            # Read .hidden line-by-line \n\
	            while IFS= read -r word; do \n\
	                # Convert word to hex \n\
	                word=\$$(printf \"%s\" \"\$$word\" | xxd -p | tr -d '\\\\n') \n\
	    \n\
	                # Check if word exists in list (might save some cycles) \n\
	                if [[ \"\$$list\" =~ \"0a\$$word\" ]]; then \n\
	                    # Remove patterns \n\
	                    for symbol in '2a' '2f' '3d' '3e' '40' '7c'; do \n\
	                        list=\"\$${list//0a\$$word\$$symbol/}\" \n\
	                    done \n\
	                fi \n\
	            done < .hidden \n\
	    \n\
	            # Convert hex to ASCII and replace newlines with spaces & remove '/' \n\
	            list=\$$(printf \"%s\" \"\$$list\" | xxd -r -p | tr '\\\\n' ' ' | tr -d '/') \n\
	    \n\
	            # Execute the command with the modified list \n\
	            eval command ls \"\$$@\" -d \$$list \n\
	        else \n\
	            command ls \"\$$@\" \n\
	        fi \n\
	    }\n"\
	    | sed 's/^    //' \
	    | $(val_superuser) tee -a "$(bin_dir_tmp)/etc/profile" $(OUT)
	    $(call heading, sub2, Command aliases)
	    $(Q)echo -e "\
	    # Great command aliases \n\
	    alias cd.='cd .' \n\
	    alias cd..='cd ..' \n\
	    alias cls='clear' \n\
	    alias copy='cp' \n\
	    alias del='rm -i' \n\
	    alias dir='ls -l' \n\
	    alias egrep='egrep --color=auto' \n\
	    alias fgrep='fgrep --color=auto' \n\
	    alias grep='grep --color=auto' \n\
	    alias l='ls -CF' \n\
	    alias la='ls -A' \n\
	    alias ll='ls -alF' \n\
	    alias ls='marked-rain-list-not-hidden-function --color=auto' \n\
	    alias md='mkdir' \n\
	    alias move='mv' \n\
	    alias pause='read' \n\
	    alias rd='rm -ri' \n\
	    alias vdir='vdir --color=auto' \n"\
	    | sed 's/^    //' \
	    | $(val_superuser) tee -a "$(bin_dir_tmp)/etc/profile" $(OUT)
    endif
#   - zsh conf -   #
	$(call heading, sub, Zsh config)
	$(Q)echo "[[ -f /etc/profile ]] && source /etc/profile" | $(val_superuser) tee -a "$(bin_dir_tmp)/etc/zshenv" $(OUT)
#   - GNU/Grub conf -   #
	$(call heading, sub, Grub boot config)
	$(Q)echo -e "\
	default=$(val_grub-boot_default) \n\
	timeout=$(val_grub-boot_timeout) \n\
	gfxpayload=$(val_grub-boot_resolution) \n\
	\n\
	menuentry \"$(val_grub-entry-one_name)\" { \n\
	    linux \"$(sys_dir_linux)\" root=$(val_grub-entry-one_li_root) $(val_grub-entry-one_li_params) \n\
	    initrd \"$(sys_dir_initramfs)\" \n\
	}\n"\
	| $(val_superuser) tee "$(bin_dir_tmp)/boot/grub/grub.cfg" $(OUT)
#   - Syslinux conf -   #
	$(call heading, sub, Syslinux config)
	$(Q)echo -e "\
	DEFAULT $(val_grub-boot_default) \n\
	PROMPT 1" \
	| $(val_superuser) tee $(bin_dir_tmp)/boot/syslinux/syslinux.cfg $(OUT)
	$(Q)if [ $(val_grub-boot_timeout) -gt 0 ]; then \
	    $(val_superuser) bash -c 'echo "TIMEOUT $(val_grub-boot_timeout)0" >> $(bin_dir_tmp)/boot/syslinux/syslinux.cfg'; \
	else \
	    $(val_superuser) bash -c 'echo "TIMEOUT 01" >> $(bin_dir_tmp)/boot/syslinux/syslinux.cfg'; \
	fi
	$(Q)echo -e "\
	LABEL $(val_grub-boot_default) \n\
	    MENU LABEL $(val_grub-entry-one_name) \n\
	    KERNEL \"$(sys_dir_linux)\" \n\
	    INITRD \"$(sys_dir_initramfs)\" \n\
	    APPEND root=$(val_grub-entry-one_li_root) $(val_grub-entry-one_li_params) vga=$(val_sylin-entry-one_li_vga_mode)\n" \
	| $(val_superuser) tee -a "$(bin_dir_tmp)/boot/syslinux/syslinux.cfg" $(OUT)
#  -- Installing bootloaders --  #
#   - Syslinux -   #
    ifeq ($(bool_use_sylin_exlin), y)
	    @echo -e ""
	    $(call heading, main, Installing syslinux to the image)
	    $(Q)sudo extlinux --install "$(bin_dir_tmp)" $(OUT)
	    $(call heading, sub, Unmounting '$(bin_dir_tmp)')
	    $(Q)sudo umount "$(bin_dir_tmp)" $(OUT)
    else
#   - GNU/Grub -   #
	    @echo -e ""
	    $(call heading, main, Creating new disc image with GRUB)
	    $(Q)grub-mkrescue -o "$(bin_dir_iso)" "$(bin_dir_tmp)" $(OUT)
    endif
    # Makefile's 'ifeq' conditions ain't working here for some reason
	$(Q)if [ "$(bool_ver_change)" = "y" ]; then \
	    $(subst @echo, echo, $(call heading, info, Saving version: $(MRAIN_VERSION))); \
	    "$(src_dir_scripts)/set_var.sh" "ver_previous_mrain-sys" "$(MRAIN_VERSION)" "$(src_dir_conf)/variables.txt"; \
	fi
	$(Q)if [ "$(bool_do_update_count)" = "y" ] || [ "$(update)" = "true" ]; then \
	    echo -e "$(col_TRUE)Summary of items changed"; \
	    echo -e "$(col_TRUE)--------------------------$(col_NORMAL)"; \
	    echo -en "$(val_changes)"; \
	    if [ "$(update)" = "true" ]; then \
	        echo -e "$(col_INFO)Variable 'update' is set to true."; \
	    fi; \
	    "$(src_dir_scripts)/count_increment.sh" "latest_next" "$(src_dir_conf)/bcount.txt"; \
	fi
	@echo -e ""
	$(call heading, info, $(col_FALSE)Cleaning temporary files)
	$(Q)rm -rf "$(bin_dir_tmp)/*"

# --- Run --- #
.PHONY: run runs
run:
    ifeq ($(shell [ -f "$(bin_dir_iso)" ] && echo y), y)
	    @echo -e ""
	    $(call ok,    // Now running '$(bin_dir_iso)' using '$(util_vm)' and parameters '$(shell echo -n $(util_vm_params))' //    )
	    $(Q)"$(util_vm)" $(shell echo -n $(util_vm_params))
    else
	    $(call stop, Supplied file '$(bin_dir_iso)' doesn't exist. Make sure you ran 'make' and check if the file specified in bin_dir_iso is correct.)
    endif
	@echo -e ""

runs: main run

# --- Clean --- #
.PHONY: clean
clean:
	$(call cleancode)

define cleancode
	$(Q)if mountpoint -q "$(bin_dir_tmp)"; then \
	    $(subst @echo, echo, $(call heading, info, $(col_FALSE)Unmounting '$(bin_dir_tmp)')); \
		sudo umount "$(bin_dir_tmp)" $(OUT) || exit 1; \
	fi; \
	$(subst @echo, echo, $(call heading, info, $(col_FALSE)Deleting directories and image)); \
	rm -rf "$(bin_dir_tmp)" "$(bin_dir_iso)" "$(bin_dir)"
endef

# --- Clean all stuff --- #
.PHONY: cleanall
cleanall:
	@echo -e ""
	$(call warn, Doing 'cleanall' will run clean on ALL of the source files and may take longer to compile.)
	@echo -e ""
	@echo -e "$(col_INFO)  Press "Y" and enter to continue, any other key will terminate.$(col_NORMAL)"
	$(Q)read choice; \
	if [ "$$choice" = "Y" ] || [ "$$choice" = "y" ]; then \
	    $(subst @if, if, $(call cleancode)); \
	    $(subst @echo, echo, $(call heading, info, $(col_FALSE)Cleaning buildroot)); \
	    $(MAKE) -C "$(src_dir_buildroot)" clean $(OUT) || exit 1; \
	    echo -e ""; \
	    $(subst @echo, echo, $(call heading, info, $(col_FALSE)Removing preinit binary)); \
	    rm $(src_dir_preinit)/preinit; \
	    echo -e ""; \
	    $(subst @echo, echo, $(call ok,  Done. Run 'make' to re-compile. Be prepared to wait a long time.  )); \
	    echo -e ""; \
	else \
	    $(subst @echo, echo, $(call ok,  Cancelled.  )); \
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
