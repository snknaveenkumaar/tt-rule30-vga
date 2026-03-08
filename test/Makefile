SIM           ?= icarus
TOPLEVEL_LANG ?= verilog
TOPLEVEL       = tb
MODULE         = test
COCOTB_RESULTS_FILE = results.xml
COCOTB_HDL_TIMEUNIT      = 1ns
COCOTB_HDL_TIMEPRECISION = 1ps

ifneq ($(GATES),yes)

# ── RTL simulation ────────────────────────────────────────────────
VERILOG_SOURCES  = $(PWD)/../src/hvsync_generator.v
VERILOG_SOURCES += $(PWD)/../src/project.v
VERILOG_SOURCES += $(PWD)/tb.v
COMPILE_ARGS    += -g2012

else

# ── Gate-Level simulation ─────────────────────────────────────────
# -DFUNCTIONAL   : use functional (not timing) cell models
# -DSIM          : enable simulation-mode in PDK cells  
# -DUNIT_DELAY   : use unit delay model
# -DUSE_POWER_PINS: CRITICAL - makes FILLER/TAP cells include VPWR/VGND/VPB/VNB
#                  ports so iverilog doesn't error "port X is not a port of FILLER_N"
COMPILE_ARGS += -g2012
COMPILE_ARGS += -DFUNCTIONAL
COMPILE_ARGS += -DSIM
COMPILE_ARGS += -DUNIT_DELAY=\#1
COMPILE_ARGS += -DUSE_POWER_PINS
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v
VERILOG_SOURCES += gate_level_netlist.v
VERILOG_SOURCES += $(PWD)/tb.v

endif

include $(shell cocotb-config --makefiles)/Makefile.sim
