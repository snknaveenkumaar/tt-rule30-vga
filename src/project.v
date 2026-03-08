`default_nettype none

module tt_um_rule30_vga (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

  // VGA signals
  wire hsync, vsync, display_on;
  wire [9:0] hpos, vpos;

  hvsync_generator hvsync_gen (
    .clk(clk),
    .reset(~rst_n),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(display_on),
    .hpos(hpos),
    .vpos(vpos)
  );

  // =====================================================
  // 128-cell Rule-30 automaton (smaller to fit TT tile)
  // =====================================================

  reg [127:0] state;

  wire [127:0] next_state;

  // Rule 30: left XOR (center OR right)
  assign next_state = (state << 1) ^ (state | (state >> 1));

  // update once per VGA row
  wire new_row = (hpos == 639) && (vpos < 480);

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      state <= (128'b1 << 64);  // center seed
    else if (new_row)
      state <= next_state;
  end

  // =====================================================
  // Pixel mapping
  // 128 cells across 640 pixels → 5 pixels per cell
  // =====================================================

  wire cell_on = display_on && state[hpos[9:3]];

  wire [7:0] depth = vpos[8:1];
  wire [1:0] pal = ui_in[1:0];

  // =====================================================
  // Colour palettes
  // =====================================================

  wire [1:0] r_out =
    !display_on ? 2'b00 :
    !cell_on    ? 2'b00 :
    (pal==2'b00) ? 2'b00 :
    (pal==2'b01) ? (depth[7] ? 2'b11 : depth[6] ? 2'b11 : 2'b10) :
    (pal==2'b10) ? 2'b00 :
                   depth[7:6];

  wire [1:0] g_out =
    !display_on ? 2'b00 :
    !cell_on    ? 2'b00 :
    (pal==2'b00) ? (depth[7] ? 2'b11 : 2'b10) :
    (pal==2'b01) ? (depth[7] ? 2'b01 : depth[6] ? 2'b10 : 2'b11) :
    (pal==2'b10) ? 2'b11 :
                   (~depth[7:6]);

  wire [1:0] b_out =
    !display_on ? 2'b00 :
    !cell_on    ? 2'b00 :
    (pal==2'b00) ? 2'b00 :
    (pal==2'b01) ? 2'b00 :
    (pal==2'b10) ? 2'b11 :
                   depth[6:5];

  // =====================================================
  // VGA output mapping (RGB222)
  // =====================================================

  assign uo_out[0] = r_out[1];
  assign uo_out[4] = r_out[0];

  assign uo_out[1] = g_out[1];
  assign uo_out[5] = g_out[0];

  assign uo_out[2] = b_out[1];
  assign uo_out[6] = b_out[0];

  assign uo_out[3] = vsync;
  assign uo_out[7] = hsync;

  // unused pins
  assign uio_out = 8'b0;
  assign uio_oe  = 8'b0;

  wire _unused = &{ena, uio_in, ui_in[7:2], 1'b0};

endmodule
