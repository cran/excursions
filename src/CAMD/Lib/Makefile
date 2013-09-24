#-------------------------------------------------------------------------------
# CAMD Makefile for compiling on Unix systems (for original Make ONLY)
#-------------------------------------------------------------------------------

# This is a very ugly Makefile, and is only provided for those who do not
# have GNU make.  Note that it is not used if you have GNU make.  It ignores
# dependency checking and just compiles everything.

default: everything

CF = $(CFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -O3 -fexceptions -fPIC

# ranlib, and ar, for generating libraries.  If you don't need ranlib,
# just change it to RANLAB = echo
RANLIB = ranlib
ARCHIVE = $(AR) $(ARFLAGS)
TARGET = ../../CAMD.a


CLEAN = *.o *.obj *.ln *.bb *.bbg *.da *.tcov *.gcov gmon.out *.bak *.d *.gcda *.gcno
##########################################

C = $(CC) $(CF) -I../Include 

everything:
	$(C) -DDINT -c ../Source/camd_aat.c -o camd_i_aat.o
	$(C) -DDINT -c ../Source/camd_1.c -o camd_i_1.o
	$(C) -DDINT -c ../Source/camd_2.c -o camd_i_2.o
	$(C) -DDINT -c ../Source/camd_dump.c -o camd_i_dump.o
	$(C) -DDINT -c ../Source/camd_postorder.c -o camd_i_postorder.o
	$(C) -DDINT -c ../Source/camd_defaults.c -o camd_i_defaults.o
	$(C) -DDINT -c ../Source/camd_order.c -o camd_i_order.o
	$(C) -DDINT -c ../Source/camd_control.c -o camd_i_control.o
	$(C) -DDINT -c ../Source/camd_info.c -o camd_i_info.o
	$(C) -DDINT -c ../Source/camd_valid.c -o camd_i_valid.o
	$(C) -DDINT -c ../Source/camd_preprocess.c -o camd_i_preprocess.o
	$(C) -DDLONG -c ../Source/camd_aat.c -o camd_l_aat.o
	$(C) -DDLONG -c ../Source/camd_1.c -o camd_l_1.o
	$(C) -DDLONG -c ../Source/camd_2.c -o camd_l_2.o
	$(C) -DDLONG -c ../Source/camd_dump.c -o camd_l_dump.o
	$(C) -DDLONG -c ../Source/camd_postorder.c -o camd_l_postorder.o
	$(C) -DDLONG -c ../Source/camd_defaults.c -o camd_l_defaults.o
	$(C) -DDLONG -c ../Source/camd_order.c -o camd_l_order.o
	$(C) -DDLONG -c ../Source/camd_control.c -o camd_l_control.o
	$(C) -DDLONG -c ../Source/camd_info.c -o camd_l_info.o
	$(C) -DDLONG -c ../Source/camd_valid.c -o camd_l_valid.o
	$(C) -DDLONG -c ../Source/camd_preprocess.c -o camd_l_preprocess.o
	$(C) -c ../Source/camd_global.c
	$(ARCHIVE)  $(TARGET) \
            camd_i_aat.o camd_i_1.o camd_i_2.o camd_i_dump.o \
	    camd_i_postorder.o camd_i_defaults.o camd_i_order.o \
	    camd_i_control.o camd_i_info.o camd_i_valid.o camd_l_aat.o \
	    camd_l_1.o camd_l_2.o camd_l_dump.o camd_l_postorder.o \
	    camd_l_defaults.o camd_l_order.o camd_l_control.o camd_l_info.o \
	    camd_l_valid.o camd_i_preprocess.o camd_l_preprocess.o camd_global.o
	- $(RANLIB) $(TARGET)

#-------------------------------------------------------------------------------
# Remove all but the files in the original distribution
#-------------------------------------------------------------------------------

clean:
	- $(RM) $(CLEAN)

purge: distclean

distclean: clean
	- $(RM) $(TARGET)
