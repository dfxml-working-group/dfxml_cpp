#!/bin/sh
# have automake do an initial population if necessary
#
# this file is public domain
#
echo "Running autoheader, aclocal, autoconf and automake."
libtoolize 2>/dev/null || glibtoolize
autoheader -f
aclocal -I m4
autoconf -f
automake --foreign --add-missing --copy
echo "Now you can run ./configure"
