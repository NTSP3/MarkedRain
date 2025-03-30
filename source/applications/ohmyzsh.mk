define main
	$(S) clone https://github.com/ohmyzsh/ohmyzsh "$(app_dir_ohmyzsh)"
	$(call heading, sub, Cloned ohmyzsh)
endef