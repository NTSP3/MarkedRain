define get_hash
	if [ -f "$(strip $(1))" ]; then \
	    shasum "$(strip $(1))" | cut -d ' ' -f 1; \
	fi
endef

define get_hash_dir
	if [ -d "$(strip $(1))" ]; then \
	    find "$(strip $(1))" -type f -exec stat --format="%s %Y %n" {} + | sort | shasum | cut -d ' ' -f 1; \
	fi
endef

define save_hash
	@$(call inf, Saving hash of file '$(strip $(2))' as '$(strip $(1))=')
	$(Q)"$(SCRIPTS)/set_var.sh" "$(strip $(1))" `$(call get_hash, $(2))` "$(CONF)/hashes.txt"
endef

define save_hash_dir
	@$(call inf, Saving hash of directory '$(strip $(2))' as '$(strip $(1))=')
	$(Q)"$(SCRIPTS)/set_var.sh" "$(strip $(1))" `$(call get_hash_dir, $(2))` "$(CONF)/hashes.txt"
endef

define cleancode
    $(S_CMD) heading "Cleaning previous files"; \
	if mountpoint -q "$(bin_dir_tmp)"; then \
	    $(S_CMD) sub "Unmounting image"; \
    	sudo umount "$(bin_dir_tmp)"; \
	fi; \
	$(S_CMD) sub "Deleting directories and image"; \
	rm -rf "$(bin_dir_tmp)" "$(bin_dir)/boot.iso" "$(bin_dir)"/* "$(bin_dir)"
endef

define initialize
	$(call heading, Initializing building environment)
	$(call sub, Setting up temporary directories)
	$(Q)mkdir -p "/dev/shm/mrain-bin"
	$(Q)ln -s /dev/shm/mrain-bin "$(bin_dir)"
	$(Q)mkdir -p "$(bin_dir_tmp)" "$(bin_dir_tmp_squashfs)" "$$HOME"
	$(call sub, Creating system directories)
	$(Q)mkdir -p "$(bin_dir_tmp)/boot" "$(bin_dir_tmp)/boot/grub" "$(bin_dir_tmp)/dev"
	$(Q)"$(SCRIPTS)/mk_sys_dir.sh" "$(CONF)/dir.txt" "$(bin_dir_tmp_squashfs)"
endef

define buildroot_packages_to_be_remade
	$(Q)if [ "$(bool_ver_change)" = "y" ] && [ "$(strip $(val_remake_br_pack))" != "" ]; then \
	    val_temp="$(val_remake_br_pack)"; \
	    for val_temp2 in $$val_temp; do \
	        if [ "$$repeat" = "y" ]; then \
	            $(subst @echo, echo, $(call sub, Re-making package: $$val_temp2)); \
	            fakeroot $(MAKE) -C "$(src_dir_buildroot)" "$${val_temp2}-reconfigure"; \
	            continue; \
	        fi; \
	        echo -n "$(col_FALSE)[Version changed] $(col_INFO)Do you want to re-compile package '$$val_temp2'? $(col_NORMAL)[$(col_DONE)[Y]es$(col_NORMAL)/$(col_FALSE)[N]o$(col_NORMAL)/$(col_INFO)[A]ll$(col_NORMAL)]"; \
	        while true; do \
	            read choice; \
	            if [ "$$choice" = "N" ] || [ "$$choice" = "n" ]; then \
	                break; \
	            elif [ "$$choice" = "Y" ] || [ "$$choice" = "y" ] || [ "$$choice" = "A" ] || [ "$$choice" = "a" ]  ; then \
	                $(subst @echo, echo, $(call sub, Re-making package: $$val_temp2)); \
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
endef

#
# run_qemu loads up terminal and runs Qemu (or the one specified in util_vm)
#
ifeq ($(bool_serial_in_new_term),y)
define run_qemu
	Logfile="$$(mktemp)"; \
	("$(util_vm)" $(util_vm_params) 2>&1 | tee "$$Logfile") $(OUT) & \
	Qemu_Process_ID=$$!; \
	while ! grep -q "char device redirected to" "$$Logfile"; do \
	    sleep 0.1; \
	done; \
	SERIAL_DEVICE=$$(grep "char device redirected to" "$$Logfile" | sed 's/.*redirected to \(.*\) (label.*$$/\1/'); \
	sleep 1; \
	if [ ! "$$(command -v screen)" ]; then \
	    $(S_CMD) error "Application 'screen' not installed!"; \
	    exit; \
	else \
	    $(call qemu_run_serial_terminal); \
	fi; \
	while kill -0 "$$Qemu_Process_ID" 2>/dev/null; do \
	    sleep 1; \
	done; \
	if kill -0 "$$Qemu_Process_ID" 2>/dev/null; then \
	    kill "$$Qemu_Process_ID"; \
	fi; \
	if kill -0 "$$Console_Process_ID" 2>/dev/null; then \
	    kill "$$Console_Process_ID"; \
	fi
endef
else
define run_qemu
	"$(util_vm)" $(util_vm_params)
endef
endif

#
# qemu_run_serial_terminal finds and loads appropriate terminal for use as serial console
#

define qemu_run_serial_terminal
	if [ "$(bool_serial_x-terminal-emulator)" = "y" ] && [ "$$(command -v x-terminal-emulator)" ]; then \
	    x-terminal-emulator -T "Cereal console" -e "socat -,raw,echo=0 '$$SERIAL_DEVICE'" & \
	    Console_Process_ID=$$!; \
	elif [ "$(bool_serial_xterm)" = "y" ] && [ "$$(command -v xterm)" ]; then \
	    xterm -T "Cereal console" -e "socat -,raw,echo=0 '$$SERIAL_DEVICE'" & \
	    Console_Process_ID=$$!; \
	elif [ "$(bool_serial_gnome-terminal)" = "y" ] && [ "$$(command -v gnome-terminal)" ]; then \
	    gnome-terminal --title="Cereal console" -- bash -c "socat -,raw,echo=0 '$$SERIAL_DEVICE'" & \
	    Console_Process_ID=$$!; \
	elif [ "$(bool_serial_konsole)" = "y" ] && [ "$$(command -v konsole)" ]; then \
	    konsole --hold --new-tab -p tabtitle="Cereal console" -e "socat -,raw,echo=0 '$$SERIAL_DEVICE'" & \
	    Console_Process_ID=$$!; \
	else \
	    $(S_CMD) error "Suitable terminal emulators not found. Either install the terminal you chose, or choose another terminal that's available"; \
	    exit; \
	fi
endef