#! /bin/sh
# Copyright (C) 2011-2012 Free Software Foundation, Inc.
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

# Check that automake can cope with user-redefinition of $(YFLAGS)
# at configure time and/or at make time.

required='cc yacc'
. ./defs || Exit 1

unset YFLAGS || :

cat >> configure.ac <<'END'
AC_PROG_CC
AC_PROG_YACC
AC_OUTPUT
END

cat > Makefile.am <<'END'
bin_PROGRAMS = foo
foo_SOURCES = foo.y
# A minor automake wart: automake doesn't generate code to clean
# '*.output' files generated by yacc (it's not even clear if that
# would be useful in general, so it's probably better to be
# conservative).
CLEANFILES = foo.output
# Another automake wart: '-d' flag won't be given at automake time,
# so automake won't be able to generate code to clean 'foo.h' :-(
MAINTAINERCLEANFILES = foo.h
END

cat > foo.y << 'END'
%{
int yylex () { return 0; }
void yyerror (char *s) { return; }
int main () { return 0; }
%}
%%
foobar : 'f' 'o' 'o' 'b' 'a' 'r' {};
END

$ACLOCAL
$AUTOMAKE -a
$AUTOCONF

./configure YFLAGS='-d -v'
$MAKE
ls -l
test -f foo.c
test -f foo.h
test -f foo.output

$MAKE maintainer-clean
ls -l

./configure YFLAGS='-v'
$MAKE
ls -l
test -f foo.c
test ! -r foo.h
test -f foo.output

$MAKE maintainer-clean
ls -l

./configure YFLAGS='-v'
YFLAGS=-d $MAKE -e
ls -l
test -f foo.c
test -f foo.h
test ! -r foo.output

$MAKE maintainer-clean
ls -l

: