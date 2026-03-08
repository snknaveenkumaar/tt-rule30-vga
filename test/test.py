import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_rule30_vga(dut):
    """Basic smoke test for Rule-30 VGA design."""
    clock = Clock(dut.clk, 40, units="ns")  # 25 MHz
    cocotb.start_soon(clock.start())

    dut.ui_in.value  = 0
    dut.uio_in.value = 0
    dut.ena.value    = 1
    dut.rst_n.value  = 0

    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 500)

    assert dut.uo_out.value.is_resolvable, "uo_out has X/Z"
    assert dut.uio_out.value == 0,         "uio_out should be 0"
    assert dut.uio_oe.value  == 0,         "uio_oe should be 0"
    dut._log.info("PASSED")
