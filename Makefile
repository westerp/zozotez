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
SVNREPO = https://zozotez.googlecode.com/svn

all: zozotez.bf

test:
	@make -C src all

zozotez.bf: 	src/test-zozotez.bf src/ascii-zozotez.txt COPYING
	cat src/test-zozotez.bf | perl -e '$$/=undef;$$_=<>;s/[^\Q+-<>,.[]\E]//g;s/\Q<>\E|\Q><\E//g;s/\Q-+\E|\Q+-\E//g;print' | tools/apply_code.pl src/ascii-zozotez.txt > zozotez.tmp &&\
	cat zozotez.tmp COPYING | sed "s~COMPILERINFO~`echo '?'| tools/ebf | sed 's/\\$$//g'`~g" > zozotez.bf &&\
	rm -f zozotez.tmp

src/test-zozotez.bf:  src
	@make -C src test-zozotez.bf

clean:
	rm -f zozotez.bf *~
	@echo "NB: this will not clean the src directory"


release: version zozotez.bf
	@rm -rf zozotez-$(REV).tar.gz zozotez-$(REV).zip zozotez-$(REV)
	svn copy  -m "tagged release zozotez-$$REV" $(SVNREPO)/trunk  $(SVNREPO)/tags/zozotez-$(REV);
	svn export $(SVNREPO)/tags/zozotez-$(REV) zozotez-$(REV)
	jitbf zozotez-$(REV)/zozotez.bf -p --description 'ZOZOTEZ LISP INTERPRETER by PÅL WESTER' > zozotez.c
	gcc zozotez.c -O3 -o zozotez-$(REV)/zozotez
	strip zozotez-$(REV)/zozotez
	zip -r zozotez-$(REV).zip zozotez-$(REV)
	tar -czf zozotez-$(REV).tar.gz zozotez-$(REV)


version:
	@if [ "$$REV" != "" -a "x`echo $$REV|sed 's/[\.0-9]//g'`" = "x" ]; then \
		echo "tag will be zozotez-$$REV ($$REV)";\
		true;\
	else \
		echo "REV=$$REV is invalid. You need to pass release REV=<revision> where revision is numbers separated by ."; \
		false; \
	fi

.PHONEY: clean test version
