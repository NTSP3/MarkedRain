savedcmd_make/kconfig/util.o := cc -Wp,-MMD,make/kconfig/.util.o.d    -c -o make/kconfig/util.o make/kconfig/util.c

source_make/kconfig/util.o := make/kconfig/util.c

deps_make/kconfig/util.o := \
  make/kconfig/lkc.h \
    $(wildcard include/config/prefix) \
  make/kconfig/expr.h \
  make/kconfig/list.h \
  make/kconfig/lkc_proto.h \

make/kconfig/util.o: $(deps_make/kconfig/util.o)

$(deps_make/kconfig/util.o):
