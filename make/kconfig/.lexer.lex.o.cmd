savedcmd_make/kconfig/lexer.lex.o := cc -Wp,-MMD,make/kconfig/.lexer.lex.o.d   -I /mnt/personal/Applications/MRain-Linux/make/kconfig -c -o make/kconfig/lexer.lex.o make/kconfig/lexer.lex.c

source_make/kconfig/lexer.lex.o := make/kconfig/lexer.lex.c

deps_make/kconfig/lexer.lex.o := \
  make/kconfig/lkc.h \
    $(wildcard include/config/prefix) \
  make/kconfig/expr.h \
  make/kconfig/list.h \
  make/kconfig/lkc_proto.h \
  make/kconfig/parser.tab.h \

make/kconfig/lexer.lex.o: $(deps_make/kconfig/lexer.lex.o)

$(deps_make/kconfig/lexer.lex.o):
