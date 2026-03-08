`ifndef HVSYNC_GENERATOR_H
`define HVSYNC_GENERATOR_H

// Standard 640x480 @ 60Hz VGA timing generator
// Pixel clock: 25.175 MHz (use 25 MHz)
module hvsync_generator(
    input  wire clk,
    input  wire reset,
    output reg  hsync,
    output reg  vsync,
    output wire display_on,
    output reg  [9:0] hpos,
    output reg  [9:0] vpos
);

  // ── Horizontal timing (pixels) ──────────────────────
  parameter H_DISPLAY    = 640;
  parameter H_FRONT      = 16;
  parameter H_SYNC       = 96;
  parameter H_BACK       = 48;
  parameter H_MAX        = H_DISPLAY + H_FRONT + H_SYNC + H_BACK - 1; // 799

  parameter H_SYNC_START = H_DISPLAY + H_FRONT;          // 656
  parameter H_SYNC_END   = H_DISPLAY + H_FRONT + H_SYNC - 1; // 751

  // ── Vertical timing (lines) ──────────────────────────
  parameter V_DISPLAY    = 480;
  parameter V_BOTTOM     = 10;   // front porch (below active)
  parameter V_SYNC       = 2;
  parameter V_TOP        = 33;   // back porch  (above active)
  parameter V_MAX        = V_DISPLAY + V_BOTTOM + V_SYNC + V_TOP - 1; // 524

  parameter V_SYNC_START = V_DISPLAY + V_BOTTOM;          // 490
  parameter V_SYNC_END   = V_DISPLAY + V_BOTTOM + V_SYNC - 1; // 491

  // ── Horizontal counter ───────────────────────────────
  always @(posedge clk) begin
    if (reset)
      hpos <= 10'd0;
    else if (hpos == H_MAX)
      hpos <= 10'd0;
    else
      hpos <= hpos + 10'd1;
  end

  // ── Vertical counter (advances at end of each line) ──
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

  // ── Sync signals ─────────────────────────────────────
  // Registered for clean output; compare against CURRENT counters.
  // hsync: active-low during sync pulse
  // vsync: active-low during sync pulse
  always @(posedge clk) begin
    if (reset) begin
      hsync <= 1'b1;
      vsync <= 1'b1;
    end else begin
      // hsync uses hpos value that will be current NEXT cycle (post-increment).
      // Because hpos updates in the same always block above (non-blocking),
      // both always blocks see the SAME pre-increment hpos in this cycle.
      // So registered output is effectively 1 cycle delayed — acceptable for VGA.
      hsync <= ~((hpos >= H_SYNC_START) && (hpos <= H_SYNC_END));
      vsync <= ~((vpos >= V_SYNC_START) && (vpos <= V_SYNC_END));
    end
  end

  // ── Active display window ─────────────────────────────
  assign display_on = (hpos < H_DISPLAY) && (vpos < V_DISPLAY);

endmodule

`endif
