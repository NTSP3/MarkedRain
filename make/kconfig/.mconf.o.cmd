savedcmd_make/kconfig/mconf.o := gcc -Wp,-MMD,make/kconfig/.mconf.o.d   -D_GNU_SOURCE -I/usr/include/ncursesw -c -o make/kconfig/mconf.o make/kconfig/mconf.c

source_make/kconfig/mconf.o := make/kconfig/mconf.c

deps_make/kconfig/mconf.o := \
  make/kconfig/lkc.h \
    $(wildcard include/config/prefix) \
  make/kconfig/expr.h \
  make/kconfig/list.h \
  make/kconfig/lkc_proto.h \
  make/kconfig/lxdialog/dialog.h \
  /usr/include/ncursesw/ncurses.h \
  /usr/include/ncursesw/ncurses_dll.h \
  /usr/include/ncursesw/unctrl.h \
  /usr/include/ncursesw/curses.h \

make/kconfig/mconf.o: $(deps_make/kconfig/mconf.o)

$(deps_make/kconfig/mconf.o):
