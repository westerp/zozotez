#!/usr/bin/perl -w
# $Id: ebf_error.pl 115 2011-05-11 23:27:15Z westerp $
#
# This file is part of ebf-compiler package
#
# This is used to catch compilation errors and stop make from continuing
#
# ebf-compiler is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ebf-compiler is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License

die("usage: $0 object-file\n") unless defined $ARGV[0];
die("Compilation of $ARGV[0] failed: zero size\n") if(! -s $ARGV[0] );
my $file = $ARGV[0];
$/=undef;
$in=<>;
die("compilation of $file failed: $&\n") if( $in=~ /^.*ERROR.*$/m )
