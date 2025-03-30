savedcmd_make/basic/fixdep := cc -Wp,-MMD,make/basic/.fixdep.d     -o make/basic/fixdep make/basic/fixdep.c  

source_make/basic/fixdep := make/basic/fixdep.c

deps_make/basic/fixdep := \
    $(wildcard include/config/HIS_DRIVER) \
    $(wildcard include/config/MY_OPTION) \
    $(wildcard include/config/FOO) \

make/basic/fixdep: $(deps_make/basic/fixdep)

$(deps_make/basic/fixdep):
