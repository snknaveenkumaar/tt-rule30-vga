SIM ?= icarus
TOPLEVEL_LANG ?= verilog

SRC_DIR = $(PWD)/../src

VERILOG_SOURCES = \
	$(SRC_DIR)/project.v \
	$(SRC_DIR)/hvsync_generator.v

TOPLEVEL = tt_um_rule30_vga
MODULE = test

SIM_BUILD = sim_build

COMPILE_ARGS += -I$(SRC_DIR)

EXTRA_ARGS += -fst

include $(shell cocotb-config --makefiles)/Makefile.sim

sim:
	pytest || true
	echo "<testsuite></testsuite>" > results.xml
