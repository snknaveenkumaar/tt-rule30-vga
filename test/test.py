import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles


@cocotb.test()
async def test_rule30_vga(dut):
    """Basic smoke test for Rule-30 VGA design."""

    # 25 MHz clock (40 ns period)
    clock = Clock(dut.clk, 40, units="ns")
    cocotb.start_soon(clock.start())

    # Initialise all inputs
    dut.ui_in.value  = 0
    dut.uio_in.value = 0
    dut.ena.value    = 1
    dut.rst_n.value  = 0

    # Hold reset for 10 cycles
    await ClockCycles(dut.clk, 10)

    # Release reset
    dut.rst_n.value = 1

    # Run for 500 cycles
    await ClockCycles(dut.clk, 500)

    # Verify outputs are valid (no X/Z)
    assert dut.uo_out.value.is_resolvable,  "uo_out has X/Z after reset release"
    assert dut.uio_out.value == 0,          "uio_out should be 0"
    assert dut.uio_oe.value  == 0,          "uio_oe should be 0"

    dut._log.info(f"uo_out = {dut.uo_out.value}")
    dut._log.info("Rule-30 VGA smoke test PASSED")
