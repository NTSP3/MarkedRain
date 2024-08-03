savedcmd_make/kconfig/lxdialog/util.o := gcc -Wp,-MMD,make/kconfig/lxdialog/.util.o.d   -D_GNU_SOURCE -I/usr/include/ncursesw -c -o make/kconfig/lxdialog/util.o make/kconfig/lxdialog/util.c

source_make/kconfig/lxdialog/util.o := make/kconfig/lxdialog/util.c

deps_make/kconfig/lxdialog/util.o := \
  make/kconfig/lxdialog/dialog.h \
  /usr/include/ncursesw/ncurses.h \
  /usr/include/ncursesw/ncurses_dll.h \
  /usr/include/ncursesw/unctrl.h \
  /usr/include/ncursesw/curses.h \

make/kconfig/lxdialog/util.o: $(deps_make/kconfig/lxdialog/util.o)

$(deps_make/kconfig/lxdialog/util.o):
