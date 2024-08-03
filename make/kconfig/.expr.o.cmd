savedcmd_make/kconfig/expr.o := gcc -Wp,-MMD,make/kconfig/.expr.o.d    -c -o make/kconfig/expr.o make/kconfig/expr.c

source_make/kconfig/expr.o := make/kconfig/expr.c

deps_make/kconfig/expr.o := \
  make/kconfig/lkc.h \
    $(wildcard include/config/prefix) \
  make/kconfig/expr.h \
  make/kconfig/list.h \
  make/kconfig/lkc_proto.h \

make/kconfig/expr.o: $(deps_make/kconfig/expr.o)

$(deps_make/kconfig/expr.o):
