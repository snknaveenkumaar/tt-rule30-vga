## Makefile for TinyTapeout Rule-30 VGA — cocotb + Icarus Verilog
## Usage:
##   make            — RTL sim
##   make GATES=yes  — Gate-level sim (used automatically by tt-gds-action/gl_test)

SIM           ?= icarus
TOPLEVEL_LANG ?= verilog

TOPLEVEL = tt_um_rule30_vga
MODULE   = test

# Write JUnit XML to the current directory (test/) not sim_build/
COCOTB_RESULTS_FILE = results.xml

COCOTB_HDL_TIMEUNIT      = 1ns
COCOTB_HDL_TIMEPRECISION = 1ps

ifneq ($(GATES),yes)

# ── RTL simulation ───────────────────────────────────────────────────────────
# List hvsync_generator.v FIRST so the module is defined before tt_um_rule30_vga.v
# uses it. If hvsync_generator is `included inside tt_um_rule30_vga.v already,
# remove it from here to avoid "module redefined" errors.
VERILOG_SOURCES  = $(PWD)/../src/hvsync_generator.v
VERILOG_SOURCES += $(PWD)/../src/tt_um_rule30_vga.v

COMPILE_ARGS += -g2012

else

# ── Gate-Level simulation ─────────────────────────────────────────────────────
COMPILE_ARGS += -g2012
COMPILE_ARGS += -DGL_TEST
COMPILE_ARGS += -DFUNCTIONAL
COMPILE_ARGS += -DSIM
COMPILE_ARGS += -DUNIT_DELAY=\#1

VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v
VERILOG_SOURCES += gate_level_netlist.v

endif

# ── cocotb Makefile must be last ─────────────────────────────────────────────
include $(shell cocotb-config --makefiles)/Makefile.sim
