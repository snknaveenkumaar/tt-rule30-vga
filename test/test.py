import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

@cocotb.test()
async def rule30_vga_test(dut):
"""Basic smoke test for Rule-30 VGA design"""

```
# Start 25 MHz clock (40 ns period)
clock = Clock(dut.clk, 40, units="ns")
cocotb.start_soon(clock.start())

# Initialize inputs
dut.ena.value = 1
dut.ui_in.value = 0
dut.uio_in.value = 0
dut.rst_n.value = 0

# Hold reset for a few cycles
for _ in range(10):
    await RisingEdge(dut.clk)

# Release reset
dut.rst_n.value = 1

# Run simulation for some cycles
for _ in range(500):
    await RisingEdge(dut.clk)

# Check outputs are valid (not X or Z)
assert dut.uo_out.value.is_resolvable, "uo_out contains invalid values"
assert dut.uio_out.value == 0, "uio_out should remain zero"
assert dut.uio_oe.value == 0, "uio_oe should remain zero"

cocotb.log.info("Rule-30 VGA test completed successfully")
```
