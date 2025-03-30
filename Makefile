# Makefile re-written for MarkedRain: 14th March 2025 8:00PM
# Try to be neat this time

# ---[ Makefile Setup ] --- #
ifeq ($(wildcard Default.in),)
    $(error Required default settings 'Default.in' not found. Please ensure it exists before continuing)
endif

# Default.in contains default settings for use
# with the Makefile.
include Default.in
# The scripts.mk file contains definitions that
# the Makefile can use later.
include $(SCRIPTS)/scripts.mk

ifeq ($(wildcard $(USER_CONFIG)),)
    $(info $(shell $(call stop, Please run 'make menuconfig' before running 'make')))
endif
# The USER_CONFIG file (.config) contains settings
# that can be changed via menuconfig.
include $(USER_CONFIG)

# Exports color settings to makefile shell
export col_HEADING col_SUBHEADING col_INFOHEADING col_INFO col_TRUE col_FALSE col_DONE col_ERROR col_IMP col_NORMAL

all:
	echo Hi
