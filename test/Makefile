## TinyTapeout cocotb Makefile
## make           → RTL simulation
## make GATES=yes → Gate-Level simulation (called by tt-gds-action/gl_test)

SIM           ?= icarus
TOPLEVEL_LANG ?= verilog

# TOPLEVEL is the tb wrapper module, NOT the design directly
TOPLEVEL = tb
MODULE   = test

# cocotb writes results.xml to the directory where make is run (test/)
COCOTB_RESULTS_FILE = results.xml

COCOTB_HDL_TIMEUNIT      = 1ns
COCOTB_HDL_TIMEPRECISION = 1ps

ifneq ($(GATES),yes)

# ── RTL ──────────────────────────────────────────────────────────────────────
VERILOG_SOURCES  = $(PWD)/../src/hvsync_generator.v
VERILOG_SOURCES += $(PWD)/../src/tt_um_rule30_vga.v
VERILOG_SOURCES += $(PWD)/tb.v
COMPILE_ARGS    += -g2012

else

# ── Gate-Level ────────────────────────────────────────────────────────────────
COMPILE_ARGS += -g2012
COMPILE_ARGS += -DGL_TEST
COMPILE_ARGS += -DFUNCTIONAL
COMPILE_ARGS += -DSIM
COMPILE_ARGS += -DUNIT_DELAY=\#1

VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v
VERILOG_SOURCES += gate_level_netlist.v
VERILOG_SOURCES += $(PWD)/tb.v

endif

# Must be last
include $(shell cocotb-config --makefiles)/Makefile.sim
