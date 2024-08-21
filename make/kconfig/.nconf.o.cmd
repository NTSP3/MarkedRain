savedcmd_make/kconfig/nconf.o := gcc -Wp,-MMD,make/kconfig/.nconf.o.d   -D_GNU_SOURCE -I/usr/include/ncursesw -c -o make/kconfig/nconf.o make/kconfig/nconf.c

source_make/kconfig/nconf.o := make/kconfig/nconf.c

deps_make/kconfig/nconf.o := \
  make/kconfig/lkc.h \
    $(wildcard include/config/prefix) \
  make/kconfig/expr.h \
  make/kconfig/list.h \
  make/kconfig/lkc_proto.h \
  make/kconfig/nconf.h \
  /usr/include/ncursesw/ncurses.h \
  /usr/include/ncursesw/ncurses_dll.h \
  /usr/include/ncursesw/unctrl.h \
  /usr/include/ncursesw/curses.h \
  /usr/include/ncursesw/menu.h \
  /usr/include/ncursesw/eti.h \
  /usr/include/ncursesw/panel.h \
  /usr/include/ncursesw/form.h \

make/kconfig/nconf.o: $(deps_make/kconfig/nconf.o)

$(deps_make/kconfig/nconf.o):
