define main
	$(S) clone https://github.com/ohmyzsh/ohmyzsh "$(app_dir_ohmyzsh)"
	$(call sub, Cloned ohmyzsh)
endef