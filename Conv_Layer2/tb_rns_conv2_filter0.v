`timescale 1ns/1ps

module tb_rns_conv2_filter0;

    parameter NUM_OUTPUTS = 196;
    parameter NUM_TERMS   = 288;
    parameter TOTAL_TERMS = NUM_OUTPUTS * NUM_TERMS;

    parameter [63:0] M_VAL = 64'd2145747229;

    reg [31:0] x_mem      [0:TOTAL_TERMS-1];
    reg [31:0] w_mem      [0:TOTAL_TERMS-1];
    reg [31:0] bias_mem   [0:NUM_OUTPUTS-1];
    reg [31:0] golden_mem [0:NUM_OUTPUTS-1];

    reg [31:0] x_in;
    reg [31:0] w_in;
    reg [31:0] bias_in;

    wire [15:0] x_r1, x_r2;
    wire [15:0] w_r1, w_r2;
    wire [15:0] b_r1, b_r2;

    wire [15:0] mult_r1, mult_r2;
    wire [15:0] acc_plus_mult_r1, acc_plus_mult_r2;
    wire [15:0] final_acc_r1, final_acc_r2;

    reg [15:0] acc_r1;
    reg [15:0] acc_r2;

    wire [31:0] y_out;

    integer out_idx;
    integer i;
    integer base;
    integer mismatch_count;

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

    mod_mult_m32749 mult1 (
        .a(x_r1),
        .b(w_r1),
        .y(mult_r1)
    );

    mod_mult_m65521 mult2 (
        .a(x_r2),
        .b(w_r2),
        .y(mult_r2)
    );

    mod_add #(
        .M(32749),
        .WIDTH(16)
    ) add_acc1 (
        .a(acc_r1),
        .b(mult_r1),
        .y(acc_plus_mult_r1)
    );

    mod_add #(
        .M(65521),
        .WIDTH(16)
    ) add_acc2 (
        .a(acc_r2),
        .b(mult_r2),
        .y(acc_plus_mult_r2)
    );

    mod_add #(
        .M(32749),
        .WIDTH(16)
    ) add_bias1 (
        .a(acc_r1),
        .b(b_r1),
        .y(final_acc_r1)
    );

    mod_add #(
        .M(65521),
        .WIDTH(16)
    ) add_bias2 (
        .a(acc_r2),
        .b(b_r2),
        .y(final_acc_r2)
    );

    rns_to_bns dec (
        .r1(final_acc_r1),
        .r2(final_acc_r2),
        .x_out(y_out)
    );

    function [31:0] signed_to_rns_input;
        input [31:0] val;

        reg signed [31:0] sval;
        reg [63:0] temp;

        begin
            sval = val;

            if (sval < 0)
                temp = M_VAL + sval;
            else
                temp = sval;

            signed_to_rns_input = temp[31:0];
        end
    endfunction

    initial begin

        mismatch_count = 0;

        $display("=====================================");
        $display(" RNS Conv2 Filter0 Full Map ");
        $display(" 196 outputs, 288 MAC terms each ");
        $display("=====================================");

        $readmemh("conv2_filter0_x_hex.txt", x_mem);
        $readmemh("conv2_filter0_w_hex.txt", w_mem);
        $readmemh("conv2_filter0_bias_hex.txt", bias_mem);
        $readmemh("conv2_filter0_goldens_hex.txt", golden_mem);

        for (out_idx = 0; out_idx < NUM_OUTPUTS; out_idx = out_idx + 1) begin

            base = out_idx * NUM_TERMS;

            acc_r1 = 16'd0;
            acc_r2 = 16'd0;

            for (i = 0; i < NUM_TERMS; i = i + 1) begin

                x_in = signed_to_rns_input(x_mem[base + i]);
                w_in = signed_to_rns_input(w_mem[base + i]);

                #10;

                acc_r1 = acc_plus_mult_r1;
                acc_r2 = acc_plus_mult_r2;

                #1;
            end

            bias_in = signed_to_rns_input(bias_mem[out_idx]);

            #10;

            if ($signed(y_out) !== $signed(golden_mem[out_idx])) begin
                $display("MISMATCH output=%0d expected=%0d got=%0d",
                         out_idx, $signed(golden_mem[out_idx]), $signed(y_out));
                mismatch_count = mismatch_count + 1;
            end
        end

        if (mismatch_count == 0)
            $display("ALL %0d RNS CONV2 FILTER0 OUTPUTS PASSED", NUM_OUTPUTS);
        else
            $display("FAILED: %0d mismatches out of %0d", mismatch_count, NUM_OUTPUTS);

        $finish;
    end

endmodule