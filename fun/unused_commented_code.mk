unused_commented_code:
# Following stuff is commented code not available in Makefile.old that I put here because I feel like it.
# Everything below the first two lines of a commented section is the original commented stuff.
# Eg: "Section: <section> \n"

# Section: "config" & "%config" after line "$(MAKE) $(build)=make/kconfig $@ --no-print-directory":
#
#       MOVED TO MCONF.C:
#       @if [ -f ".config" ]; then \
#           echo "$(col_INFO)    // Generating '.config.mk' from '.config' //$(col_NORMAL)\n"; \
#           sed -n 's/^CONFIG_\(.*\)=\(\"\(.*\)\"\|\(.*\)\)/\1=\3\4/p' .config > .config.mk; \
#           if grep -q '^syslinux-vga_' .config.mk; then \
#               sed -n 's/^syslinux-vga_\([0-9]*\)=.*/val_sylin-entry-one_li_vga_mode=\1/p' .config.mk >> .config.mk; \
#           else \
#               echo "val_sylin-entry-one_li_vga_mode=792" >> .config.mk; \
#           fi; \
#           if ! grep -q '^val_grub-boot_resolution' .config.mk; then \
#               echo "val_grub-boot_resolution=1024x768" >> .config.mk; \
#           fi; \
#       fi

# Section: "init" after line "@echo "$(col_INFO)               !**          Checking variable 'EXTRAVERSION'          **!               $(col_NORMAL)"":
#
#    ifeq ($(shell echo $(VERSION) | grep -Eq '^[0-9]+$$' && echo 1 || echo 0), 0)
#	    @echo "$(col_FALSE)  Variable 'VERSION' expected numeric value, but it's nothing like that."
#	    @echo "  Contents of the variable at this time {"
#	    @echo "$(VERSION)"
#	    @echo "  }"
#	    @echo "  Using value '0' instead - please verify config file using menuconfig.\n$(col_NORMAL)"
#	    $(eval VERSION = 0)
#    endif
#    ifeq ($(shell echo $(PATCHLEVEL) | grep -Eq '^[0-9]+$$' && echo 1 || echo 0), 0)
#	    @echo "$(col_FALSE)  Variable 'PATCHLEVEL' expected numeric value, but it's nothing like that."
#	    @echo "  Contents of the variable at this time {"
#	    @echo "$(PATCHLEVEL)"
#	    @echo "  }"
#	    @echo "  Using value '0' instead - please verify config file using menuconfig.\n$(col_NORMAL)"
#	    $(eval PATCHLEVEL = 0)
#    endif
#    ifeq ($(shell echo $(SUBLEVEL) | grep -Eq '^[0-9]+$$' && echo 1 || echo 0), 0)
#	    @echo "$(col_FALSE)  Variable 'SUBLEVEL' expected numeric value, but it's nothing like that."
#	    @echo "  Contents of the variable at this time {"
#	    @echo "$(SUBLEVEL)"
#	    @echo "  }"
#	    @echo "  Using value '0' instead - please verify config file using menuconfig.\n$(col_NORMAL)"
#	    $(eval SUBLEVEL = 0)
#    endif