MkInclude = ${R_HOME}/etc${R_ARCH}/Makeconf

IEXTLIBS = -ISuiteSparse_config -ICAMD/Include -ICHOLMOD/Include
LEXTLIBS =	
E_LIBS = CHOLMOD.a CAMD.a AMD.a COLAMD.a SuiteSparse_config.a 
SUBDIRS = CHOLMOD COLAMD AMD CAMD SuiteSparse_config

PKG_CFLAGS = $(SHLIB_OPENMP_CFLAGS) $(IEXTLIBS)
PKG_CXXFLAGS = $(SHLIB_OPENMP_CXXFLAGS) $(IEXTLIBS)
LDFLAGS = $(ALL_CXXFLAGS)

ALL_LIBS = $(E_LIBS) ${LAPACK_LIBS} ${BLAS_LIBS} ${FLIBS} -lm

SUBLIBS = $(SUBDIRS:=.a)

all : sublibraries excursions gaussint

EXCURSIONS_OBJ = excursions.o integration.o utils.o RngStream.o gsl_fix.o xerbla.o
excursions : $(EXCURSIONS_OBJ)
	$(CXX) $(LDFLAGS) $(LEXTLIBS) -o $@ $(EXCURSIONS_OBJ) $(ALL_LIBS)

GAUSSINT_OBJ = gaussint.o integration.o utils.o RngStream.o gsl_fix.o xerbla.o
gaussint : $(GAUSSINT_OBJ)
	$(CXX) $(LDFLAGS) $(LEXTLIBS) -o $@ $(GAUSSINT_OBJ) $(ALL_LIBS) 

sublibraries:
	@for d in $(SUBDIRS); do \
	(cd $${d} && CFLAGS="$(CFLAGS)" CXXFLAGS="$(CXXFLAGS)" MkInclude="$(MkInclude)" $(MAKE) library) || exit 1; \
	done

clean: subclean
	@-rm -f *.o excursions gaussint

subclean:
	@-rm -f *.a
	@for d in $(SUBDIRS); do \
	  (cd $${d} && MkInclude="$(MkInclude)" $(MAKE) clean) || exit 1; \
	done
