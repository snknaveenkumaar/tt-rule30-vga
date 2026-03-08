import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_rule30_vga(dut):
    """Smoke test for Rule-30 VGA design (RTL and GL)."""

    # cocotb 2.0: 'unit' not 'units' (fixes DeprecationWarning)
    clock = Clock(dut.clk, 40, unit="ns")
    cocotb.start_soon(clock.start())

    dut.ui_in.value  = 0
    dut.uio_in.value = 0
    dut.ena.value    = 1
    dut.rst_n.value  = 0

    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 500)

    # In GL simulation every signal (including hardwired-0 outputs) starts
    # as X because gate cells initialise to unknown state.
    # NEVER use int() on a LogicArray that may contain X — it raises ValueError.
    # Use .is_resolvable first, then check the value.

    assert dut.uio_out.value.is_resolvable, \
        f"uio_out has X/Z after reset: {dut.uio_out.value}"
    assert dut.uio_oe.value.is_resolvable, \
        f"uio_oe has X/Z after reset: {dut.uio_oe.value}"

    assert dut.uio_out.value == 0, \
        f"uio_out should be 0, got {dut.uio_out.value}"
    assert dut.uio_oe.value == 0, \
        f"uio_oe should be 0, got {dut.uio_oe.value}"

    dut._log.info(f"PASSED — uio_out={dut.uio_out.value} uio_oe={dut.uio_oe.value}")
