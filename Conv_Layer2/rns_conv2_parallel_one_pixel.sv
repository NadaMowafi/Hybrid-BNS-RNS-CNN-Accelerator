`timescale 1ns/1ps

module rns_conv2_parallel_one_pixel (

    // =========================================================
    // 32 channels × 9 values = 288 inputs
    // =========================================================

    input wire [31:0] x [0:287],
    input wire [31:0] w [0:287],

    input wire [31:0] bias,

    output wire [31:0] y_out
);

    // =========================================================
    // Partial residue sums from 32 MAC9 blocks
    // =========================================================

    wire [15:0] partial_r1 [0:31];
    wire [15:0] partial_r2 [0:31];

    genvar ch;

    generate

        for (ch = 0; ch < 32; ch = ch + 1) begin : MAC9_ARRAY

            rns_mac9_residue mac9 (

                .x0(x[ch*9 + 0]),
                .x1(x[ch*9 + 1]),
                .x2(x[ch*9 + 2]),
                .x3(x[ch*9 + 3]),
                .x4(x[ch*9 + 4]),
                .x5(x[ch*9 + 5]),
                .x6(x[ch*9 + 6]),
                .x7(x[ch*9 + 7]),
                .x8(x[ch*9 + 8]),

                .w0(w[ch*9 + 0]),
                .w1(w[ch*9 + 1]),
                .w2(w[ch*9 + 2]),
                .w3(w[ch*9 + 3]),
                .w4(w[ch*9 + 4]),
                .w5(w[ch*9 + 5]),
                .w6(w[ch*9 + 6]),
                .w7(w[ch*9 + 7]),
                .w8(w[ch*9 + 8]),

                .sum_r1(partial_r1[ch]),
                .sum_r2(partial_r2[ch])
            );

        end

    endgenerate

    // =========================================================
    // Encode bias
    // =========================================================

    wire [15:0] bias_r1;
    wire [15:0] bias_r2;

    bns_to_rns enc_bias (
        .x_in(bias),
        .r1(bias_r1),
        .r2(bias_r2)
    );

    // =========================================================
    // Accumulate all 32 residue partial sums
    // =========================================================

    integer i;

    reg [15:0] acc_r1;
    reg [15:0] acc_r2;

    always @(*) begin

        acc_r1 = bias_r1;
        acc_r2 = bias_r2;

        for (i = 0; i < 32; i = i + 1) begin

            acc_r1 = (acc_r1 + partial_r1[i]) % 32749;
            acc_r2 = (acc_r2 + partial_r2[i]) % 65521;

        end
    end

    // =========================================================
    // CRT reconstruction
    // =========================================================

    rns_to_bns dec (

        .r1(acc_r1),
        .r2(acc_r2),
        .x_out(y_out)

    );
    

endmodule