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

EBF_BIN = ../tools/ebf
EBF_ERROR = ../tools/ebf_error.pl
APPLY_CODE = ../tools/apply_code.pl ascii-zozotez.txt
TEST_BINS   = test-read.bf test-print.bf test-readprint.bf
TEST_FILES  = test/read.ebf
MACRO_FILES = macro-read.ebf macro-print.ebf macro-main.ebf
#MACRO_FILES = macro-main.ebf
VERSION = version.bf
BASE = zozotez-base.ebf
TAIL = tail.ebf

test: $(TEST_BINS)
all: test-zozotez.bf

.SUFFIXES:
.SUFFIXES: .bf .ebf

test-zozotez.ebf: $(MACRO_FILES) $(BASE) $(TAIL)
	cat $(MACRO_FILES) $(BASE) $(TAIL) > test-zozotez.ebf

test-read.ebf:  macro-read.ebf $(BASE) test/read.ebf
	cat  macro-read.ebf $(BASE) test/read.ebf > test-read.ebf

test-print.ebf: macro-print.ebf $(BASE) test/print.ebf
	cat macro-print.ebf $(BASE) test/print.ebf > test-print.ebf

test-readprint.ebf: macro-read.ebf macro-print.ebf $(BASE) test/readprint.ebf
	cat macro-read.ebf macro-print.ebf $(BASE) test/readprint.ebf > test-readprint.ebf


.ebf.bf : info
	cat $< | $(EBF_BIN) | tee  $*.tmp  | $(APPLY_CODE) && \
	${EBF_ERROR} $*.tmp && \
	mv $*.tmp $*.bf

clean:
	rm -f test-*.ebf *.bf *~

info:
	@echo In order to compile this package under windowns you need a ebf-bf and a bf-compiler/interpreter
	@echo and change EBF_BIN to a combination of the ebf.bf and a intrepreter to run it.
	@echo Go to http://sylwester.no/ebf/ to get it.

.PHONY: clean info
