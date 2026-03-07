`ifndef HVSYNC_GENERATOR_H
`define HVSYNC_GENERATOR_H

module hvsync_generator(
    input wire clk,
    input wire reset,
    output reg hsync,
    output reg vsync,
    output wire display_on,
    output reg [9:0] hpos,
    output reg [9:0] vpos
);

  parameter H_DISPLAY = 640;
  parameter H_BACK    = 48;
  parameter H_FRONT   = 16;
  parameter H_SYNC    = 96;
  parameter V_DISPLAY = 480;
  parameter V_TOP     = 33;
  parameter V_BOTTOM  = 10;
  parameter V_SYNC    = 2;

  parameter H_SYNC_START = H_DISPLAY + H_FRONT;
  parameter H_SYNC_END   = H_DISPLAY + H_FRONT + H_SYNC - 1;
  parameter H_MAX        = H_DISPLAY + H_BACK + H_FRONT + H_SYNC - 1;
  parameter V_SYNC_START = V_DISPLAY + V_BOTTOM;
  parameter V_SYNC_END   = V_DISPLAY + V_BOTTOM + V_SYNC - 1;
  parameter V_MAX        = V_DISPLAY + V_TOP + V_BOTTOM + V_SYNC - 1;

  // Horizontal counter
  always @(posedge clk) begin
    if (reset)
      hpos <= 10'd0;
    else if (hpos == H_MAX)
      hpos <= 10'd0;
    else
      hpos <= hpos + 10'd1;
  end

  // Vertical counter
  always @(posedge clk) begin
    if (reset)
      vpos <= 10'd0;
    else if (hpos == H_MAX) begin
      if (vpos == V_MAX)
        vpos <= 10'd0;
      else
        vpos <= vpos + 10'd1;
    end
  end

  // Sync signals (registered for better timing)
  always @(posedge clk) begin
    hsync <= ~(hpos >= H_SYNC_START && hpos <= H_SYNC_END);
    vsync <= ~(vpos >= V_SYNC_START && vpos <= V_SYNC_END);
  end

  assign display_on = (hpos < H_DISPLAY) && (vpos < V_DISPLAY);

endmodule
`endif
