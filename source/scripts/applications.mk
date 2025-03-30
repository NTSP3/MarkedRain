define applicationsah5
	$(call heading, Installing applications)
	$(S) clone https://github.com/ghaerr/microwindows.git "$(app_dir_microwindows)"
    $(call sub, Nano-X Window System)
	$(Q)cp "$(app_dir_microwindows)/bin"/* "$(bin_dir_tmp_squashfs)/bin/"
	$(call sub, v86d)
	$(Q)"$(app_dir_v86d)/configure" --default $(OUT)
	$(Q)cp "$(app_dir_v86d)/v86d" "$(bin_dir_tmp_squashfs)/sbin"
endef

# This function will:
#  1. Get the filename part of .mk file (eg. 'ohmyzsh' for 'ohmyzsh.mk')
#  2. Checks if the variable 'app_dir_<filename>' (eg. 'app_dir_ohmyzsh') is not empty:
#     + TRUE (variable NOT empty): Execute definition 'main' from the .mk file.
#     + FALSE (variable empty): Do not do anything.
define download_and_compile_application_MAIN
	$(eval FILENAME := $(basename $(notdir $(1))))
	$(if $(strip $(app_dir_$(FILENAME))),$(eval include $(1)) $(call main))
endef

# This function will execute download_and_compile_application_MAIN for every .mk file found in src_dir_apps
define applications
	$(call heading, Installing applications)
	$(foreach file,$(wildcard $(src_dir_apps)/*.mk),$(call download_and_compile_application_MAIN,$(file)))
endef
