`define BASIC 1
`define SPLIT_INOUTS
/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

// for tinytapeout we target ice40, but then replace SB_IO cells
// by a custom implementation
`define ICE40 1
`define SIM_SB_IO 1

module tt_um_silice (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // https://tinytapeout.com/specs/pinouts/

  M_main main(

    .in_ui(ui_in),
    .out_uo(uo_out),

    .inout_uio_i(uio_in),
    .inout_uio_o(uio_out),
    .inout_uio_oe(uio_oe),

    .in_run(1'b1),
    .reset(~rst_n),
    .clock(clk)
  );

  //              vvvvv inputs when in reset to allow PMOD external takeover
  // assign uio_oe = rst_n ? {1'b1,1'b1,main_uio_oe[3],main_uio_oe[2],1'b1,main_uio_oe[1],main_uio_oe[0],1'b1} : 8'h00;

endmodule

module M_vga_M_main_demo_vga (
out_vga_hs,
out_vga_vs,
out_active,
out_vblank,
out_vga_x,
out_vga_y,
reset,
out_clock,
clock
);
output  [0:0] out_vga_hs;
output  [0:0] out_vga_vs;
output  [0:0] out_active;
output  [0:0] out_vblank;
output  [11:0] out_vga_x;
output  [10:0] out_vga_y;
input reset;
output out_clock;
input clock;
assign out_clock = clock;

reg signed [10:0] _d_xcount;
reg signed [10:0] _q_xcount;
reg signed [9:0] _d_ycount;
reg signed [9:0] _q_ycount;
reg  [0:0] _d_active_h;
reg  [0:0] _q_active_h;
reg  [0:0] _d_active_v;
reg  [0:0] _q_active_v;
reg  [0:0] _d_vga_hs;
reg  [0:0] _q_vga_hs;
reg  [0:0] _d_vga_vs;
reg  [0:0] _q_vga_vs;
reg  [0:0] _d_active;
reg  [0:0] _q_active;
reg  [0:0] _d_vblank;
reg  [0:0] _q_vblank;
reg  [11:0] _d_vga_x;
reg  [11:0] _q_vga_x;
reg  [10:0] _d_vga_y;
reg  [10:0] _q_vga_y;
assign out_vga_hs = _q_vga_hs;
assign out_vga_vs = _q_vga_vs;
assign out_active = _q_active;
assign out_vblank = _q_vblank;
assign out_vga_x = _q_vga_x;
assign out_vga_y = _q_vga_y;



`ifdef FORMAL
initial begin
assume(reset);
end
`endif
always @* begin
_d_xcount = _q_xcount;
_d_ycount = _q_ycount;
_d_active_h = _q_active_h;
_d_active_v = _q_active_v;
_d_vga_hs = _q_vga_hs;
_d_vga_vs = _q_vga_vs;
_d_active = _q_active;
_d_vblank = _q_vblank;
_d_vga_x = _q_vga_x;
_d_vga_y = _q_vga_y;
// _always_pre
// __block_1
_d_active_h = _q_xcount==0 ? 1:_q_xcount==640 ? 0:_q_active_h;

_d_active_v = _q_ycount==0 ? 1:_q_ycount==480 ? 0:_q_active_v;

_d_active = _d_active_h&&_d_active_v;

_d_vga_x = _d_active_h ? _q_xcount:0;

_d_vga_y = _d_active_v ? _q_ycount:0;

_d_vga_hs = _q_xcount==-144 ? 0:_q_xcount==-49 ? 1:_q_vga_hs;

_d_vga_vs = _q_ycount==-35 ? 0:_q_ycount==-34 ? 1:_q_vga_vs;

_d_vblank = _q_ycount[9+:1];

if (_q_xcount==640) begin
// __block_2
// __block_4
_d_xcount = $signed(-159);

if (_q_ycount==480) begin
// __block_5
// __block_7
_d_ycount = $signed(-44);

// __block_8
end else begin
// __block_6
// __block_9
_d_ycount = _q_ycount+1;

// __block_10
end
// 'after'
// __block_11
// __block_12
end else begin
// __block_3
// __block_13
_d_xcount = _q_xcount+1;

// __block_14
end
// 'after'
// __block_15
// __block_16
// _always_post
// pipeline stage triggers
end

always @(posedge clock) begin
_q_xcount <= (reset) ? 0 : _d_xcount;
_q_ycount <= (reset) ? 0 : _d_ycount;
_q_active_h <= (reset) ? 0 : _d_active_h;
_q_active_v <= (reset) ? 0 : _d_active_v;
_q_vga_hs <= _d_vga_hs;
_q_vga_vs <= _d_vga_vs;
_q_active <= _d_active;
_q_vblank <= _d_vblank;
_q_vga_x <= _d_vga_x;
_q_vga_y <= _d_vga_y;
end

endmodule


module M_vga_demo_M_main_demo (
out_video_r,
out_video_g,
out_video_b,
out_video_hs,
out_video_vs,
reset,
out_clock,
clock
);
output  [1:0] out_video_r;
output  [1:0] out_video_g;
output  [1:0] out_video_b;
output  [0:0] out_video_hs;
output  [0:0] out_video_vs;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire  [0:0] _w_vga_vga_hs;
wire  [0:0] _w_vga_vga_vs;
wire  [0:0] _w_vga_active;
wire  [0:0] _w_vga_vblank;
wire  [11:0] _w_vga_vga_x;
wire  [10:0] _w_vga_vga_y;
reg  [1:0] _t_video_r;
reg  [1:0] _t_video_g;
reg  [1:0] _t_video_b;

assign out_video_r = _t_video_r;
assign out_video_g = _t_video_g;
assign out_video_b = _t_video_b;
assign out_video_hs = _w_vga_vga_hs;
assign out_video_vs = _w_vga_vga_vs;
M_vga_M_main_demo_vga vga (
.out_vga_hs(_w_vga_vga_hs),
.out_vga_vs(_w_vga_vga_vs),
.out_active(_w_vga_active),
.out_vblank(_w_vga_vblank),
.out_vga_x(_w_vga_vga_x),
.out_vga_y(_w_vga_vga_y),
.reset(reset),
.clock(clock));



`ifdef FORMAL
initial begin
assume(reset);
end
`endif
always @* begin
// _always_pre
// __block_1
_t_video_r = _w_vga_active ? _w_vga_vga_x:0;

_t_video_g = _w_vga_active ? _w_vga_vga_y:0;

_t_video_b = 0;

// __block_2
// _always_post
// pipeline stage triggers
end

always @(posedge clock) begin
end

endmodule


module M_main (
in_ui,
out_uo,
inout_uio_oe,
inout_uio_i,
inout_uio_o,
in_run,
out_done,
reset,
out_clock,
clock
);
input  [7:0] in_ui;
output  [7:0] out_uo;
output  [7:0] inout_uio_oe;
input  [7:0] inout_uio_i;
output  [7:0] inout_uio_o;
input in_run;
output out_done;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
wire  [1:0] _w_demo_video_r;
wire  [1:0] _w_demo_video_g;
wire  [1:0] _w_demo_video_b;
wire  [0:0] _w_demo_video_hs;
wire  [0:0] _w_demo_video_vs;

reg  [7:0] _d_uio_oenable;
reg  [7:0] _q_uio_oenable;
reg  [7:0] _d_uo;
reg  [7:0] _q_uo;
assign out_uo = _d_uo;
assign out_done = 0;
M_vga_demo_M_main_demo demo (
.out_video_r(_w_demo_video_r),
.out_video_g(_w_demo_video_g),
.out_video_b(_w_demo_video_b),
.out_video_hs(_w_demo_video_hs),
.out_video_vs(_w_demo_video_vs),
.reset(reset),
.clock(clock));


assign inout_uio_oe[0] = _q_uio_oenable[0];
assign inout_uio_o[0] = 1'b0;
assign inout_uio_oe[1] = _q_uio_oenable[1];
assign inout_uio_o[1] = 1'b0;
assign inout_uio_oe[2] = _q_uio_oenable[2];
assign inout_uio_o[2] = 1'b0;
assign inout_uio_oe[3] = _q_uio_oenable[3];
assign inout_uio_o[3] = 1'b0;
assign inout_uio_oe[4] = _q_uio_oenable[4];
assign inout_uio_o[4] = 1'b0;
assign inout_uio_oe[5] = _q_uio_oenable[5];
assign inout_uio_o[5] = 1'b0;
assign inout_uio_oe[6] = _q_uio_oenable[6];
assign inout_uio_o[6] = 1'b0;
assign inout_uio_oe[7] = _q_uio_oenable[7];
assign inout_uio_o[7] = 1'b0;

`ifdef FORMAL
initial begin
assume(reset);
end
`endif
always @* begin
_d_uio_oenable = _q_uio_oenable;
_d_uo = _q_uo;
// _always_pre
// __block_1
_d_uo[7+:1] = _w_demo_video_hs;

_d_uo[3+:1] = _w_demo_video_vs;

_d_uo[4+:1] = _w_demo_video_r[0+:1];

_d_uo[0+:1] = _w_demo_video_r[1+:1];

_d_uo[5+:1] = _w_demo_video_g[0+:1];

_d_uo[1+:1] = _w_demo_video_g[1+:1];

_d_uo[6+:1] = _w_demo_video_b[0+:1];

_d_uo[2+:1] = _w_demo_video_b[1+:1];

_d_uio_oenable = 8'b0;

// __block_2
// _always_post
// pipeline stage triggers
end

always @(posedge clock) begin
_q_uio_oenable <= _d_uio_oenable;
_q_uo <= _d_uo;
end

endmodule

