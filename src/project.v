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

module tt_um_whynot (
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

  // register reset
  reg rst_n_q;
  always @(posedge clk) begin
    rst_n_q <= rst_n;
  end

  M_main main(

    .in_ui(ui_in),
    .out_uo(uo_out),

    .inout_uio_i(uio_in),
    .inout_uio_o(uio_out),
    .inout_uio_oe(uio_oe),

    .in_run(1'b1),
    .reset(~rst_n_q),
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

// ==== defines ====
`undef  _c___block_1_next_sample
`define _c___block_1_next_sample (1'((_q_clock_count[0+:9]==0)))
`undef  _c___block_1_sum
`define _c___block_1_sum (9'(_w_squ_wave))
`undef  _c___block_1_next_inc
`define _c___block_1_next_inc (1'(`_c___block_1_next_sample&&(_q_rythm_count[0+:8]==8'd0)))
`undef  _c___block_1_next_note
`define _c___block_1_next_note (1'(_q_rythm_count[8+:5]==5'd25))
`undef  _c___block_1_smpl
`define _c___block_1_smpl (7'($unsigned($signed(_t_audio8)+$signed(8'd64))))
// ===============

module M_music_M_main_demo_zic (
out_audio8,
out_audio1,
reset,
out_clock,
clock
);
output signed [7:0] out_audio8;
output  [0:0] out_audio1;
input reset;
output out_clock;
input clock;
assign out_clock = clock;
reg signed [7:0] _t_audio8;
reg  [0:0] _t_audio1;
wire signed [7:0] _w_squ_wave;

reg  [5:0] _d_idx;
reg  [5:0] _q_idx;
reg  [8:0] _d_clock_count;
reg  [8:0] _q_clock_count;
reg  [12:0] _d_rythm_count;
reg  [12:0] _q_rythm_count;
reg  [12:0] _d_qpos;
reg  [12:0] _q_qpos;
reg  [5:0] _d_squ_env;
reg  [5:0] _q_squ_env;
assign out_audio8 = _t_audio8;
assign out_audio1 = _t_audio1;


assign _w_squ_wave = _q_qpos[12+:1] ? _q_squ_env[3+:3]:-_q_squ_env[3+:3];

`ifdef FORMAL
initial begin
assume(reset);
end
`endif
always @* begin
_d_idx = _q_idx;
_d_clock_count = _q_clock_count;
_d_rythm_count = _q_rythm_count;
_d_qpos = _q_qpos;
_d_squ_env = _q_squ_env;
// _always_pre
// __block_1


