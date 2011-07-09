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

EBF_BIN = ebf
EBF_ERROR = ebf_error.pl
TEST_BINS   = zozotez-read.bf zozotez-print.bf
TEST_FILES  = test/read.ebf
MACRO_FILES = macro-read.ebf macro-print.ebf macro-main.ebf
HEAD = version.ebf
BASE = zozotez-base.ebf
TAIL = tail.ebf

test: $(TEST_BINS)
all: zozotez.bf

.SUFFIXES:
.SUFFIXES: .bf .ebf

zozotez.ebf: $(HEAD) $(MACRO_FILES) $(BASE) $(TAIL)
	cat $(HEAD) $(MACRO_FILES) $(BASE) $(TAIL) > zozotez.ebf

zozotez-read.ebf:  $(HEAD) macro-read.ebf $(BASE) test/read.ebf
	cat $(HEAD) macro-read.ebf $(BASE) test/read.ebf > zozotez-read.ebf

zozotez-print.ebf: $(HEAD) macro-print.ebf $(BASE) test/print.ebf
	cat $(HEAD) macro-print.ebf $(BASE) test/print.ebf > zozotez-print.ebf

.ebf.bf : info
	cat $< | $(EBF_BIN) | tee  $*.tmp  && \
	${EBF_ERROR} $*.tmp && \
	mv $*.tmp $*.bf

clean:
	rm -rf zozotez-read.ebf zozotez.ebf *.bf *~

info:
	@echo In order to compile this package you need a ebf binary or change EBF_BIN to a combination of
	@echo the ebf.bf and a intrepreter to run it.
	@echo Go to http://sylwester.no/ebf/ to get the package and run make install it makeing fails

.PHONY: clean info
