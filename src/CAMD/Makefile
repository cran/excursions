#------------------------------------------------------------------------------
# CAMD Makefile
#------------------------------------------------------------------------------

VERSION = 2.3.1

default: demos
demos: all

# Compile all C code.  Do not compile the FORTRAN versions.
library:
	( cd Lib    ; $(MAKE) )

# remove object files, but keep the compiled programs and library archives
clean:
	( cd Lib    ; $(MAKE) clean )



