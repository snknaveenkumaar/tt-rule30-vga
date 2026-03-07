# Makefile for cocotb simulation

SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# Path to design sources
SRC_DIR = $(PWD)/../src

# Design source files
VERILOG_SOURCES = \
	$(SRC_DIR)/project.v \
	$(SRC_DIR)/hvsync_generator.v

# Top level module of the design
TOPLEVEL = tt_um_rule30_vga

# Python test module (test.py)
MODULE = test

# Build directory
SIM_BUILD = sim_build

# Allow include of source directory
COMPILE_ARGS += -I$(SRC_DIR)

# Enable waveform dumping
EXTRA_ARGS += -fst

# Use cocotb's simulation rules
include $(shell cocotb-config --makefiles)/Makefile.sim
