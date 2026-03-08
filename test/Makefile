## Makefile for TinyTapeout cocotb simulation
## Supports both RTL (default) and Gate-Level (GATES=yes) simulation

# ── Simulator ────────────────────────────────────────────────────
SIM          ?= icarus
TOPLEVEL_LANG ?= verilog

# ── Top-level module name (must match your tb.v instantiation) ───
TOPLEVEL     = tt_um_rule30_vga

# ── Python test module (filename without .py) ────────────────────
MODULE       = test

# ── Source files ─────────────────────────────────────────────────
ifneq ($(GATES),yes)

# RTL simulation
VERILOG_SOURCES  = $(PWD)/../src/hvsync_generator.v
VERILOG_SOURCES += $(PWD)/../src/tt_um_rule30_vga.v

else

# Gate-Level simulation – netlist provided by tt-gds-action
COMPILE_ARGS    += -DGL_TEST
COMPILE_ARGS    += -DFUNCTIONAL
COMPILE_ARGS    += -DSIM
COMPILE_ARGS    += -DUNIT_DELAY=\#1
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v
VERILOG_SOURCES += gate_level_netlist.v

endif

# ── Waveform dump ─────────────────────────────────────────────────
COCOTB_HDL_TIMEUNIT      = 1ns
COCOTB_HDL_TIMEPRECISION = 1ps

ifeq ($(SIM),icarus)
COMPILE_ARGS += -g2012
# Dump FST waveform
PLUSARGS     += +dump_file=tb.fst
endif

# ── Include cocotb Makefile (must be last) ────────────────────────
include $(shell cocotb-config --makefiles)/Makefile.sim
