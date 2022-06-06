# Find Perl.
include(FindPerlLibs)
if (NOT PERLLIBS_FOUND)
  message(FATAL_ERROR "Could not find Perl libraries.")
endif ()
execute_process(COMMAND "${PERL_EXECUTABLE}" "-MExtUtils::Embed" "-e" "ldopts"
  RESULT_VARIABLE PERL_LDFLAGS_ERROR
  OUTPUT_VARIABLE PERL_LIBRARIES)
string(STRIP "${PERL_LIBRARIES}" PERL_LIBRARIES)
if (PERL_LDFLAGS_ERROR)
  set(PERL_LIBRARIES ${PERL_LIBRARY})
endif ()
execute_process(COMMAND "${PERL_EXECUTABLE}" "-MExtUtils::Embed" "-e" "ccopts"
  RESULT_VARIABLE PERL_CFLAGS_ERROR
  OUTPUT_VARIABLE PERL_CFLAGS)
if (NOT PERL_CFLAGS_ERROR)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${PERL_CFLAGS}")
endif ()
message(INFO ${PERL_CFLAGS})