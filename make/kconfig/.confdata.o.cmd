savedcmd_make/kconfig/confdata.o := cc -Wp,-MMD,make/kconfig/.confdata.o.d    -c -o make/kconfig/confdata.o make/kconfig/confdata.c

source_make/kconfig/confdata.o := make/kconfig/confdata.c

deps_make/kconfig/confdata.o := \
    $(wildcard include/config/FOO) \
    $(wildcard include/config/X) \
  make/kconfig/lkc.h \
    $(wildcard include/config/prefix) \
  make/kconfig/expr.h \
  make/kconfig/list.h \
  make/kconfig/lkc_proto.h \

make/kconfig/confdata.o: $(deps_make/kconfig/confdata.o)

$(deps_make/kconfig/confdata.o):
