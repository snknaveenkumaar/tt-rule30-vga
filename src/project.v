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

  // 128-cell Rule-30 automaton
  // Rule 30: new[i] = left XOR (center OR right)
  reg [127:0] state;
  wire [127:0] next_state;
  assign next_state = (state << 1) ^ (state | (state >> 1));

  wire new_row = (hpos == 10'd639) && (vpos < 10'd480);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      state <= (128'b1 << 64);
    else if (new_row)
      state <= next_state;
  end

  // Cell counter: 128 cells across 640 pixels = 5px per cell
  reg [6:0] cell_idx;
  reg [2:0] px_count;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      cell_idx <= 7'd0;
      px_count <= 3'd0;
    end else begin
      if (hpos == 10'd639) begin
        cell_idx <= 7'd0;
        px_count <= 3'd0;
      end else if (display_on || hpos < 10'd640) begin
        if (px_count == 3'd4) begin
          px_count <= 3'd0;
          cell_idx <= cell_idx + 7'd1;
        end else begin
          px_count <= px_count + 3'd1;
        end
      end
    end
  end

  wire cell_on = display_on && state[cell_idx];
  wire [1:0] pal = ui_in[1:0];

  // FIX: only declare bits actually used in palette logic (7,6,5 of vpos)
  // Old: wire [7:0] depth = vpos[8:1] — bits [4:0] unused → linter warning
  // New: wire [2:0] depth = vpos[8:6] — only 3 bits needed, all used
  wire [2:0] depth = vpos[8:6];

  // Colour palettes (RGB222)
  wire [1:0] r_out =
    !display_on ? 2'b00 :
    !cell_on    ? 2'b00 :
    (pal==2'b00) ? 2'b00 :
    (pal==2'b01) ? (depth[2] ? 2'b11 : depth[1] ? 2'b11 : 2'b10) :
    (pal==2'b10) ? 2'b00 :
                   depth[2:1];

  wire [1:0] g_out =
    !display_on ? 2'b00 :
    !cell_on    ? 2'b00 :
    (pal==2'b00) ? (depth[2] ? 2'b11 : 2'b10) :
    (pal==2'b01) ? (depth[2] ? 2'b01 : depth[1] ? 2'b10 : 2'b11) :
    (pal==2'b10) ? 2'b11 :
                   (~depth[2:1]);

  wire [1:0] b_out =
    !display_on ? 2'b00 :
    !cell_on    ? 2'b00 :
    (pal==2'b00) ? 2'b00 :
    (pal==2'b01) ? 2'b00 :
    (pal==2'b10) ? 2'b11 :
                   depth[1:0];

  // VGA output (RGB222, TinyTapeout pinout)
  assign uo_out[0] = r_out[1];
  assign uo_out[4] = r_out[0];
  assign uo_out[1] = g_out[1];
  assign uo_out[5] = g_out[0];
  assign uo_out[2] = b_out[1];
  assign uo_out[6] = b_out[0];
  assign uo_out[3] = vsync;
  assign uo_out[7] = hsync;

  assign uio_out = 8'b0;
  assign uio_oe  = 8'b0;
  wire _unused = &{ena, uio_in, ui_in[7:2], 1'b0};

endmodule
