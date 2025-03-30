savedcmd_make/kconfig/lxdialog/inputbox.o := cc -Wp,-MMD,make/kconfig/lxdialog/.inputbox.o.d   -D_GNU_SOURCE -I/usr/include/ncursesw -c -o make/kconfig/lxdialog/inputbox.o make/kconfig/lxdialog/inputbox.c

source_make/kconfig/lxdialog/inputbox.o := make/kconfig/lxdialog/inputbox.c

deps_make/kconfig/lxdialog/inputbox.o := \
  make/kconfig/lxdialog/dialog.h \
  /usr/include/ncursesw/ncurses.h \
  /usr/include/ncursesw/ncurses_dll.h \
  /usr/include/ncursesw/unctrl.h \
  /usr/include/ncursesw/curses.h \

make/kconfig/lxdialog/inputbox.o: $(deps_make/kconfig/lxdialog/inputbox.o)

$(deps_make/kconfig/lxdialog/inputbox.o):
