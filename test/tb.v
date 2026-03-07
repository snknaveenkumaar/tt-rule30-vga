import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

@cocotb.test()
async def test_rule30(dut):
    """Basic test: reset, run for some clocks, check outputs are not X"""
    # Start 25MHz clock
    clock = Clock(dut.clk, 40, units="ns")
    cocotb.start_soon(clock.start())
    # Apply reset
    dut.rst_n.value = 0
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.ena.value = 1
    await Timer(200, units="ns")
    dut.rst_n.value = 1
    # Run for enough clocks to get past first row (800 clocks = 1 row)
    for _ in range(1000):
        await RisingEdge(dut.clk)
    # Check outputs are driven (not high-Z or X)
    # vsync and hsync should be toggling
    assert dut.uo_out.value.is_resolvable, "uo_out has X/Z values"
    assert dut.uio_out.value == 0, "uio_out should be 0"
    assert dut.uio_oe.value == 0, "uio_oe should be 0"
    cocotb.log.info("Rule 30 VGA test passed!")
