define stop
	@$(S_CMD) error "$(strip $(1))"
endef

define ok
	@echo '$(col_DONE)$(1)$(col_NORMAL)'
endef

define imp
	@$(S_CMD) imp "$(strip $(1))"
endef

define heading
	@$(S_CMD) heading "$(strip $(1))"
endef

define sub
	@$(S_CMD) sub "$(strip $(1))"
endef

define sub2
	@$(S_CMD) sub2 "$(strip $(1))"
endef

define inf
	@$(S_CMD) info "$(strip $(1))"
endef