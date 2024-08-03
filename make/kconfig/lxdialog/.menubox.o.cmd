savedcmd_make/kconfig/lxdialog/menubox.o := gcc -Wp,-MMD,make/kconfig/lxdialog/.menubox.o.d   -D_GNU_SOURCE -I/usr/include/ncursesw -c -o make/kconfig/lxdialog/menubox.o make/kconfig/lxdialog/menubox.c

source_make/kconfig/lxdialog/menubox.o := make/kconfig/lxdialog/menubox.c

deps_make/kconfig/lxdialog/menubox.o := \
  make/kconfig/lxdialog/dialog.h \
  /usr/include/ncursesw/ncurses.h \
  /usr/include/ncursesw/ncurses_dll.h \
  /usr/include/ncursesw/unctrl.h \
  /usr/include/ncursesw/curses.h \

make/kconfig/lxdialog/menubox.o: $(deps_make/kconfig/lxdialog/menubox.o)

$(deps_make/kconfig/lxdialog/menubox.o):
