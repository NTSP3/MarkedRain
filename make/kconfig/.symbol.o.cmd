savedcmd_make/kconfig/symbol.o := cc -Wp,-MMD,make/kconfig/.symbol.o.d    -c -o make/kconfig/symbol.o make/kconfig/symbol.c

source_make/kconfig/symbol.o := make/kconfig/symbol.c

deps_make/kconfig/symbol.o := \
  make/kconfig/lkc.h \
    $(wildcard include/config/prefix) \
  make/kconfig/expr.h \
  make/kconfig/list.h \
  make/kconfig/lkc_proto.h \

make/kconfig/symbol.o: $(deps_make/kconfig/symbol.o)

$(deps_make/kconfig/symbol.o):
