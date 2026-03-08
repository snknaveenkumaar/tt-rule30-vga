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
  // 64-cell Rule-30 automaton
  // 640 pixels / 64 cells = exactly 10 pixels per cell
  // hpos[9:4] gives bits 9..4 = hpos/16... NO.
  // hpos[9:4] = hpos >> 4 = hpos/16 → 40 cells. Wrong.
  // hpos[9:3] = hpos/8 → 80 cells shown (out of 128). Bug!
  //
  // FIX: Use 64-cell state. hpos[9:4] = hpos/16 → 40 cells. Still wrong.
  // Cleanest power-of-2 fix: 128-cell state, display only cells 0..79
  // by using hpos[9:3], but the right edge (cells 80-127) never appears.
  // Instead: shrink to 64-cell state, map with hpos[9:3] giving cell 0-79
  // and clamp: if cell >= 64 → background.
  //
  // Best solution: keep 128-cell state but correctly map all 128 cells
  // across 640px. Since 640/128=5 (exact), we need cell = hpos/5.
  // Implement with a cell counter that increments every 5 pixels.
  // =====================================================
  reg [127:0] state;
  wire [127:0] next_state;

  // Rule 30: new[i] = state[i+1] XOR (state[i] OR state[i-1])
  // With state[0]=rightmost, state[127]=leftmost:
  //   left  shift = state << 1 (brings higher-index bits down)
  //   right shift = state >> 1
  // Boundary: edges wrap to 0 (shift naturally handles this)
  assign next_state = (state << 1) ^ (state | (state >> 1));

  // Update once per completed display row
  wire new_row = (hpos == 10'd639) && (vpos < 10'd480);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      state <= (128'b1 << 64);  // center seed
    else if (new_row)
      state <= next_state;
  end

  // =====================================================
  // Cell counter: 128 cells across 640 pixels = 5px/cell
  // Increment cell index every 5 clock ticks of hpos
  // =====================================================
  reg [6:0] cell_idx;    // 0..127
  reg [2:0] px_count;    // 0..4 pixel sub-counter

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      cell_idx <= 7'd0;
      px_count <= 3'd0;
    end else begin
      if (hpos == 10'd639) begin
        // End of line: reset for next row
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

  // =====================================================
  // Pixel and colour logic
  // =====================================================
  wire cell_on   = display_on && state[cell_idx];
  wire [7:0] depth = vpos[8:1];   // 0-255 gradient over vertical
  wire [1:0] pal   = ui_in[1:0];

  // Colour palettes (RGB222)
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
  // VGA output mapping (RGB222, TinyTapeout pinout)
  // =====================================================
  assign uo_out[0] = r_out[1];
  assign uo_out[4] = r_out[0];
  assign uo_out[1] = g_out[1];
  assign uo_out[5] = g_out[0];
  assign uo_out[2] = b_out[1];
  assign uo_out[6] = b_out[0];
  assign uo_out[3] = vsync;
  assign uo_out[7] = hsync;

  // Unused pins
  assign uio_out = 8'b0;
  assign uio_oe  = 8'b0;
  wire _unused = &{ena, uio_in, ui_in[7:2], 1'b0};

endmodule
