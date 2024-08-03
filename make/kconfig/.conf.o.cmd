savedcmd_make/kconfig/conf.o := gcc -Wp,-MMD,make/kconfig/.conf.o.d -Wall -Wmissing-prototypes -Wstrict-prototypes -O2 -fomit-frame-pointer -std=gnu11     -c -o make/kconfig/conf.o make/kconfig/conf.c

source_make/kconfig/conf.o := make/kconfig/conf.c

deps_make/kconfig/conf.o := \
  make/kconfig/lkc.h \
    $(wildcard include/config/prefix) \
  make/kconfig/expr.h \
  make/kconfig/list.h \
  make/kconfig/lkc_proto.h \

make/kconfig/conf.o: $(deps_make/kconfig/conf.o)

$(deps_make/kconfig/conf.o):
