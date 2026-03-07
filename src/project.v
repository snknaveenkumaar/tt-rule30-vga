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

  // Rule-30 state
  reg [319:0] state;
  reg [319:0] next_state;

  integer i;

  always @(*) begin
    next_state[0]   = 1'b0 ^ (state[0] | state[1]);
    next_state[319] = state[318] ^ (state[319] | 1'b0);

    for (i = 1; i < 319; i = i + 1)
      next_state[i] = state[i-1] ^ (state[i] | state[i+1]);
  end

  wire new_row = (hpos == 639) && (vpos < 480);

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= 320'b1 << 160;
    end else if (new_row) begin
      state <= next_state;
    end
  end

  wire cell_on = display_on && state[hpos[9:1]];

  wire [7:0] depth = vpos[8:1];
  wire [1:0] pal = ui_in[1:0];

  wire [1:0] r_out = cell_on ? depth[7:6] : 2'b00;
  wire [1:0] g_out = cell_on ? depth[6:5] : 2'b00;
  wire [1:0] b_out = cell_on ? depth[5:4] : 2'b00;

  assign uo_out[0] = r_out[1];
  assign uo_out[4] = r_out[0];
  assign uo_out[1] = g_out[1];
  assign uo_out[5] = g_out[0];
  assign uo_out[2] = b_out[1];
  assign uo_out[6] = b_out[0];
  assign uo_out[3] = vsync;
  assign uo_out[7] = hsync;

  assign uio_out = 0;
  assign uio_oe  = 0;

  wire _unused = &{ena, uio_in, ui_in[7:2], 1'b0};

endmodule
