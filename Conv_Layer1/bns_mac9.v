`timescale 1ns/1ps

module bns_mac9 (
    input wire signed [31:0] x0, x1, x2,
    input wire signed [31:0] x3, x4, x5,
    input wire signed [31:0] x6, x7, x8,

    input wire signed [31:0] w0, w1, w2,
    input wire signed [31:0] w3, w4, w5,
    input wire signed [31:0] w6, w7, w8,

    input wire signed [31:0] bias,

    output wire signed [31:0] y_out
);

    wire signed [63:0] p0 = x0 * w0;
    wire signed [63:0] p1 = x1 * w1;
    wire signed [63:0] p2 = x2 * w2;
    wire signed [63:0] p3 = x3 * w3;
    wire signed [63:0] p4 = x4 * w4;
    wire signed [63:0] p5 = x5 * w5;
    wire signed [63:0] p6 = x6 * w6;
    wire signed [63:0] p7 = x7 * w7;
    wire signed [63:0] p8 = x8 * w8;

    wire signed [63:0] sum64 =
        p0 + p1 + p2 +
        p3 + p4 + p5 +
        p6 + p7 + p8 +
        bias;

    assign y_out = sum64[31:0];

endmodule