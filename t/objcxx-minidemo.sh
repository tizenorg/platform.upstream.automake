#! /bin/sh
# Copyright (C) 2012 Free Software Foundation, Inc.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Dummy demo package using Objective C++ and doing distcheck.
# See also sister test 'objc-minidemo.sh'.

required=native
. ./defs || Exit 1

cat >> configure.ac << 'END'
dnl Support for Object C++ was introduced only in Autoconf 2.65.
AC_PREREQ([2.65])
AC_PROG_OBJCXX
AC_CONFIG_HEADERS([config.h])
AC_OUTPUT
END

cat > Makefile.am << 'END'
AM_DEFAULT_SOURCE_EXT = .mm
bin_PROGRAMS = ok
noinst_PROGRAMS = ko
TESTS = $(bin_PROGRAMS) $(XFAIL_TESTS)
XFAIL_TESTS = $(noinst_PROGRAMS)
END

cat > ok.mm << 'END'
/* The use of #import makes this valid Object C++ but invalid C++. */
#import <iostream>
#import <config.h>
int main (void)
{
    std::cout << "Success (" << PACKAGE_STRING << ")\n";
    return 0;
}
END

cat > ko.mm << 'END'
/* The use of #import makes this valid Object C++ but invalid C++. */
#import <cstdio>
int main (void)
{
    printf("Failure\n");
    return 1;
}
END

if $ACLOCAL; then
  : We have a modern enough autoconf, go ahead.
elif test $? -eq 63; then
  skip_ "Object C++ support requires Autoconf 2.65 or later"
else
  Exit 1 # Some other aclocal failure.
fi
$AUTOCONF
$AUTOHEADER
$AUTOMAKE --add-missing

./configure
$MAKE
$MAKE check
$MAKE distcheck

:
