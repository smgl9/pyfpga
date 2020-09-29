#!/usr/bin/make

all:

DOCKER_CMD=docker run --rm -it -v $$HOME:$$HOME -w $$PWD ghdl/synth:beta

docker-update:
	docker pull ghdl/synth:beta

ghdl:
	$(DOCKER_CMD) bash ghdl.sh

ghdl-yosys:
	$(DOCKER_CMD) bash ghdl-yosys.sh

ise:
	xtclsh ise.tcl

quartus:
	quartus_sh --script quartus.tcl

libero:
	libero SCRIPT:libero.tcl

vivado:
	vivado -mode batch -notrace -quiet -source vivado.tcl

yosys:
	$(DOCKER_CMD) bash yosys.sh

clean:
	# ghdl and yosys
	rm -fr *.cf *.edif
	# ise
	rm -fr \
	*.bgn *.bit *.bld *.cmd_log *.drc *.lso *.ncd *.ngc *.ngd *.ngr      \
	*.pad *.par *.pcf *.prj *.ptwx *.stx *.syr *.twr *.twx *.unroutes    \
	*.ut *.xpi *.xst *.xwbt *.map *.mrp *.ngm *.xrpt *.csv *.gise *.xise \
	_ngo _xmsgs xlnx_auto_0_xdb xst .Xil
	# libero
	rm -fr libero
	# quartus
	rm -fr \
	*.rpt *.done *.summary *.jdi *.pin *.qpf *.qsf *.sld *.sof db \
	incremental_db
	# vivado
	rm -fr *.bit *.cache *.hw *.runs *.xpr *.jou *.ip_user_files
	# General
	rm -fr *.html *.log *.txt *.xml