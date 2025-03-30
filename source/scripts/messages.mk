define stop
	$(S) error "$(strip $(1))"
	$(error $(strip $(1)))
endef
