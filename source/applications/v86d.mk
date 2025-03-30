define main
	$(S) clone https://github.com/mjanusz/v86d.git "$(app_dir_v86d)"
	$(call sub, Compiling v86d)
	$(Q)cd "$(app_dir_v86d)"; \
	"./configure" --default $(OUT)
	$(Q)$(MAKE) -C "$(app_dir_v86d)" $(OUT)
	$(call sub, Installing v86d)
	$(Q)cp "$(app_dir_v86d)/v86d" "$(bin_dir_tmp_squashfs)/sbin"
endef