PKG_CPPFLAGS = -DNTIMER

LIB = ../SuiteSparse_config.a

library: $(LIB)

$(LIB): SuiteSparse_config.o
	$(AR) -rcs $(LIB) SuiteSparse_config.o

mostlyclean: clean

clean:
	@-rm -rf .libs _libs $(LIB)
	@-rm -f *.o

