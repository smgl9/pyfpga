#!/usr/bin/make

SCRIPTS = $(wildcard *.py)

all:
	@$(foreach SCRIPT, $(SCRIPTS), python3 $(SCRIPT); python3 $(SCRIPT) --lang vhdl; )
