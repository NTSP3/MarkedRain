savedcmd_make/kconfig/lxdialog/yesno.o := gcc -Wp,-MMD,make/kconfig/lxdialog/.yesno.o.d   -D_GNU_SOURCE -I/usr/include/ncursesw -c -o make/kconfig/lxdialog/yesno.o make/kconfig/lxdialog/yesno.c

source_make/kconfig/lxdialog/yesno.o := make/kconfig/lxdialog/yesno.c

deps_make/kconfig/lxdialog/yesno.o := \
  make/kconfig/lxdialog/dialog.h \
  /usr/include/ncursesw/ncurses.h \
  /usr/include/ncursesw/ncurses_dll.h \
  /usr/include/ncursesw/unctrl.h \
  /usr/include/ncursesw/curses.h \

make/kconfig/lxdialog/yesno.o: $(deps_make/kconfig/lxdialog/yesno.o)

$(deps_make/kconfig/lxdialog/yesno.o):
