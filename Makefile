#
# $Id$
#
# This file is part of Zozotez
#
# Zozotez is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Zozotez is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License

all: zozotez.bf

test:
	@make -C src all

zozotez.bf: 	src/test-zozotez.bf src/version.bf src/ascii-zozotez.txt
	cat src/test-zozotez.bf | tools/apply_code.pl src/ascii-zozotez.txt > zozotez.tmp &&\
	cat zozotez.tmp | sed "s~COMPILERINFO~`cat src/version.bf`~g" > zozotez.bf &&\
	rm -f zozotez.tmp

src/test-zozotez.bf:  src
	@make -C src test-zozotez.bf

clean:
	rm zozotez.bf
	echo "NB: this will not clean the src directory"

.PHONEY: clean test
