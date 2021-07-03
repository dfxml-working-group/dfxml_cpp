#                                               -*- Autoconf -*-
#
# This configure script is for creating dfxml_config.h, which is used for the
# config file used by the unittest (testapp_catch2.cpp) program.
# That is the sole purpose of this script.
#
# It includes dfxml_configure.mx, which is a mix-in for using dfxml

# LICENSE
#
# Copyright (c) 2021, Simson L. Garfinkel <simsong@acm.org>
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved.  This file is offered as-is, without any
#   warranty.


AC_PREREQ([2.69])
AC_INIT([DFXML],[1.0.1],[bugs@digitalcorpora.org])
AC_CONFIG_MACRO_DIR(m4)
m4_include([m4/ax_cxx_compile_stdcxx.m4])

AC_CONFIG_FILES([Makefile])
AC_CONFIG_HEADERS([dfxml_config.h])
AM_INIT_AUTOMAKE([foreign])
AM_MAINTAINER_MODE

# Initialize libtool support
LT_PREREQ([2.4.6])
LT_INIT([shared])
LT_LANG([C++])

# Programs we will be using
AC_PROG_CC
AC_PROG_CXX
AM_PROG_CC_C_O                    dnl allow per-produce flags
AC_PROG_INSTALL

# Must use C++17 mode. (mandatory)

AC_LANG_PUSH(C++)
AX_CXX_COMPILE_STDCXX([17], [noext], [mandatory])
AC_LANG_POP()

m4_include([dfxml_configure.m4])

################################################################
#
# Enable all the compiler debugging we can find
#
# This is originally from PhotoRec, but modified substantially by Simson
# Figure out which flags we can use with the compiler.
#
# These I don't like:
# -Wdeclaration-after-statement -Wconversion
# doesn't work: -Wunreachable-code
# causes configure to crash on gcc-4.2.1: -Wsign-compare-Winline
# causes warnings with unistd.h:  -Wnested-externs
# Just causes too much annoyance: -Wmissing-format-attribute

# Check GCC
GCC_WARNINGS_TO_TEST="-MD -Wpointer-arith -Wmissing-declarations -Wmissing-prototypes \
    -Wshadow -Wwrite-strings -Wcast-align -Waggregate-return \
    -Wbad-function-cast -Wcast-qual -Wundef -Wredundant-decls -Wdisabled-optimization \
    -Wfloat-equal -Wmultichar -Wc++-compat -Wmissing-noreturn -Wno-deprecated-declarations \
    -Wno-unknown-warning-option"

CXX_WARNINGS_TO_TEST="-Wall -MD -Wpointer-arith -Wshadow -Wwrite-strings -Wcast-align  \
    -Wredundant-decls -Wdisabled-optimization -Wfloat-equal -Wmultichar -Wmissing-noreturn \
    -Wstrict-null-sentinel -Woverloaded-virtual -Wsign-promo -Wno-deprecated-declarations \
    -funit-at-a-time"

if test x"${mingw}" != "xyes" ; then
  # add the warnings we do not want to do on mingw
  GCC_WARNINGS_TO_TEST="$GCC_WARNINGS_TO_TEST -Wall -Wstrict-prototypes"
fi

echo "Warnings to test: $GCC_WARNINGS_TO_TEST"

for option in $GCC_WARNINGS_TO_TEST
do
  SAVE_CFLAGS="$CFLAGS"
  CFLAGS="$CFLAGS $option"
  AC_MSG_CHECKING([whether gcc understands $option])
  AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[]], [[]])],
      [has_option=yes],
      [has_option=no; CFLAGS="$SAVE_CFLAGS"])
  AC_MSG_RESULT($has_option)
  unset has_option
  unset SAVE_CFLAGS
  if test $option = "-Wmissing-format-attribute" ; then
    AC_DEFINE(HAVE_MISSING_FORMAT_ATTRIBUTE_WARNING,1,
		[Indicates that we have the -Wmissing-format-attribute G++ warning])
  fi
done
unset option


# Check G++
# We don't use these warnings:
# -Waggregate-return -- aggregate returns are GOOD; they simplify code design
# We can use these warnings after ZLIB gets upgraded:
# -Wundef  --- causes problems with zlib
# -Wcast-qual
# -Wmissing-format-attribute  --- Just too annoying
# 2020-06-04 removed ‘-Wno-unknown-warning-option’
AC_LANG_PUSH(C++)

if test x"${mingw}" != "xyes" ; then
  # add the warnings we don't want to do on mingw
  CXX_WARNINGS_TO_TEST="$CXX_WARNINGS_TO_TEST  -Weffc++"
fi

echo "Warnings to test: $CXX_WARNINGS_TO_TEST"

for option in $CXX_WARNINGS_TO_TEST
do
  SAVE_CXXFLAGS="$CXXFLAGS"
  CXXFLAGS="$CXXFLAGS $option"
  AC_MSG_CHECKING([whether g++ understands $option])
  AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[]], [[]])],
      [has_option=yes],
      [has_option=no; CXXFLAGS="$SAVE_CXXFLAGS"])
  AC_MSG_RESULT($has_option)
  unset has_option
  unset SAVE_CXXFLAGS
done
unset option

AC_LANG_POP()

################################################################
# Specify our other headers
#
# Autoupdate added the next two lines to ensure that your configure
# script's behavior did not change.  They are probably safe to remove.
AC_CHECK_INCLUDES_DEFAULT
AC_PROG_EGREP

################################################################
## os-specific fixups
# AC_CANONICAL_HOST is needed to access the 'host_os' variable
AC_CANONICAL_HOST
case "${host_os}" in
    linux*)
        ;;
    cygwin*|mingw*)
        ;;
    darwin*)
      CXXFLAGS="-Wno-unknown-warning-option $CXXFLAGS"
        ;;
    *)
        ;;
esac


############## drop optimization flags if requested ################
AC_ARG_WITH(no_optimize, AS_HELP_STRING([--with-no_optimize],[Drop -O C flags]))
if test x"${NO_OPTIMIZE}" != "x" ; then
   with_no_optimize="yes";
fi

if test "${with_no_optimize}" = "yes" ; then
  CFLAGS=`echo "$CFLAGS" | sed s/-O[[0-9]]//`             # note the double quoting!
  CXXFLAGS=`echo "$CXXFLAGS" | sed s/-O[[0-9]]//`
fi

AC_OUTPUT
