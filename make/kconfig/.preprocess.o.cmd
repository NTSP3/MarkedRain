savedcmd_make/kconfig/preprocess.o := cc -Wp,-MMD,make/kconfig/.preprocess.o.d    -c -o make/kconfig/preprocess.o make/kconfig/preprocess.c

source_make/kconfig/preprocess.o := make/kconfig/preprocess.c

deps_make/kconfig/preprocess.o := \
  make/kconfig/list.h \
  make/kconfig/lkc.h \
    $(wildcard include/config/prefix) \
  make/kconfig/expr.h \
  make/kconfig/lkc_proto.h \

make/kconfig/preprocess.o: $(deps_make/kconfig/preprocess.o)

$(deps_make/kconfig/preprocess.o):
