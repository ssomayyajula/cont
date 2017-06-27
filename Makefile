# Source files
SRCDIR=src
BUILDDIR=_build

# Project dependencies
DEPS=core

# Compiler and linker flags
CC=ocamlfind ocamlc
CFLAGS=-linkpkg -thread -package $(DEPS)

# Modules in dependency order and project name
NAME=cont
MODULES=Cont
MAIN=main

SIGS=$(addprefix $(SRCDIR)/, $(addsuffix .mli, $(MODULES)))
IMPLS=$(addprefix $(SRCDIR)/, $(addsuffix .ml, $(MODULES)))
CMIS=$(addprefix $(BUILDDIR)/, $(addsuffix .cmi, $(MODULES)))
CMOS=$(addprefix $(BUILDDIR)/, $(addsuffix .cmo, $(MODULES)))
LIB=$(NAME).cma

# Make both executable and toplevel
all: exe toplevel

# Make executable
exe: $(LIB)
	$(CC) -c -o $(BUILDDIR)/$(MAIN).cmo $(CFLAGS) $(SRCDIR)/$(MAIN).ml
	$(CC) -o $(NAME) $(CFLAGS) $(BUILDDIR)/$(MAIN).cmo

# Make just the library
lib: $(LIB)

$(BUILDDIR):
	mkdir _build

# Make all compiled interfaces
$(CMIS): $(BUILDDIR) $(SIGS)
	$(foreach mod, $(MODULES), \
	  $(CC) -c -o $(BUILDDIR)/$(mod).cmi $(CFLAGS) $(SRCDIR)/$(mod).mli;)

# Make all compiled implementations
$(CMOS): $(CMIS)
	$(foreach mod, $(MODULES), \
	  $(CC) -c -I $(BUILDDIR) -o $(BUILDDIR)/$(mod).cmo $(CFLAGS) $(SRCDIR)/$(mod).ml;)

# Make library
$(LIB): $(CMOS)
	$(CC) -a -I $(BUILDDIR) -o $@ $(CMOS)

# Make toplevel
toplevel: $(LIB)
	ocamlmktop -custom -o mytoplevel $(LIB) -thread -cclib $(DEPS)

# Clean
clean:
	rm -rf _build
	rm -f $(NAME)
	rm -f $(LIB)

