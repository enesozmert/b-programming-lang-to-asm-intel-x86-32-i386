CC      = gcc
LEX     = flex
YACC    = bison
CFLAGS  = -Wall -Wextra -Werror -g -I$(HDRDIR)
# LDFLAGS = -ly -ll -m32
LDFLAGS = -lm

SRCDIR    = src
LEXERDIR  = $(SRCDIR)/lexer
PARSERDIR = $(SRCDIR)/parser
OBJDIR    = obj
HDRDIR    = hdr
OUTDIR    = output

NAME    = $(OUTDIR)/B
SRCS    = $(wildcard $(SRCDIR)/*.c)
MAINSRC = main.c
LEXSRC  = $(LEXERDIR)/lexer.l
YACCSRC = $(PARSERDIR)/parser.y
OBJS    = $(patsubst $(SRCDIR)/%.c, $(OBJDIR)/%.o, $(SRCS)) \
          $(OBJDIR)/lex.yy.o \
          $(OBJDIR)/y.tab.o \
          $(OBJDIR)/main.o

all: $(NAME)

$(NAME): $(OBJS) | $(OUTDIR)
	$(CC) $(CFLAGS) -o $(NAME) $(OBJS) $(LDFLAGS)

$(OBJDIR)/%.o: $(SRCDIR)/%.c | $(OBJDIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJDIR)/main.o: $(MAINSRC) | $(OBJDIR)
	$(CC) $(CFLAGS) -c $(MAINSRC) -o $@

$(OBJDIR)/y.tab.o $(OBJDIR)/y.tab.h: $(YACCSRC) | $(OBJDIR)
	$(YACC) -d -o $(OBJDIR)/y.tab.c $(YACCSRC)
	$(CC) $(CFLAGS) -c $(OBJDIR)/y.tab.c -o $(OBJDIR)/y.tab.o

$(OBJDIR)/lex.yy.o: $(LEXSRC) $(OBJDIR)/y.tab.h | $(OBJDIR)
	$(LEX) --nounput -o $(OBJDIR)/lex.yy.c $(LEXSRC)
	$(CC) $(CFLAGS) -Wno-unused-function -c $(OBJDIR)/lex.yy.c -o $@

$(OBJDIR):
	@mkdir -p $(OBJDIR)

$(OUTDIR):
	@mkdir -p $(OUTDIR)

clean:
	rm -rf $(OBJDIR)

fclean: clean
	rm -f $(NAME)

re: fclean all

run: $(NAME)
	@echo "Running b-files/b.main..."
	@$(NAME) b-files/main.b

output_dir:
	@cd $(OUTDIR) && bash

ARGS ?= ""
SUDO ?= 0

.PHONY: all clean fclean re run output_dir
