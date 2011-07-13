#!/usr/bin/perl -w
#
# $Id: apply_code.pl 61 2010-08-06 00:29:20Z westerp $
#
# This file is part of ebf-compiler
#
# ebf-compiler is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# (at your option) any later version.
#
# ebf-compiler is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
#

my @k = split//,'~*{}';
my $eof = 0;
open(IMG, $ARGV[0])||die("could not open design file: $!");
select STDOUT;
$| = 1;

sub get_char ()
{
    do {
        $a = getc();
    } while( defined $a && $a !~ m/[\Q,.[]<>-+\E]/ );

    return $a if( defined $a);
    $eof = 1;
    return $k[int(rand()*@k)];
}

while(<IMG>)
{
  foreach $i (split(//,$_))
  {
    #print $i;
    if( $i =~ /[#\*]/ ){
        print get_char();
    } else {
      print $i;
    }
  }
}
if( ! $eof  )
{
 my $c=0;
 while( ! $eof )
 {
   print "\n" if( $c % 80 == 0);
   print get_char();
   $c++;
 }
 while($c % 80 != 0)
 {
   print get_char();
   $c++
 }
 print "\n";
}