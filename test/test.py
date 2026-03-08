import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
import os


@cocotb.test()
async def test_rule30_vga(dut):
    """Smoke test for Rule-30 VGA - works for both RTL and GL simulation."""

    clock = Clock(dut.clk, 40, units="ns")  # 25 MHz
    cocotb.start_soon(clock.start())

    dut.ui_in.value  = 0
    dut.uio_in.value = 0
    dut.ena.value    = 1
    dut.rst_n.value  = 0

    # GL sim needs more reset cycles for cells to initialize
    is_gl = os.environ.get("GL_TEST", "0") == "1"
    reset_cycles = 100 if is_gl else 10
    run_cycles   = 5000 if is_gl else 500

    await ClockCycles(dut.clk, reset_cycles)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, run_cycles)

    # uio pins are hardwired to 0 — must always pass
    assert int(dut.uio_out.value) == 0, \
        f"uio_out should be 0, got {dut.uio_out.value}"
    assert int(dut.uio_oe.value) == 0, \
        f"uio_oe should be 0, got {dut.uio_oe.value}"

    # uo_out carries live VGA signals — just verify no X/Z present
    assert dut.uo_out.value.is_resolvable, \
        f"uo_out has unresolvable bits after {run_cycles} cycles: {dut.uo_out.value}"

    dut._log.info(
        f"PASSED (gl={is_gl}, reset={reset_cycles}, run={run_cycles}, "
        f"uo_out={dut.uo_out.value})"
    )
