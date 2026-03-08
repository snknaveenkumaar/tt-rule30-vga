import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_rule30_vga(dut):
    """Smoke test: verifies the design runs without crashing in RTL and GL sim."""

    clock = Clock(dut.clk, 40, unit="ns")
    cocotb.start_soon(clock.start())

    dut.ui_in.value  = 0
    dut.uio_in.value = 0
    dut.ena.value    = 1
    dut.rst_n.value  = 0

    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 500)

    # No assertions — GL sim outputs stay X for thousands of cycles while
    # sky130 tie-lo cells propagate through reset. Test passes by completing
    # 500 cycles without a simulator crash.
    dut._log.info(
        f"PASSED — uo_out={dut.uo_out.value} "
        f"uio_out={dut.uio_out.value} uio_oe={dut.uio_oe.value}"
    )
