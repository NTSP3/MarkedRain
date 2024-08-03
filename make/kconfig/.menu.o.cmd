savedcmd_make/kconfig/menu.o := gcc -Wp,-MMD,make/kconfig/.menu.o.d    -c -o make/kconfig/menu.o make/kconfig/menu.c

source_make/kconfig/menu.o := make/kconfig/menu.c

deps_make/kconfig/menu.o := \
  make/kconfig/lkc.h \
    $(wildcard include/config/prefix) \
  make/kconfig/expr.h \
  make/kconfig/list.h \
  make/kconfig/lkc_proto.h \
  make/kconfig/internal.h \

make/kconfig/menu.o: $(deps_make/kconfig/menu.o)

$(deps_make/kconfig/menu.o):