_t_audio8 = ($signed(`_c___block_1_sum)>>>1);

_d_qpos = `_c___block_1_next_sample ? (_q_qpos+_c_keys[_q_idx]):_q_qpos;



_d_idx = `_c___block_1_next_note ? (_q_idx==7'd95 ? 7'd32:_q_idx+1):_q_idx;

_d_squ_env = `_c___block_1_next_note ? {6{|_c_keys[_d_idx]}}:(`_c___block_1_next_inc ? ((_q_squ_env!=0) ? _q_squ_env-1:0):_q_squ_env);

_d_rythm_count = `_c___block_1_next_note ? 0:(`_c___block_1_next_sample ? _q_rythm_count+1:_q_rythm_count);


_t_audio1 = _q_clock_count[0+:7]<`_c___block_1_smpl ? 1'b1:1'b0;

_d_clock_count = (_q_clock_count+1);

// __block_2
// _always_post
// pipeline stage triggers
end
// ==== wires ====
wire  [6:0] _c_keys[63:0];
assign _c_keys[0] = 10;
assign _c_keys[1] = 10;
assign _c_keys[2] = 21;
assign _c_keys[3] = 10;
assign _c_keys[4] = 10;
assign _c_keys[5] = 18;
assign _c_keys[6] = 10;
assign _c_keys[7] = 10;
assign _c_keys[8] = 15;
assign _c_keys[9] = 10;
assign _c_keys[10] = 10;
assign _c_keys[11] = 15;
assign _c_keys[12] = 10;
assign _c_keys[13] = 10;
assign _c_keys[14] = 15;
assign _c_keys[15] = 15;
assign _c_keys[16] = 10;
assign _c_keys[17] = 10;
assign _c_keys[18] = 21;
assign _c_keys[19] = 10;
assign _c_keys[20] = 10;
assign _c_keys[21] = 18;
assign _c_keys[22] = 10;
assign _c_keys[23] = 10;
assign _c_keys[24] = 15;
assign _c_keys[25] = 10;
assign _c_keys[26] = 10;
assign _c_keys[27] = 15;
assign _c_keys[28] = 0;
assign _c_keys[29] = 10;
assign _c_keys[30] = 10;
assign _c_keys[31] = 21;
assign _c_keys[32] = 10;
assign _c_keys[33] = 10;
assign _c_keys[34] = 18;
assign _c_keys[35] = 10;
assign _c_keys[36] = 10;
assign _c_keys[37] = 15;
assign _c_keys[38] = 10;
assign _c_keys[39] = 10;
assign _c_keys[40] = 15;
assign _c_keys[41] = 10;
assign _c_keys[42] = 10;
assign _c_keys[43] = 15;
assign _c_keys[44] = 15;
assign _c_keys[45] = 10;
assign _c_keys[46] = 10;
assign _c_keys[47] = 21;
assign _c_keys[48] = 10;
assign _c_keys[49] = 10;
assign _c_keys[50] = 18;
assign _c_keys[51] = 10;
assign _c_keys[52] = 10;
assign _c_keys[53] = 15;
assign _c_keys[54] = 10;
assign _c_keys[55] = 10;
assign _c_keys[56] = 15;
assign _c_keys[57] = 0;
assign _c_keys[58] = 0;
assign _c_keys[59] = 0;
assign _c_keys[60] = 0;
assign _c_keys[61] = 0;
assign _c_keys[62] = 0;
assign _c_keys[63] = 0;
// ===============

always @(posedge clock) begin
_q_idx <= (reset) ? 0 : _d_idx;
_q_clock_count <= (reset) ? 0 : _d_clock_count;
_q_rythm_count <= (reset) ? 0 : _d_rythm_count;
_q_qpos <= (reset) ? 0 : _d_qpos;
_q_squ_env <= (reset) ? 0 : _d_squ_env;
end

endmodule

// ==== defines ====
`undef  _c___block_1_pidA
`define _c___block_1_pidA (5'(_c_doomhead[_q_addr]&{5{_q_clip}}))
`undef  _c___block_1_palA
`define _c___block_1_palA (18'(_c_sub666[`_c___block_1_pidA]))
`undef  _c_i
`define _c_i (5'((_t_ru[2+:5]+_q_frame[0+:5])))
`undef  _c_j
`define _c_j (5'(_t_rv[2+:5]))
`undef  _c___block_1_bval4
`define _c___block_1_bval4 (4'({_t___block_1_q4[0+:1],_t___block_1_p4[0+:1],_t___block_1_q4[1+:1],_t___block_1_p4[1+:1]}^{4{_q_frame[0+:1]}}))
`undef  _c___block_1_frame_tick
`define _c___block_1_frame_tick (1'(_q_prev_vs&~_w_vga_vga_vs))
`undef  _c___block_1_tri
`define _c___block_1_tri (9'({_d_frame[0+:9]^{9{_d_frame[9+:1]}}}))
`undef  _c___block_1_line_tick
`define _c___block_1_line_tick (1'(_q_prev_hs&~_w_vga_vga_hs))
// ===============

module M_vga_demo_M_main_demo (
out_video_r,
out_video_g,
out_video_b,
out_video_hs,
out_video_vs,
out_audio8,
out_audio1,
reset,
out_clock,
clock
);
output  [1:0] out_video_r;
output  [1:0] out_video_g;
output  [1:0] out_video_b;
output  [0:0] out_video_hs;
output  [0:0] out_video_vs;
output  [7:0] out_audio8;
output  [0:0] out_audio1;
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
wire signed [7:0] _w_zic_audio8;
wire  [0:0] _w_zic_audio1;
reg signed [7:0] _t_ru;
reg signed [7:0] _t_rv;
reg  [17:0] _t___block_1_pal;
reg  [3:0] _t___block_1_p4;
reg  [1:0] _t___block_1_q4;
reg  [5:0] _t___block_1_l_r;
reg  [5:0] _t___block_1_l_g;
reg  [5:0] _t___block_1_l_b;
reg  [1:0] _t_video_r;
reg  [1:0] _t_video_g;
reg  [1:0] _t_video_b;
reg  [0:0] _t_video_hs;
reg  [0:0] _t_video_vs;

reg  [0:0] _d_prev_vs;
reg  [0:0] _q_prev_vs;
reg  [0:0] _d_prev_hs;
reg  [0:0] _q_prev_hs;
reg  [9:0] _d_frame;
reg  [9:0] _q_frame;
reg signed [7:0] _d_u;
reg signed [7:0] _q_u;
reg  [14:0] _d_uT;
reg  [14:0] _q_uT;
reg signed [7:0] _d_v;
reg signed [7:0] _q_v;
reg  [14:0] _d_vT;
reg  [14:0] _q_vT;
reg  [0:0] _d_clip;
reg  [0:0] _q_clip;
reg  [9:0] _d_addr;
reg  [9:0] _q_addr;
assign out_video_r = _t_video_r;
assign out_video_g = _t_video_g;
assign out_video_b = _t_video_b;
assign out_video_hs = _t_video_hs;
assign out_video_vs = _t_video_vs;
assign out_audio8 = _w_zic_audio8;
assign out_audio1 = _w_zic_audio1;
M_vga_M_main_demo_vga vga (
.out_vga_hs(_w_vga_vga_hs),
.out_vga_vs(_w_vga_vga_vs),
.out_active(_w_vga_active),
.out_vblank(_w_vga_vblank),
.out_vga_x(_w_vga_vga_x),
.out_vga_y(_w_vga_vga_y),
.reset(reset),
.clock(clock));
M_music_M_main_demo_zic zic (
.out_audio8(_w_zic_audio8),
.out_audio1(_w_zic_audio1),
.reset(reset),
.clock(clock));



`ifdef FORMAL
initial begin
assume(reset);
end
`endif
always @* begin
_d_prev_vs = _q_prev_vs;
_d_prev_hs = _q_prev_hs;
_d_frame = _q_frame;
_d_u = _q_u;
_d_uT = _q_uT;
_d_v = _q_v;
_d_vT = _q_vT;
_d_clip = _q_clip;
_d_addr = _q_addr;
// _always_pre
// __block_1


_t_ru = _q_u-$signed(_q_vT>>8);

_t_rv = $signed(_q_uT>>8)+_q_v;


_d_clip = `_c_i<5'd24;


_d_addr = (`_c_i+{`_c_j,4'b0}+{`_c_j,3'b0});

_t___block_1_pal = `_c___block_1_palA;

_t___block_1_p4 = {_w_vga_vga_y[0+:2],_w_vga_vga_x[0+:2]};

_t___block_1_q4 = _t___block_1_p4[0+:2]^_t___block_1_p4[2+:2];


_t___block_1_l_r = `_c___block_1_pidA==0 ? 0:_t___block_1_pal[14+:4]+`_c___block_1_bval4;

_t___block_1_l_g = `_c___block_1_pidA==0 ? 0:_t___block_1_pal[8+:4]+`_c___block_1_bval4;

_t___block_1_l_b = `_c___block_1_pidA==0 ? 0:_t___block_1_pal[2+:4]+`_c___block_1_bval4;

_t_video_r = _w_vga_active ? _t___block_1_l_r[3+:2]:0;

_t_video_g = _w_vga_active ? _t___block_1_l_g[3+:2]:0;

_t_video_b = _w_vga_active ? _t___block_1_l_b[3+:2]:0;

_t_video_hs = _w_vga_vga_hs;

_t_video_vs = _w_vga_vga_vs;


_d_prev_vs = _w_vga_vga_vs;

_d_frame = `_c___block_1_frame_tick ? (_q_frame+1):_q_frame;



_d_prev_hs = _w_vga_vga_hs;

_d_u = ~_w_vga_vga_hs ? 0:(_q_u+1);

_d_uT = ~_w_vga_vga_hs ? 0:(_q_uT+$signed(`_c___block_1_tri));

_d_v = ~_w_vga_vga_vs ? 0:(`_c___block_1_line_tick ? (_q_v+1):_q_v);

_d_vT = ~_w_vga_vga_vs ? 0:(`_c___block_1_line_tick ? (_q_vT+$signed(`_c___block_1_tri)):_q_vT);

// __block_2
// _always_post
// pipeline stage triggers
end
// ==== wires ====
wire  [4:0] _c_doomhead[695:0];
assign _c_doomhead[0] = 5'h00;
assign _c_doomhead[1] = 5'h00;
assign _c_doomhead[2] = 5'h00;
assign _c_doomhead[3] = 5'h00;
assign _c_doomhead[4] = 5'h00;
assign _c_doomhead[5] = 5'h09;
assign _c_doomhead[6] = 5'h06;
assign _c_doomhead[7] = 5'h06;
assign _c_doomhead[8] = 5'h06;
assign _c_doomhead[9] = 5'h04;
assign _c_doomhead[10] = 5'h02;
assign _c_doomhead[11] = 5'h02;
assign _c_doomhead[12] = 5'h02;
assign _c_doomhead[13] = 5'h02;
assign _c_doomhead[14] = 5'h02;
assign _c_doomhead[15] = 5'h04;
assign _c_doomhead[16] = 5'h06;
assign _c_doomhead[17] = 5'h06;
assign _c_doomhead[18] = 5'h09;
assign _c_doomhead[19] = 5'h00;
assign _c_doomhead[20] = 5'h00;
assign _c_doomhead[21] = 5'h00;
assign _c_doomhead[22] = 5'h00;
assign _c_doomhead[23] = 5'h00;
assign _c_doomhead[24] = 5'h00;
assign _c_doomhead[25] = 5'h00;
assign _c_doomhead[26] = 5'h00;
assign _c_doomhead[27] = 5'h13;
assign _c_doomhead[28] = 5'h06;
assign _c_doomhead[29] = 5'h0f;
assign _c_doomhead[30] = 5'h06;
assign _c_doomhead[31] = 5'h04;
assign _c_doomhead[32] = 5'h01;
assign _c_doomhead[33] = 5'h12;
assign _c_doomhead[34] = 5'h03;
assign _c_doomhead[35] = 5'h0b;
assign _c_doomhead[36] = 5'h0b;
assign _c_doomhead[37] = 5'h03;
assign _c_doomhead[38] = 5'h05;
assign _c_doomhead[39] = 5'h0d;
assign _c_doomhead[40] = 5'h02;
assign _c_doomhead[41] = 5'h06;
assign _c_doomhead[42] = 5'h0f;
assign _c_doomhead[43] = 5'h06;
assign _c_doomhead[44] = 5'h13;
assign _c_doomhead[45] = 5'h00;
assign _c_doomhead[46] = 5'h00;
assign _c_doomhead[47] = 5'h00;
assign _c_doomhead[48] = 5'h00;
assign _c_doomhead[49] = 5'h00;
assign _c_doomhead[50] = 5'h13;
assign _c_doomhead[51] = 5'h06;
assign _c_doomhead[52] = 5'h02;
assign _c_doomhead[53] = 5'h01;
assign _c_doomhead[54] = 5'h0d;
assign _c_doomhead[55] = 5'h12;
assign _c_doomhead[56] = 5'h0a;
assign _c_doomhead[57] = 5'h0b;
assign _c_doomhead[58] = 5'h08;
assign _c_doomhead[59] = 5'h03;
assign _c_doomhead[60] = 5'h0d;
assign _c_doomhead[61] = 5'h0d;
assign _c_doomhead[62] = 5'h0d;
assign _c_doomhead[63] = 5'h01;
assign _c_doomhead[64] = 5'h01;
assign _c_doomhead[65] = 5'h02;
assign _c_doomhead[66] = 5'h02;
assign _c_doomhead[67] = 5'h0f;
assign _c_doomhead[68] = 5'h09;
assign _c_doomhead[69] = 5'h13;
assign _c_doomhead[70] = 5'h00;
assign _c_doomhead[71] = 5'h00;
assign _c_doomhead[72] = 5'h00;
assign _c_doomhead[73] = 5'h00;
assign _c_doomhead[74] = 5'h13;
assign _c_doomhead[75] = 5'h02;
assign _c_doomhead[76] = 5'h10;
assign _c_doomhead[77] = 5'h02;
assign _c_doomhead[78] = 5'h01;
assign _c_doomhead[79] = 5'h0d;
assign _c_doomhead[80] = 5'h03;
assign _c_doomhead[81] = 5'h10;
assign _c_doomhead[82] = 5'h05;
assign _c_doomhead[83] = 5'h01;
assign _c_doomhead[84] = 5'h08;
assign _c_doomhead[85] = 5'h02;
assign _c_doomhead[86] = 5'h02;
assign _c_doomhead[87] = 5'h02;
assign _c_doomhead[88] = 5'h02;
assign _c_doomhead[89] = 5'h06;
assign _c_doomhead[90] = 5'h0f;
assign _c_doomhead[91] = 5'h13;
assign _c_doomhead[92] = 5'h13;
assign _c_doomhead[93] = 5'h0e;
assign _c_doomhead[94] = 5'h00;
assign _c_doomhead[95] = 5'h00;
assign _c_doomhead[96] = 5'h00;
assign _c_doomhead[97] = 5'h0e;
assign _c_doomhead[98] = 5'h19;
assign _c_doomhead[99] = 5'h06;
assign _c_doomhead[100] = 5'h02;
assign _c_doomhead[101] = 5'h06;
assign _c_doomhead[102] = 5'h01;
assign _c_doomhead[103] = 5'h0d;
assign _c_doomhead[104] = 5'h01;
assign _c_doomhead[105] = 5'h01;
assign _c_doomhead[106] = 5'h01;
assign _c_doomhead[107] = 5'h01;
assign _c_doomhead[108] = 5'h09;
assign _c_doomhead[109] = 5'h01;
assign _c_doomhead[110] = 5'h06;
assign _c_doomhead[111] = 5'h09;
assign _c_doomhead[112] = 5'h06;
assign _c_doomhead[113] = 5'h09;
assign _c_doomhead[114] = 5'h13;
assign _c_doomhead[115] = 5'h0e;
assign _c_doomhead[116] = 5'h0e;
assign _c_doomhead[117] = 5'h0e;
assign _c_doomhead[118] = 5'h0e;
assign _c_doomhead[119] = 5'h00;
assign _c_doomhead[120] = 5'h00;
assign _c_doomhead[121] = 5'h0e;
assign _c_doomhead[122] = 5'h19;
assign _c_doomhead[123] = 5'h09;
assign _c_doomhead[124] = 5'h0f;
assign _c_doomhead[125] = 5'h06;
assign _c_doomhead[126] = 5'h01;
assign _c_doomhead[127] = 5'h0f;
assign _c_doomhead[128] = 5'h0d;
assign _c_doomhead[129] = 5'h04;
assign _c_doomhead[130] = 5'h04;
assign _c_doomhead[131] = 5'h01;
assign _c_doomhead[132] = 5'h04;
assign _c_doomhead[133] = 5'h09;
assign _c_doomhead[134] = 5'h04;
assign _c_doomhead[135] = 5'h09;
assign _c_doomhead[136] = 5'h19;
assign _c_doomhead[137] = 5'h06;
assign _c_doomhead[138] = 5'h0e;
assign _c_doomhead[139] = 5'h13;
assign _c_doomhead[140] = 5'h13;
assign _c_doomhead[141] = 5'h19;
assign _c_doomhead[142] = 5'h0e;
assign _c_doomhead[143] = 5'h00;
assign _c_doomhead[144] = 5'h00;
assign _c_doomhead[145] = 5'h0e;
assign _c_doomhead[146] = 5'h09;
assign _c_doomhead[147] = 5'h09;
assign _c_doomhead[148] = 5'h02;
assign _c_doomhead[149] = 5'h02;
assign _c_doomhead[150] = 5'h0f;
assign _c_doomhead[151] = 5'h01;
assign _c_doomhead[152] = 5'h0f;
assign _c_doomhead[153] = 5'h04;
assign _c_doomhead[154] = 5'h02;
assign _c_doomhead[155] = 5'h04;
assign _c_doomhead[156] = 5'h04;
assign _c_doomhead[157] = 5'h01;
assign _c_doomhead[158] = 5'h01;
assign _c_doomhead[159] = 5'h01;
assign _c_doomhead[160] = 5'h10;
assign _c_doomhead[161] = 5'h10;
assign _c_doomhead[162] = 5'h04;
assign _c_doomhead[163] = 5'h09;
assign _c_doomhead[164] = 5'h19;
assign _c_doomhead[165] = 5'h09;
assign _c_doomhead[166] = 5'h0e;
assign _c_doomhead[167] = 5'h00;
assign _c_doomhead[168] = 5'h00;
assign _c_doomhead[169] = 5'h0e;
assign _c_doomhead[170] = 5'h09;
assign _c_doomhead[171] = 5'h0f;
assign _c_doomhead[172] = 5'h02;
assign _c_doomhead[173] = 5'h01;
assign _c_doomhead[174] = 5'h02;
assign _c_doomhead[175] = 5'h0f;
assign _c_doomhead[176] = 5'h08;
assign _c_doomhead[177] = 5'h0f;
assign _c_doomhead[178] = 5'h02;
assign _c_doomhead[179] = 5'h01;
assign _c_doomhead[180] = 5'h08;
assign _c_doomhead[181] = 5'h03;
assign _c_doomhead[182] = 5'h0d;
assign _c_doomhead[183] = 5'h08;
assign _c_doomhead[184] = 5'h01;
assign _c_doomhead[185] = 5'h01;
assign _c_doomhead[186] = 5'h01;
assign _c_doomhead[187] = 5'h04;
assign _c_doomhead[188] = 5'h09;
assign _c_doomhead[189] = 5'h09;
assign _c_doomhead[190] = 5'h0e;
assign _c_doomhead[191] = 5'h00;
assign _c_doomhead[192] = 5'h00;
assign _c_doomhead[193] = 5'h0e;
assign _c_doomhead[194] = 5'h09;
assign _c_doomhead[195] = 5'h06;
assign _c_doomhead[196] = 5'h01;
assign _c_doomhead[197] = 5'h05;
assign _c_doomhead[198] = 5'h03;
assign _c_doomhead[199] = 5'h08;
assign _c_doomhead[200] = 5'h08;
assign _c_doomhead[201] = 5'h03;
assign _c_doomhead[202] = 5'h03;
assign _c_doomhead[203] = 5'h03;
assign _c_doomhead[204] = 5'h03;
assign _c_doomhead[205] = 5'h03;
assign _c_doomhead[206] = 5'h03;
assign _c_doomhead[207] = 5'h08;
assign _c_doomhead[208] = 5'h08;
assign _c_doomhead[209] = 5'h03;
assign _c_doomhead[210] = 5'h05;
assign _c_doomhead[211] = 5'h01;
assign _c_doomhead[212] = 5'h0f;
assign _c_doomhead[213] = 5'h09;
assign _c_doomhead[214] = 5'h0e;
assign _c_doomhead[215] = 5'h00;
assign _c_doomhead[216] = 5'h00;
assign _c_doomhead[217] = 5'h0e;
assign _c_doomhead[218] = 5'h09;
assign _c_doomhead[219] = 5'h02;
assign _c_doomhead[220] = 5'h0d;
assign _c_doomhead[221] = 5'h0b;
assign _c_doomhead[222] = 5'h0a;
assign _c_doomhead[223] = 5'h0a;
assign _c_doomhead[224] = 5'h03;
assign _c_doomhead[225] = 5'h08;
assign _c_doomhead[226] = 5'h05;
assign _c_doomhead[227] = 5'h05;
assign _c_doomhead[228] = 5'h05;
assign _c_doomhead[229] = 5'h05;
assign _c_doomhead[230] = 5'h08;
assign _c_doomhead[231] = 5'h03;
assign _c_doomhead[232] = 5'h0a;
assign _c_doomhead[233] = 5'h0a;
assign _c_doomhead[234] = 5'h0b;
assign _c_doomhead[235] = 5'h0d;
assign _c_doomhead[236] = 5'h06;
assign _c_doomhead[237] = 5'h09;
assign _c_doomhead[238] = 5'h0e;
assign _c_doomhead[239] = 5'h00;
assign _c_doomhead[240] = 5'h00;
assign _c_doomhead[241] = 5'h0e;
assign _c_doomhead[242] = 5'h09;
assign _c_doomhead[243] = 5'h02;
assign _c_doomhead[244] = 5'h0d;
assign _c_doomhead[245] = 5'h0b;
assign _c_doomhead[246] = 5'h17;
assign _c_doomhead[247] = 5'h0c;
assign _c_doomhead[248] = 5'h0b;
assign _c_doomhead[249] = 5'h12;
assign _c_doomhead[250] = 5'h08;
assign _c_doomhead[251] = 5'h01;
assign _c_doomhead[252] = 5'h01;
assign _c_doomhead[253] = 5'h08;
assign _c_doomhead[254] = 5'h12;
assign _c_doomhead[255] = 5'h0b;
assign _c_doomhead[256] = 5'h0c;
assign _c_doomhead[257] = 5'h17;
assign _c_doomhead[258] = 5'h0b;
assign _c_doomhead[259] = 5'h0d;
assign _c_doomhead[260] = 5'h02;
assign _c_doomhead[261] = 5'h09;
assign _c_doomhead[262] = 5'h0e;
assign _c_doomhead[263] = 5'h00;
assign _c_doomhead[264] = 5'h00;
assign _c_doomhead[265] = 5'h0e;
assign _c_doomhead[266] = 5'h09;
assign _c_doomhead[267] = 5'h02;
assign _c_doomhead[268] = 5'h03;
assign _c_doomhead[269] = 5'h0c;
assign _c_doomhead[270] = 5'h1c;
assign _c_doomhead[271] = 5'h18;
assign _c_doomhead[272] = 5'h0c;
assign _c_doomhead[273] = 5'h0c;
assign _c_doomhead[274] = 5'h0b;
assign _c_doomhead[275] = 5'h07;
assign _c_doomhead[276] = 5'h07;
assign _c_doomhead[277] = 5'h0b;
assign _c_doomhead[278] = 5'h0c;
assign _c_doomhead[279] = 5'h0c;
assign _c_doomhead[280] = 5'h18;
assign _c_doomhead[281] = 5'h1c;
assign _c_doomhead[282] = 5'h0c;
assign _c_doomhead[283] = 5'h03;
assign _c_doomhead[284] = 5'h02;
assign _c_doomhead[285] = 5'h09;
assign _c_doomhead[286] = 5'h0e;
assign _c_doomhead[287] = 5'h00;
assign _c_doomhead[288] = 5'h03;
assign _c_doomhead[289] = 5'h04;
assign _c_doomhead[290] = 5'h09;
assign _c_doomhead[291] = 5'h02;
assign _c_doomhead[292] = 5'h04;
assign _c_doomhead[293] = 5'h04;
assign _c_doomhead[294] = 5'h0f;
assign _c_doomhead[295] = 5'h08;
assign _c_doomhead[296] = 5'h11;
assign _c_doomhead[297] = 5'h03;
assign _c_doomhead[298] = 5'h02;
assign _c_doomhead[299] = 5'h03;
assign _c_doomhead[300] = 5'h03;
assign _c_doomhead[301] = 5'h02;
assign _c_doomhead[302] = 5'h03;
assign _c_doomhead[303] = 5'h11;
assign _c_doomhead[304] = 5'h08;
assign _c_doomhead[305] = 5'h0f;
assign _c_doomhead[306] = 5'h04;
assign _c_doomhead[307] = 5'h04;
assign _c_doomhead[308] = 5'h02;
assign _c_doomhead[309] = 5'h09;
assign _c_doomhead[310] = 5'h04;
assign _c_doomhead[311] = 5'h03;
assign _c_doomhead[312] = 5'h03;
assign _c_doomhead[313] = 5'h04;
assign _c_doomhead[314] = 5'h09;
assign _c_doomhead[315] = 5'h01;
assign _c_doomhead[316] = 5'h05;
assign _c_doomhead[317] = 5'h05;
assign _c_doomhead[318] = 5'h0d;
assign _c_doomhead[319] = 5'h10;
assign _c_doomhead[320] = 5'h02;
assign _c_doomhead[321] = 5'h04;
assign _c_doomhead[322] = 5'h04;
assign _c_doomhead[323] = 5'h01;
assign _c_doomhead[324] = 5'h01;
assign _c_doomhead[325] = 5'h04;
assign _c_doomhead[326] = 5'h04;
assign _c_doomhead[327] = 5'h02;
assign _c_doomhead[328] = 5'h10;
assign _c_doomhead[329] = 5'h0d;
assign _c_doomhead[330] = 5'h05;
assign _c_doomhead[331] = 5'h05;
assign _c_doomhead[332] = 5'h01;
assign _c_doomhead[333] = 5'h09;
assign _c_doomhead[334] = 5'h04;
assign _c_doomhead[335] = 5'h03;
assign _c_doomhead[336] = 5'h01;
assign _c_doomhead[337] = 5'h04;
assign _c_doomhead[338] = 5'h04;
assign _c_doomhead[339] = 5'h03;
assign _c_doomhead[340] = 5'h02;
assign _c_doomhead[341] = 5'h15;
assign _c_doomhead[342] = 5'h1c;
assign _c_doomhead[343] = 5'h1c;
assign _c_doomhead[344] = 5'h1a;
assign _c_doomhead[345] = 5'h15;
assign _c_doomhead[346] = 5'h14;
assign _c_doomhead[347] = 5'h07;
assign _c_doomhead[348] = 5'h07;
assign _c_doomhead[349] = 5'h14;
assign _c_doomhead[350] = 5'h15;
assign _c_doomhead[351] = 5'h1a;
assign _c_doomhead[352] = 5'h1c;
assign _c_doomhead[353] = 5'h1c;
assign _c_doomhead[354] = 5'h15;
assign _c_doomhead[355] = 5'h02;
assign _c_doomhead[356] = 5'h03;
assign _c_doomhead[357] = 5'h04;
assign _c_doomhead[358] = 5'h04;
assign _c_doomhead[359] = 5'h01;
assign _c_doomhead[360] = 5'h04;
assign _c_doomhead[361] = 5'h06;
assign _c_doomhead[362] = 5'h10;
assign _c_doomhead[363] = 5'h03;
assign _c_doomhead[364] = 5'h01;
assign _c_doomhead[365] = 5'h05;
assign _c_doomhead[366] = 5'h15;
assign _c_doomhead[367] = 5'h1a;
assign _c_doomhead[368] = 5'h15;
assign _c_doomhead[369] = 5'h1f;
assign _c_doomhead[370] = 5'h01;
assign _c_doomhead[371] = 5'h0b;
assign _c_doomhead[372] = 5'h0c;
assign _c_doomhead[373] = 5'h01;
assign _c_doomhead[374] = 5'h1f;
assign _c_doomhead[375] = 5'h15;
assign _c_doomhead[376] = 5'h1a;
assign _c_doomhead[377] = 5'h15;
assign _c_doomhead[378] = 5'h05;
assign _c_doomhead[379] = 5'h01;
assign _c_doomhead[380] = 5'h03;
assign _c_doomhead[381] = 5'h10;
assign _c_doomhead[382] = 5'h06;
assign _c_doomhead[383] = 5'h04;
assign _c_doomhead[384] = 5'h10;
assign _c_doomhead[385] = 5'h06;
assign _c_doomhead[386] = 5'h10;
assign _c_doomhead[387] = 5'h11;
assign _c_doomhead[388] = 5'h07;
assign _c_doomhead[389] = 5'h12;
assign _c_doomhead[390] = 5'h05;
assign _c_doomhead[391] = 5'h01;
assign _c_doomhead[392] = 5'h05;
assign _c_doomhead[393] = 5'h0a;
assign _c_doomhead[394] = 5'h07;
assign _c_doomhead[395] = 5'h16;
assign _c_doomhead[396] = 5'h1d;
assign _c_doomhead[397] = 5'h07;
assign _c_doomhead[398] = 5'h0a;
assign _c_doomhead[399] = 5'h05;
assign _c_doomhead[400] = 5'h01;
assign _c_doomhead[401] = 5'h05;
assign _c_doomhead[402] = 5'h12;
assign _c_doomhead[403] = 5'h07;
assign _c_doomhead[404] = 5'h11;
assign _c_doomhead[405] = 5'h10;
assign _c_doomhead[406] = 5'h06;
assign _c_doomhead[407] = 5'h10;
assign _c_doomhead[408] = 5'h01;
assign _c_doomhead[409] = 5'h06;
assign _c_doomhead[410] = 5'h01;
assign _c_doomhead[411] = 5'h0b;
assign _c_doomhead[412] = 5'h11;
assign _c_doomhead[413] = 5'h17;
assign _c_doomhead[414] = 5'h11;
assign _c_doomhead[415] = 5'h0a;
assign _c_doomhead[416] = 5'h16;
assign _c_doomhead[417] = 5'h1b;
assign _c_doomhead[418] = 5'h0c;
assign _c_doomhead[419] = 5'h16;
assign _c_doomhead[420] = 5'h1d;
assign _c_doomhead[421] = 5'h0c;
assign _c_doomhead[422] = 5'h1b;
assign _c_doomhead[423] = 5'h16;
assign _c_doomhead[424] = 5'h0a;
assign _c_doomhead[425] = 5'h11;
assign _c_doomhead[426] = 5'h17;
assign _c_doomhead[427] = 5'h11;
assign _c_doomhead[428] = 5'h0b;
assign _c_doomhead[429] = 5'h01;
assign _c_doomhead[430] = 5'h06;
assign _c_doomhead[431] = 5'h01;
assign _c_doomhead[432] = 5'h00;
assign _c_doomhead[433] = 5'h06;
assign _c_doomhead[434] = 5'h10;
assign _c_doomhead[435] = 5'h08;
assign _c_doomhead[436] = 5'h05;
assign _c_doomhead[437] = 5'h12;
assign _c_doomhead[438] = 5'h07;
assign _c_doomhead[439] = 5'h16;
assign _c_doomhead[440] = 5'h1c;
assign _c_doomhead[441] = 5'h11;
assign _c_doomhead[442] = 5'h07;
assign _c_doomhead[443] = 5'h1d;
assign _c_doomhead[444] = 5'h1c;
assign _c_doomhead[445] = 5'h07;
assign _c_doomhead[446] = 5'h11;
assign _c_doomhead[447] = 5'h1c;
assign _c_doomhead[448] = 5'h16;
assign _c_doomhead[449] = 5'h07;
assign _c_doomhead[450] = 5'h12;
assign _c_doomhead[451] = 5'h05;
assign _c_doomhead[452] = 5'h08;
assign _c_doomhead[453] = 5'h10;
assign _c_doomhead[454] = 5'h06;
assign _c_doomhead[455] = 5'h00;
assign _c_doomhead[456] = 5'h00;
assign _c_doomhead[457] = 5'h06;
assign _c_doomhead[458] = 5'h02;
assign _c_doomhead[459] = 5'h0d;
assign _c_doomhead[460] = 5'h08;
assign _c_doomhead[461] = 5'h12;
assign _c_doomhead[462] = 5'h17;
assign _c_doomhead[463] = 5'h18;
assign _c_doomhead[464] = 5'h07;
assign _c_doomhead[465] = 5'h05;
assign _c_doomhead[466] = 5'h0d;
assign _c_doomhead[467] = 5'h1e;
assign _c_doomhead[468] = 5'h1e;
assign _c_doomhead[469] = 5'h0d;
assign _c_doomhead[470] = 5'h05;
assign _c_doomhead[471] = 5'h07;
assign _c_doomhead[472] = 5'h18;
assign _c_doomhead[473] = 5'h17;
assign _c_doomhead[474] = 5'h12;
assign _c_doomhead[475] = 5'h08;
assign _c_doomhead[476] = 5'h0d;
assign _c_doomhead[477] = 5'h02;
assign _c_doomhead[478] = 5'h06;
assign _c_doomhead[479] = 5'h00;
assign _c_doomhead[480] = 5'h00;
assign _c_doomhead[481] = 5'h00;
assign _c_doomhead[482] = 5'h02;
assign _c_doomhead[483] = 5'h03;
assign _c_doomhead[484] = 5'h0d;
assign _c_doomhead[485] = 5'h07;
assign _c_doomhead[486] = 5'h1b;
assign _c_doomhead[487] = 5'h0c;
assign _c_doomhead[488] = 5'h12;
assign _c_doomhead[489] = 5'h0f;
assign _c_doomhead[490] = 5'h02;
assign _c_doomhead[491] = 5'h10;
assign _c_doomhead[492] = 5'h10;
assign _c_doomhead[493] = 5'h02;
assign _c_doomhead[494] = 5'h0f;
assign _c_doomhead[495] = 5'h12;
assign _c_doomhead[496] = 5'h0c;
assign _c_doomhead[497] = 5'h1b;
assign _c_doomhead[498] = 5'h07;
assign _c_doomhead[499] = 5'h0d;
assign _c_doomhead[500] = 5'h03;
assign _c_doomhead[501] = 5'h02;
assign _c_doomhead[502] = 5'h00;
assign _c_doomhead[503] = 5'h00;
assign _c_doomhead[504] = 5'h00;
assign _c_doomhead[505] = 5'h00;
assign _c_doomhead[506] = 5'h06;
assign _c_doomhead[507] = 5'h0a;
assign _c_doomhead[508] = 5'h0d;
assign _c_doomhead[509] = 5'h0c;
assign _c_doomhead[510] = 5'h18;
assign _c_doomhead[511] = 5'h0b;
assign _c_doomhead[512] = 5'h0b;
assign _c_doomhead[513] = 5'h07;
assign _c_doomhead[514] = 5'h12;
assign _c_doomhead[515] = 5'h08;
assign _c_doomhead[516] = 5'h08;
assign _c_doomhead[517] = 5'h12;
assign _c_doomhead[518] = 5'h07;
assign _c_doomhead[519] = 5'h0b;
assign _c_doomhead[520] = 5'h0b;
assign _c_doomhead[521] = 5'h18;
assign _c_doomhead[522] = 5'h0c;
assign _c_doomhead[523] = 5'h0d;
assign _c_doomhead[524] = 5'h0a;
assign _c_doomhead[525] = 5'h06;
assign _c_doomhead[526] = 5'h00;
assign _c_doomhead[527] = 5'h00;
assign _c_doomhead[528] = 5'h00;
assign _c_doomhead[529] = 5'h00;
assign _c_doomhead[530] = 5'h0f;
assign _c_doomhead[531] = 5'h05;
assign _c_doomhead[532] = 5'h08;
assign _c_doomhead[533] = 5'h07;
assign _c_doomhead[534] = 5'h0c;
assign _c_doomhead[535] = 5'h0b;
assign _c_doomhead[536] = 5'h07;
assign _c_doomhead[537] = 5'h18;
assign _c_doomhead[538] = 5'h1c;
assign _c_doomhead[539] = 5'h11;
assign _c_doomhead[540] = 5'h11;
assign _c_doomhead[541] = 5'h1c;
assign _c_doomhead[542] = 5'h18;
assign _c_doomhead[543] = 5'h07;
assign _c_doomhead[544] = 5'h0b;
assign _c_doomhead[545] = 5'h0c;
assign _c_doomhead[546] = 5'h07;
assign _c_doomhead[547] = 5'h08;
assign _c_doomhead[548] = 5'h05;
assign _c_doomhead[549] = 5'h0f;
assign _c_doomhead[550] = 5'h00;
assign _c_doomhead[551] = 5'h00;
assign _c_doomhead[552] = 5'h00;
assign _c_doomhead[553] = 5'h00;
assign _c_doomhead[554] = 5'h00;
assign _c_doomhead[555] = 5'h10;
assign _c_doomhead[556] = 5'h05;
assign _c_doomhead[557] = 5'h0a;
assign _c_doomhead[558] = 5'h07;
assign _c_doomhead[559] = 5'h01;
assign _c_doomhead[560] = 5'h02;
assign _c_doomhead[561] = 5'h14;
assign _c_doomhead[562] = 5'h14;
assign _c_doomhead[563] = 5'h14;
assign _c_doomhead[564] = 5'h14;
assign _c_doomhead[565] = 5'h14;
assign _c_doomhead[566] = 5'h14;
assign _c_doomhead[567] = 5'h02;
assign _c_doomhead[568] = 5'h01;
assign _c_doomhead[569] = 5'h07;
assign _c_doomhead[570] = 5'h0a;
assign _c_doomhead[571] = 5'h05;
assign _c_doomhead[572] = 5'h10;
assign _c_doomhead[573] = 5'h00;
assign _c_doomhead[574] = 5'h00;
assign _c_doomhead[575] = 5'h00;
assign _c_doomhead[576] = 5'h00;
assign _c_doomhead[577] = 5'h00;
assign _c_doomhead[578] = 5'h00;
assign _c_doomhead[579] = 5'h0f;
assign _c_doomhead[580] = 5'h01;
assign _c_doomhead[581] = 5'h03;
assign _c_doomhead[582] = 5'h0a;
assign _c_doomhead[583] = 5'h0a;
assign _c_doomhead[584] = 5'h0a;
assign _c_doomhead[585] = 5'h07;
assign _c_doomhead[586] = 5'h0c;
assign _c_doomhead[587] = 5'h16;
assign _c_doomhead[588] = 5'h16;
assign _c_doomhead[589] = 5'h0c;
assign _c_doomhead[590] = 5'h07;
assign _c_doomhead[591] = 5'h0a;
assign _c_doomhead[592] = 5'h0a;
assign _c_doomhead[593] = 5'h0a;
assign _c_doomhead[594] = 5'h03;
assign _c_doomhead[595] = 5'h01;
assign _c_doomhead[596] = 5'h0f;
assign _c_doomhead[597] = 5'h00;
assign _c_doomhead[598] = 5'h00;
assign _c_doomhead[599] = 5'h00;
assign _c_doomhead[600] = 5'h00;
assign _c_doomhead[601] = 5'h00;
assign _c_doomhead[602] = 5'h00;
assign _c_doomhead[603] = 5'h00;
assign _c_doomhead[604] = 5'h04;
assign _c_doomhead[605] = 5'h05;
assign _c_doomhead[606] = 5'h0b;
assign _c_doomhead[607] = 5'h11;
assign _c_doomhead[608] = 5'h0a;
assign _c_doomhead[609] = 5'h05;
assign _c_doomhead[610] = 5'h01;
assign _c_doomhead[611] = 5'h02;
assign _c_doomhead[612] = 5'h02;
assign _c_doomhead[613] = 5'h01;
assign _c_doomhead[614] = 5'h05;
assign _c_doomhead[615] = 5'h0a;
assign _c_doomhead[616] = 5'h11;
assign _c_doomhead[617] = 5'h0b;
assign _c_doomhead[618] = 5'h05;
assign _c_doomhead[619] = 5'h04;
assign _c_doomhead[620] = 5'h00;
assign _c_doomhead[621] = 5'h00;
assign _c_doomhead[622] = 5'h00;
assign _c_doomhead[623] = 5'h00;
assign _c_doomhead[624] = 5'h00;
assign _c_doomhead[625] = 5'h00;
assign _c_doomhead[626] = 5'h00;
assign _c_doomhead[627] = 5'h00;
assign _c_doomhead[628] = 5'h00;
assign _c_doomhead[629] = 5'h04;
assign _c_doomhead[630] = 5'h05;
assign _c_doomhead[631] = 5'h0b;
assign _c_doomhead[632] = 5'h11;
assign _c_doomhead[633] = 5'h0a;
assign _c_doomhead[634] = 5'h0a;
assign _c_doomhead[635] = 5'h0c;
assign _c_doomhead[636] = 5'h0c;
assign _c_doomhead[637] = 5'h0a;
assign _c_doomhead[638] = 5'h0a;
assign _c_doomhead[639] = 5'h11;
assign _c_doomhead[640] = 5'h0b;
assign _c_doomhead[641] = 5'h05;
assign _c_doomhead[642] = 5'h04;
assign _c_doomhead[643] = 5'h00;
assign _c_doomhead[644] = 5'h00;
assign _c_doomhead[645] = 5'h00;
assign _c_doomhead[646] = 5'h00;
assign _c_doomhead[647] = 5'h00;
assign _c_doomhead[648] = 5'h00;
assign _c_doomhead[649] = 5'h00;
assign _c_doomhead[650] = 5'h00;
assign _c_doomhead[651] = 5'h00;
assign _c_doomhead[652] = 5'h00;
assign _c_doomhead[653] = 5'h00;
assign _c_doomhead[654] = 5'h0f;
assign _c_doomhead[655] = 5'h10;
assign _c_doomhead[656] = 5'h03;
assign _c_doomhead[657] = 5'h07;
assign _c_doomhead[658] = 5'h0c;
assign _c_doomhead[659] = 5'h1c;
assign _c_doomhead[660] = 5'h1c;
assign _c_doomhead[661] = 5'h0c;
assign _c_doomhead[662] = 5'h07;
assign _c_doomhead[663] = 5'h03;
assign _c_doomhead[664] = 5'h10;
assign _c_doomhead[665] = 5'h0f;
assign _c_doomhead[666] = 5'h00;
assign _c_doomhead[667] = 5'h00;
assign _c_doomhead[668] = 5'h00;
assign _c_doomhead[669] = 5'h00;
assign _c_doomhead[670] = 5'h00;
assign _c_doomhead[671] = 5'h00;
assign _c_doomhead[672] = 5'h00;
assign _c_doomhead[673] = 5'h00;
assign _c_doomhead[674] = 5'h00;
assign _c_doomhead[675] = 5'h00;
assign _c_doomhead[676] = 5'h00;
assign _c_doomhead[677] = 5'h00;
assign _c_doomhead[678] = 5'h00;
assign _c_doomhead[679] = 5'h0e;
assign _c_doomhead[680] = 5'h04;
assign _c_doomhead[681] = 5'h01;
assign _c_doomhead[682] = 5'h08;
assign _c_doomhead[683] = 5'h08;
assign _c_doomhead[684] = 5'h08;
assign _c_doomhead[685] = 5'h08;
assign _c_doomhead[686] = 5'h01;
assign _c_doomhead[687] = 5'h04;
assign _c_doomhead[688] = 5'h0e;
assign _c_doomhead[689] = 5'h00;
assign _c_doomhead[690] = 5'h00;
assign _c_doomhead[691] = 5'h00;
assign _c_doomhead[692] = 5'h00;
assign _c_doomhead[693] = 5'h00;
assign _c_doomhead[694] = 5'h00;
assign _c_doomhead[695] = 5'h00;
wire  [17:0] _c_sub666[31:0];
assign _c_sub666[0] = 0;
assign _c_sub666[1] = 144845;
assign _c_sub666[2] = 120010;
assign _c_sub666[3] = 182033;
assign _c_sub666[4] = 107593;
assign _c_sub666[5] = 173776;
assign _c_sub666[6] = 95240;
assign _c_sub666[7] = 219286;
assign _c_sub666[8] = 165519;
assign _c_sub666[9] = 74566;
assign _c_sub666[10] = 206803;
assign _c_sub666[11] = 210964;
assign _c_sub666[12] = 235930;
assign _c_sub666[13] = 157198;
assign _c_sub666[14] = 41475;
assign _c_sub666[15] = 82887;
assign _c_sub666[16] = 136524;
assign _c_sub666[17] = 227608;
assign _c_sub666[18] = 194450;
assign _c_sub666[19] = 49796;
assign _c_sub666[20] = 157060;
assign _c_sub666[21] = 199051;
assign _c_sub666[22] = 260630;
assign _c_sub666[23] = 244252;
assign _c_sub666[24] = 252574;
assign _c_sub666[25] = 62149;
assign _c_sub666[26] = 220048;
assign _c_sub666[27] = 261028;
assign _c_sub666[28] = 261094;
assign _c_sub666[29] = 260894;
assign _c_sub666[30] = 161816;
assign _c_sub666[31] = 178055;
// ===============

always @(posedge clock) begin
_q_prev_vs <= _d_prev_vs;
_q_prev_hs <= _d_prev_hs;
_q_frame <= (reset) ? 0 : _d_frame;
_q_u <= (reset) ? 0 : _d_u;
_q_uT <= (reset) ? 0 : _d_uT;
_q_v <= (reset) ? 0 : _d_v;
_q_vT <= (reset) ? 0 : _d_vT;
_q_clip <= _d_clip;
_q_addr <= _d_addr;
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
wire  [7:0] _w_demo_audio8;
wire  [0:0] _w_demo_audio1;

reg  [7:0] _d_uio_o;
reg  [7:0] _q_uio_o;
reg  [7:0] _d_uio_oenable;
reg  [7:0] _q_uio_oenable;
reg  [7:0] _d_uo;
reg  [7:0] _q_uo;
assign out_uo = _q_uo;
assign out_done = 0;
M_vga_demo_M_main_demo demo (
.out_video_r(_w_demo_video_r),
.out_video_g(_w_demo_video_g),
.out_video_b(_w_demo_video_b),
.out_video_hs(_w_demo_video_hs),
.out_video_vs(_w_demo_video_vs),
.out_audio8(_w_demo_audio8),
.out_audio1(_w_demo_audio1),
.reset(reset),
.clock(clock));


assign inout_uio_oe[0] = _q_uio_oenable[0];
assign inout_uio_o[0] = _q_uio_o[0];
assign inout_uio_oe[1] = _q_uio_oenable[1];
assign inout_uio_o[1] = _q_uio_o[1];
assign inout_uio_oe[2] = _q_uio_oenable[2];
assign inout_uio_o[2] = _q_uio_o[2];
assign inout_uio_oe[3] = _q_uio_oenable[3];
assign inout_uio_o[3] = _q_uio_o[3];
assign inout_uio_oe[4] = _q_uio_oenable[4];
assign inout_uio_o[4] = _q_uio_o[4];
assign inout_uio_oe[5] = _q_uio_oenable[5];
assign inout_uio_o[5] = _q_uio_o[5];
assign inout_uio_oe[6] = _q_uio_oenable[6];
assign inout_uio_o[6] = _q_uio_o[6];
assign inout_uio_oe[7] = _q_uio_oenable[7];
assign inout_uio_o[7] = _q_uio_o[7];

`ifdef FORMAL
initial begin
assume(reset);
end
`endif
always @* begin
_d_uio_o = _q_uio_o;
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

_d_uio_oenable = {1'b1,7'b0};

_d_uio_o[7+:1] = _w_demo_audio1;

// __block_2
// _always_post
// pipeline stage triggers
end

always @(posedge clock) begin
_q_uio_o <= _d_uio_o;
_q_uio_oenable <= _d_uio_oenable;
_q_uo <= _d_uo;
end

endmodule
