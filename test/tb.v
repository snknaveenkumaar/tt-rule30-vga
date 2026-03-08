`default_nettype none
`timescale 1ns / 1ps

/*
 * Standard TinyTapeout testbench wrapper.
 * TOPLEVEL in Makefile = "tb"
 * cocotb accesses signals as dut.ui_in, dut.uo_out, etc.
 */
module tb ();

  // Clock and reset
  reg clk;
  reg rst_n;
  reg ena;

  // Design ports
  reg  [7:0] ui_in;
  wire [7:0] uo_out;
  reg  [7:0] uio_in;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

  // Dump waveforms
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #1;
  end

  // Instantiate the design under test
  tt_um_rule30_vga user_project (
    .ui_in  (ui_in),
    .uo_out (uo_out),
    .uio_in (uio_in),
    .uio_out(uio_out),
    .uio_oe (uio_oe),
    .ena    (ena),
    .clk    (clk),
    .rst_n  (rst_n)
  );

endmodule
