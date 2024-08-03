savedcmd_make/kconfig/lxdialog/textbox.o := gcc -Wp,-MMD,make/kconfig/lxdialog/.textbox.o.d   -D_GNU_SOURCE -I/usr/include/ncursesw -c -o make/kconfig/lxdialog/textbox.o make/kconfig/lxdialog/textbox.c

source_make/kconfig/lxdialog/textbox.o := make/kconfig/lxdialog/textbox.c

deps_make/kconfig/lxdialog/textbox.o := \
  make/kconfig/lxdialog/dialog.h \
  /usr/include/ncursesw/ncurses.h \
  /usr/include/ncursesw/ncurses_dll.h \
  /usr/include/ncursesw/unctrl.h \
  /usr/include/ncursesw/curses.h \

make/kconfig/lxdialog/textbox.o: $(deps_make/kconfig/lxdialog/textbox.o)

$(deps_make/kconfig/lxdialog/textbox.o):
