`timescale 1ns/1ps

module rns_mac9_residue (
    input  wire [31:0] x0, x1, x2,
    input  wire [31:0] x3, x4, x5,
    input  wire [31:0] x6, x7, x8,

    input  wire [31:0] w0, w1, w2,
    input  wire [31:0] w3, w4, w5,
    input  wire [31:0] w6, w7, w8,

    output wire [15:0] sum_r1,
    output wire [15:0] sum_r2
);

    wire [15:0] xr1 [0:8];
    wire [15:0] xr2 [0:8];

    wire [15:0] wr1 [0:8];
    wire [15:0] wr2 [0:8];

    wire [15:0] pr1 [0:8];
    wire [15:0] pr2 [0:8];

    wire [15:0] s1_r1, s2_r1, s3_r1, s4_r1;
    wire [15:0] s5_r1, s6_r1, s7_r1, s8_r1;

    wire [15:0] s1_r2, s2_r2, s3_r2, s4_r2;
    wire [15:0] s5_r2, s6_r2, s7_r2, s8_r2;

    // ---------------- Encode inputs ----------------
    bns_to_rns enc_x0 (.x_in(x0), .r1(xr1[0]), .r2(xr2[0]));
    bns_to_rns enc_x1 (.x_in(x1), .r1(xr1[1]), .r2(xr2[1]));
    bns_to_rns enc_x2 (.x_in(x2), .r1(xr1[2]), .r2(xr2[2]));
    bns_to_rns enc_x3 (.x_in(x3), .r1(xr1[3]), .r2(xr2[3]));
    bns_to_rns enc_x4 (.x_in(x4), .r1(xr1[4]), .r2(xr2[4]));
    bns_to_rns enc_x5 (.x_in(x5), .r1(xr1[5]), .r2(xr2[5]));
    bns_to_rns enc_x6 (.x_in(x6), .r1(xr1[6]), .r2(xr2[6]));
    bns_to_rns enc_x7 (.x_in(x7), .r1(xr1[7]), .r2(xr2[7]));
    bns_to_rns enc_x8 (.x_in(x8), .r1(xr1[8]), .r2(xr2[8]));

    // ---------------- Encode weights ----------------
    bns_to_rns enc_w0 (.x_in(w0), .r1(wr1[0]), .r2(wr2[0]));
    bns_to_rns enc_w1 (.x_in(w1), .r1(wr1[1]), .r2(wr2[1]));
    bns_to_rns enc_w2 (.x_in(w2), .r1(wr1[2]), .r2(wr2[2]));
    bns_to_rns enc_w3 (.x_in(w3), .r1(wr1[3]), .r2(wr2[3]));
    bns_to_rns enc_w4 (.x_in(w4), .r1(wr1[4]), .r2(wr2[4]));
    bns_to_rns enc_w5 (.x_in(w5), .r1(wr1[5]), .r2(wr2[5]));
    bns_to_rns enc_w6 (.x_in(w6), .r1(wr1[6]), .r2(wr2[6]));
    bns_to_rns enc_w7 (.x_in(w7), .r1(wr1[7]), .r2(wr2[7]));
    bns_to_rns enc_w8 (.x_in(w8), .r1(wr1[8]), .r2(wr2[8]));

    // ---------------- Multiplication channel 1 ----------------
    mod_mult_m32749 m1_0 (.a(xr1[0]), .b(wr1[0]), .y(pr1[0]));
    mod_mult_m32749 m1_1 (.a(xr1[1]), .b(wr1[1]), .y(pr1[1]));
    mod_mult_m32749 m1_2 (.a(xr1[2]), .b(wr1[2]), .y(pr1[2]));
    mod_mult_m32749 m1_3 (.a(xr1[3]), .b(wr1[3]), .y(pr1[3]));
    mod_mult_m32749 m1_4 (.a(xr1[4]), .b(wr1[4]), .y(pr1[4]));
    mod_mult_m32749 m1_5 (.a(xr1[5]), .b(wr1[5]), .y(pr1[5]));
    mod_mult_m32749 m1_6 (.a(xr1[6]), .b(wr1[6]), .y(pr1[6]));
    mod_mult_m32749 m1_7 (.a(xr1[7]), .b(wr1[7]), .y(pr1[7]));
    mod_mult_m32749 m1_8 (.a(xr1[8]), .b(wr1[8]), .y(pr1[8]));

    // ---------------- Multiplication channel 2 ----------------
    mod_mult_m65521 m2_0 (.a(xr2[0]), .b(wr2[0]), .y(pr2[0]));
    mod_mult_m65521 m2_1 (.a(xr2[1]), .b(wr2[1]), .y(pr2[1]));
    mod_mult_m65521 m2_2 (.a(xr2[2]), .b(wr2[2]), .y(pr2[2]));
    mod_mult_m65521 m2_3 (.a(xr2[3]), .b(wr2[3]), .y(pr2[3]));
    mod_mult_m65521 m2_4 (.a(xr2[4]), .b(wr2[4]), .y(pr2[4]));
    mod_mult_m65521 m2_5 (.a(xr2[5]), .b(wr2[5]), .y(pr2[5]));
    mod_mult_m65521 m2_6 (.a(xr2[6]), .b(wr2[6]), .y(pr2[6]));
    mod_mult_m65521 m2_7 (.a(xr2[7]), .b(wr2[7]), .y(pr2[7]));
    mod_mult_m65521 m2_8 (.a(xr2[8]), .b(wr2[8]), .y(pr2[8]));

    // ---------------- Add tree channel 1 ----------------
    mod_add #(.M(32749), .WIDTH(16)) add1_0 (.a(pr1[0]), .b(pr1[1]), .y(s1_r1));
    mod_add #(.M(32749), .WIDTH(16)) add1_1 (.a(s1_r1), .b(pr1[2]), .y(s2_r1));
    mod_add #(.M(32749), .WIDTH(16)) add1_2 (.a(s2_r1), .b(pr1[3]), .y(s3_r1));
    mod_add #(.M(32749), .WIDTH(16)) add1_3 (.a(s3_r1), .b(pr1[4]), .y(s4_r1));
    mod_add #(.M(32749), .WIDTH(16)) add1_4 (.a(s4_r1), .b(pr1[5]), .y(s5_r1));
    mod_add #(.M(32749), .WIDTH(16)) add1_5 (.a(s5_r1), .b(pr1[6]), .y(s6_r1));
    mod_add #(.M(32749), .WIDTH(16)) add1_6 (.a(s6_r1), .b(pr1[7]), .y(s7_r1));
    mod_add #(.M(32749), .WIDTH(16)) add1_7 (.a(s7_r1), .b(pr1[8]), .y(s8_r1));

    // ---------------- Add tree channel 2 ----------------
    mod_add #(.M(65521), .WIDTH(16)) add2_0 (.a(pr2[0]), .b(pr2[1]), .y(s1_r2));
    mod_add #(.M(65521), .WIDTH(16)) add2_1 (.a(s1_r2), .b(pr2[2]), .y(s2_r2));
    mod_add #(.M(65521), .WIDTH(16)) add2_2 (.a(s2_r2), .b(pr2[3]), .y(s3_r2));
    mod_add #(.M(65521), .WIDTH(16)) add2_3 (.a(s3_r2), .b(pr2[4]), .y(s4_r2));
    mod_add #(.M(65521), .WIDTH(16)) add2_4 (.a(s4_r2), .b(pr2[5]), .y(s5_r2));
    mod_add #(.M(65521), .WIDTH(16)) add2_5 (.a(s5_r2), .b(pr2[6]), .y(s6_r2));
    mod_add #(.M(65521), .WIDTH(16)) add2_6 (.a(s6_r2), .b(pr2[7]), .y(s7_r2));
    mod_add #(.M(65521), .WIDTH(16)) add2_7 (.a(s7_r2), .b(pr2[8]), .y(s8_r2));

    assign sum_r1 = s8_r1;
    assign sum_r2 = s8_r2;

endmodule