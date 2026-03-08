import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles


@cocotb.test()
async def rule30_vga_smoke_test(dut):
    """Smoke test: reset, release, verify outputs are valid and stable."""

    clock = Clock(dut.clk, 40, units="ns")  # 25 MHz
    cocotb.start_soon(clock.start())

    # Initialize inputs
    dut.ena.value   = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value  = 0

    # Hold reset for 10 cycles
    await ClockCycles(dut.clk, 10)

    # Release reset
    dut.rst_n.value = 1

    # Run for 500 cycles
    await ClockCycles(dut.clk, 500)

    # Basic output validity
    assert dut.uo_out.value.is_resolvable,  "uo_out contains X/Z after reset"
    assert dut.uio_out.value == 0,          "uio_out should remain 0"
    assert dut.uio_oe.value  == 0,          "uio_oe should remain 0"

    cocotb.log.info("Smoke test passed")


@cocotb.test()
async def rule30_vga_palette_test(dut):
    """Test all four palette selections via ui_in[1:0]."""

    clock = Clock(dut.clk, 40, units="ns")
    cocotb.start_soon(clock.start())

    dut.ena.value    = 1
    dut.uio_in.value = 0
    dut.rst_n.value  = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    for pal in range(4):
        dut.ui_in.value = pal
        await ClockCycles(dut.clk, 200)
        assert dut.uo_out.value.is_resolvable, \
            f"uo_out invalid for palette {pal}"
        cocotb.log.info(f"Palette {pal}: uo_out = {dut.uo_out.value}")

    cocotb.log.info("Palette test passed")


@cocotb.test()
async def rule30_vga_full_frame_test(dut):
    """
    Run for a full VGA frame (800 * 525 = 420 000 pixel clocks at 25 MHz)
    and verify outputs remain valid throughout.
    """

    clock = Clock(dut.clk, 40, units="ns")
    cocotb.start_soon(clock.start())

    dut.ena.value    = 1
    dut.ui_in.value  = 0
    dut.uio_in.value = 0
    dut.rst_n.value  = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    # One full frame = 800 * 525 cycles
    FRAME_CYCLES = 800 * 525
    SAMPLE_INTERVAL = 8400  # check every ~10 lines

    for i in range(0, FRAME_CYCLES, SAMPLE_INTERVAL):
        await ClockCycles(dut.clk, SAMPLE_INTERVAL)
        assert dut.uo_out.value.is_resolvable, \
            f"uo_out has X/Z at cycle ~{i}"
        assert dut.uio_out.value == 0, f"uio_out non-zero at cycle ~{i}"
        assert dut.uio_oe.value  == 0, f"uio_oe non-zero at cycle ~{i}"

    cocotb.log.info("Full-frame test passed")
