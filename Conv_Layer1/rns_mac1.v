`timescale 1ns/1ps

module rns_mac1 (
    input  wire [31:0] x_in,
    input  wire [31:0] w_in,
    input  wire [31:0] bias_in,
    output wire [31:0] y_out
);

    wire [15:0] x_r1, x_r2;
    wire [15:0] w_r1, w_r2;
    wire [15:0] b_r1, b_r2;

    wire [15:0] mult_r1, mult_r2;
    wire [15:0] acc_r1, acc_r2;

    // Convert x, w, bias to RNS
    bns_to_rns enc_x (
        .x_in(x_in),
        .r1(x_r1),
        .r2(x_r2)
    );

    bns_to_rns enc_w (
        .x_in(w_in),
        .r1(w_r1),
        .r2(w_r2)
    );

    bns_to_rns enc_b (
        .x_in(bias_in),
        .r1(b_r1),
        .r2(b_r2)
    );

    // Modular multiplication
    mod_mult_m32749 mult_ch1 (
        .a(x_r1),
        .b(w_r1),
        .y(mult_r1)
    );

    mod_mult_m65521 mult_ch2 (
        .a(x_r2),
        .b(w_r2),
        .y(mult_r2)
    );

    // Add bias
    mod_add #(
        .M(32749),
        .WIDTH(16)
    ) add_ch1 (
        .a(mult_r1),
        .b(b_r1),
        .y(acc_r1)
    );

    mod_add #(
        .M(65521),
        .WIDTH(16)
    ) add_ch2 (
        .a(mult_r2),
        .b(b_r2),
        .y(acc_r2)
    );

    // Convert result back to BNS
    rns_to_bns dec (
        .r1(acc_r1),
        .r2(acc_r2),
        .x_out(y_out)
    );

endmodule