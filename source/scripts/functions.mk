define get_hash
	shasum "$(strip $(1))" | cut -d ' ' -f 1
endef

define get_hash_dir
	find "$(strip $(1))" -type f -exec stat --format="%s %Y %n" {} + | sort | shasum | cut -d ' ' -f 1
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
