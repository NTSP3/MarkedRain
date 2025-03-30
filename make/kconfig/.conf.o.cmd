savedcmd_make/kconfig/conf.o := cc -Wp,-MMD,make/kconfig/.conf.o.d    -c -o make/kconfig/conf.o make/kconfig/conf.c

source_make/kconfig/conf.o := make/kconfig/conf.c

deps_make/kconfig/conf.o := \
  make/kconfig/lkc.h \
    $(wildcard include/config/prefix) \
  make/kconfig/expr.h \
  make/kconfig/list.h \
  make/kconfig/lkc_proto.h \

make/kconfig/conf.o: $(deps_make/kconfig/conf.o)

$(deps_make/kconfig/conf.o):
