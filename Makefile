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
VERSION    = $(shell head VERSION)
MAJOR      = $(shell echo $(VERSION) | sed "s/^\([0-9]*\).*/\1/")
MINOR	   = $(shell echo $(VERSION) | sed "s/[0-9]*\.\([0-9]*\)/\1/")
PATCH      = 

all: zozotez.bf

test:
	@make -C src all VERSION=$VERSION-$PATCH

zozotez.bf: src/test-zozotez.bf src/ascii-zozotez.txt COPYING VERSION
	@if [ -d .git ]; then\
		PATCH=-$$(git rev-parse --short=4 HEAD);\
	fi;\
	cat src/test-zozotez.bf | perl -e '$$/=undef;$$_=<>;s/[^\Q+-<>,.[]\E]//g;s/\Q<>\E|\Q><\E//g;s/\Q-+\E|\Q+-\E//g;print' | tools/apply_code.pl src/ascii-zozotez.txt > zozotez.tmp &&\
	cat zozotez.tmp COPYING | sed "s~COMPILERINFO~`echo '?'| tools/ebf | sed 's/\\$$//g'`~g" |\
	sed s/ZOZOTEZVERSION/$(VERSION)$${PATCH}/g > zozotez.bf &&\
	rm -f zozotez.tmp

src/test-zozotez.bf: src VERSION
	@if [ -d .git ]; then\
		PATCH=-$$(git rev-parse --short=4 HEAD);\
	fi;\
	make -C src test-zozotez.bf VERSION=$(VERSION)$${PATCH}

clean:
	rm -f zozotez.bf *~
	rm -rf zozotez-$(VERSION).tar.gz zozotez-$(VERSION).zip zozotez-$(VERSION) zozotez.c
	@echo "NB: this will not clean the src directory"

rebuild-binary:
	rm -rf zozotez.bf *~
	make -C src clean
	make zozotez.bf
	
bump-major:
	@echo `expr 1 + $(MAJOR)`.0 > VERSION
	cat VERSION

bump-minor:
	@echo $(MAJOR).`expr 1 + $(MINOR)` > VERSION
	cat VERSION

new-version: bump-minor
	
release: clean
	@if [ -d .git ]; then\
		PATCH=-$$(git rev-parse --short=4 HEAD);\
	fi;\
	STATUS=$$(git status --porcelain);\
	BRANCH=$$(git status | grep 'On branch master');\
	if [ "x$${BRANCH}" = "x" ]; then\
		echo ERROR: Not release branch. Please switch;\
		git status;\
	elif [ "x$${STATUS}" != "x" ]; then\
		echo ERROR: Working directory is dirty >&2;\
		git status --porcelain;\
        else\
        	make rebuild-binary;\
		git checkout-index -a --prefix=zozotez-$(VERSION)/;\
		cp zozotez.bf zozotez-$(VERSION);\
		jitbf zozotez-$(VERSION)/zozotez.bf -p --description "ZOZOTEZ LISP INTERPRETER v$(VERSION)$${PATCH} by PÅL WESTER" > zozotez.c;\
		gcc zozotez.c -m32 -O2 -o zozotez-$(VERSION)/zozotez;\
		strip zozotez-$(VERSION)/zozotez;\
		zip -r zozotez-$(VERSION).zip zozotez-$(VERSION);\
		tar -czf zozotez-$(VERSION).tar.gz zozotez-$(VERSION);\
	fi

tag:
	git tag -a zozotez-$(VERSION) -m "Tagged release $(VERSION)"

push: 
	git push --tags

.PHONEY: clean test bump-major bump-minor new-version release rebuild-binary tag push
