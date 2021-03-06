#!/bin/bash
#
# Copyright (C) 2020 Rodrigo A. Melo
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# This file implements an open-source flow based on ghdl, ghdl-yosys-plugin,
# yosys, nextpnr, icestorm and prjtrellis.
#

set -e

###############################################################################
# Things to tuneup
###############################################################################

FRONTEND={frontend}
BACKEND={backend}
PROJECT={project}
FAMILY={family}
DEVICE={device}
PACKAGE={package}
TOP={top}

PARAMS="{params}"
FLAGS="--std=08 -fsynopsys -fexplicit -frelaxed"
VHDLS="{vhdls}"
INCLUDES="{includes}"
VERILOGS="{verilogs}"
CONSTRAINTS="{constraints}"

# taks = prj syn imp bit
TASKS="{tasks}"

#
# Tools configuration
#

OCI_ENGINE="{oci_engine}"

CONT_GHDL="{cont_ghdl}"
CONT_YOSYS="{cont_yosys}"
CONT_NEXTPNR_ICE40="{cont_nextpnr_ice40}"
CONT_ICETIME="{cont_icetime}"
CONT_ICEPACK="{cont_icepack}"
CONT_NEXTPNR_ECP5="{cont_nextpnr_ecp5}"
CONT_ECPPACK="{cont_ecppack}"

TOOL_GHDL="{tool_ghdl}"
TOOL_YOSYS="{tool_yosys}"
TOOL_NEXTPNR_ICE40="{tool_nextpnr_ice40}"
TOOL_ICETIME="{tool_icetime}"
TOOL_ICEPACK="{tool_icepack}"
TOOL_NEXTPNR_ECP5="{tool_nextpnr_ecp5}"
TOOL_ECPPACK="{tool_ecppack}"

###############################################################################
# Support
###############################################################################

MODULE=
[ -n "$VHDLS" ] && MODULE="-m ghdl"

function print () {{
    tput setaf 6; echo ">>> PyFPGA ($1): $2"; tput sgr0;
}}

###############################################################################
# Synthesis
###############################################################################

if [[ $TASKS == *"syn"* ]]; then

print "$FRONTEND" "running 'synthesis'"

### GHDL

if [[ $FRONTEND == "ghdl" ]]; then

$OCI_ENGINE $CONT_GHDL /bin/bash -c "
$VHDLS
$TOOL_GHDL --synth $FLAGS $TOP
" > $PROJECT.vhdl

fi

### Yosys (with ghdl-yosys-plugin)

if [[ $FRONTEND == "yosys" ]]; then

SYNTH=
WRITE=
if [[ $BACKEND == "vivado" ]]; then
    SYNTH="synth_xilinx -top $TOP -family $FAMILY"
    WRITE="write_edif -pvector bra $PROJECT.edif"
elif [[ $BACKEND == "ise" ]]; then
    SYNTH="synth_xilinx -top $TOP -family $FAMILY -ise"
    WRITE="write_edif -pvector bra $PROJECT.edif"
elif [[ $BACKEND == "nextpnr" ]]; then
    SYNTH="synth_$FAMILY -top $TOP -json $PROJECT.json"
elif [[ $BACKEND == "verilog-nosynth" ]]; then
    WRITE="write_verilog $PROJECT.v"
else
    SYNTH="synth -top $TOP"
    WRITE="write_verilog $PROJECT.v"
fi

$OCI_ENGINE $CONT_YOSYS /bin/bash -c "
$VHDLS
$TOOL_YOSYS -Q $MODULE -p '
$INCLUDES;
$VERILOGS;
$PARAMS;
$SYNTH;
$WRITE
'"

fi

###

fi

###############################################################################
# Place and Route
###############################################################################

if [[ $TASKS == *"imp"* ]]; then

print "nextpnr-$FAMILY" "running 'implementation'"

INPUT="--json $PROJECT.json"

if [[ $FAMILY == "ice40" ]]; then
    CONSTRAINT="--pcf $CONSTRAINTS"
    OUTPUT="--asc $PROJECT.asc"
    $OCI_ENGINE $CONT_NEXTPNR_ICE40 $TOOL_NEXTPNR_ICE40 \
        --$DEVICE --package $PACKAGE $CONSTRAINT $INPUT $OUTPUT
    $OCI_ENGINE $CONT_ICETIME $TOOL_ICETIME \
        -d $DEVICE -mtr $PROJECT.rpt $PROJECT.asc
fi

if [[ $FAMILY == "ecp5" ]]; then
    CONSTRAINT="--lpf $CONSTRAINTS"
    OUTPUT="--textcfg $PROJECT.config"
    $OCI_ENGINE $CONT_NEXTPNR_ECP5 $TOOL_NEXTPNR_ECP5 \
        --$DEVICE --package $PACKAGE $CONSTRAINT $INPUT $OUTPUT
fi

fi

###############################################################################
# Bitstream generation
###############################################################################

if [[ $TASKS == *"bit"* ]]; then

if [[ $FAMILY == "ice40" ]]; then
    print "icepack" "running 'bitstream generation'"
    $OCI_ENGINE $CONT_ICEPACK $TOOL_ICEPACK \
        $PROJECT.asc $PROJECT.bit
fi

if [[ $FAMILY == "ecp5" ]]; then
    print "eccpack" "running 'bitstream generation'"
    $OCI_ENGINE $CONT_ECPPACK $TOOL_ECPPACK \
        --svf $PROJECT.svf $PROJECT.config $PROJECT.bit
fi

fi
