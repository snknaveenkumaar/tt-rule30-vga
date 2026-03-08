## Makefile for TinyTapeout Rule-30 VGA cocotb simulation
## RTL:  make
## GL:   make GATES=yes  (run by tt-gds-action/gl_test automatically)

SIM           ?= icarus
TOPLEVEL_LANG ?= verilog

# cocotb drives the DUT directly — no separate testbench wrapper needed
TOPLEVEL = tt_um_rule30_vga
MODULE   = test

# Explicitly set results file path so it lands in test/ (the CWD when make runs)
COCOTB_RESULTS_FILE = results.xml

# Timing
COCOTB_HDL_TIMEUNIT      = 1ns
COCOTB_HDL_TIMEPRECISION = 1ps

ifneq ($(GATES),yes)

# ── RTL simulation ───────────────────────────────────────────────
VERILOG_SOURCES  = $(PWD)/../src/hvsync_generator.v
VERILOG_SOURCES += $(PWD)/../src/tt_um_rule30_vga.v
COMPILE_ARGS    += -g2012

else

# ── Gate-Level simulation ────────────────────────────────────────
COMPILE_ARGS += -g2012
COMPILE_ARGS += -DGL_TEST
COMPILE_ARGS += -DFUNCTIONAL
COMPILE_ARGS += -DSIM
COMPILE_ARGS += -DUNIT_DELAY=\#1
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v
VERILOG_SOURCES += gate_level_netlist.v

endif

# ── cocotb Makefile (must be the last include) ───────────────────
include $(shell cocotb-config --makefiles)/Makefile.sim
