define applications
    $(call heading, sub, Nano-X Window System)
	$(Q)cp "$(app_dir_microwindows)/bin"/* "$(bin_dir_tmp_squashfs)/bin/"
	$(call heading, sub, v86d)
	$(Q)"$(app_dir_v86d)/configure" --default $(OUT)
	$(Q)cp "$(app_dir_v86d)/v86d" "$(bin_dir_tmp_squashfs)/sbin"
endef

NULL:
