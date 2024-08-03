savedcmd_make/kconfig/parser.tab.o := gcc -Wp,-MMD,make/kconfig/.parser.tab.o.d   -I /mnt/personal/Applications/MRain-Linux/make/kconfig -c -o make/kconfig/parser.tab.o make/kconfig/parser.tab.c

source_make/kconfig/parser.tab.o := make/kconfig/parser.tab.c

deps_make/kconfig/parser.tab.o := \
  make/kconfig/lkc.h \
    $(wildcard include/config/prefix) \
  make/kconfig/expr.h \
  make/kconfig/list.h \
  make/kconfig/lkc_proto.h \
  make/kconfig/internal.h \
  make/kconfig/parser.tab.h \

make/kconfig/parser.tab.o: $(deps_make/kconfig/parser.tab.o)

$(deps_make/kconfig/parser.tab.o):
