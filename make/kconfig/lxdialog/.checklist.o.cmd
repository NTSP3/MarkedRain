savedcmd_make/kconfig/lxdialog/checklist.o := gcc -Wp,-MMD,make/kconfig/lxdialog/.checklist.o.d   -D_GNU_SOURCE -I/usr/include/ncursesw -c -o make/kconfig/lxdialog/checklist.o make/kconfig/lxdialog/checklist.c

source_make/kconfig/lxdialog/checklist.o := make/kconfig/lxdialog/checklist.c

deps_make/kconfig/lxdialog/checklist.o := \
  make/kconfig/lxdialog/dialog.h \
  /usr/include/ncursesw/ncurses.h \
  /usr/include/ncursesw/ncurses_dll.h \
  /usr/include/ncursesw/unctrl.h \
  /usr/include/ncursesw/curses.h \

make/kconfig/lxdialog/checklist.o: $(deps_make/kconfig/lxdialog/checklist.o)

$(deps_make/kconfig/lxdialog/checklist.o):
