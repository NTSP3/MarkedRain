# These functions will check if the hash of the program's source directory
# matches the hash saved in hashes.txt. If fail, then it re-compiles and
# saves the hash.
define application_compiler
	$(call main_compile)
	$(call save_hash_dir,$(1),$(2))
	$(eval bool_do_update_count := y)
	$(eval val_changes += Application '$(basename $(notdir $(2)))' is added or modified\n)
endef

define application_installer
	$(eval stored_hash = $(shell $(S_CMD) get hash_$(1) $(CURDIR)/$(CONF)/hashes.txt))
	$(eval folder_hash = $(shell $(call get_hash_dir,$(2))))
	$(if $(filter $(stored_hash),$(folder_hash)),,\
	    $(call application_compiler,hash_$(1),$(2)))

	$(call main_install)
endef

# This function will:
#  1. Get the filename part of .mk file (eg. 'ohmyzsh' for 'ohmyzsh.mk')
#  2. Checks if the variable 'app_dir_<filename>' (eg. 'app_dir_ohmyzsh') is not empty:
#     + TRUE (variable NOT empty): Execute definition 'application_installer',
#                                  which will execute 'main_compile' & 'main_install'
#                                  from the .mk file.
#     + FALSE (variable empty): Do not do anything.
define application_condition
	$(eval FILENAME := $(basename $(notdir $(1))))
	$(if $(strip $(app_dir_$(FILENAME))),$(eval include $(1)) $(call application_installer,app_dir_$(FILENAME),$(basename $(1))))
endef

# This function will execute application_condition for every .mk file found in src_dir_apps
define applications
	$(call heading, Installing applications)
	$(foreach file,$(wildcard $(src_dir_apps)/*.mk),$(call application_condition,$(file)))
endef
