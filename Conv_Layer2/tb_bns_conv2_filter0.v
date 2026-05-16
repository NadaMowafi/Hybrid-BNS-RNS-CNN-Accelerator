`timescale 1ns/1ps

module tb_bns_conv2_filter0;

    parameter NUM_OUTPUTS = 196;
    parameter NUM_TERMS   = 288;
    parameter TOTAL_TERMS = NUM_OUTPUTS * NUM_TERMS;

    reg signed [31:0] x_mem      [0:TOTAL_TERMS-1];
    reg signed [31:0] w_mem      [0:TOTAL_TERMS-1];
    reg signed [31:0] bias_mem   [0:NUM_OUTPUTS-1];
    reg signed [31:0] golden_mem [0:NUM_OUTPUTS-1];

    integer out_idx;
    integer i;
    integer base;
    integer mismatch_count;

    reg signed [63:0] acc;

    initial begin
        mismatch_count = 0;

        $display("=====================================");
        $display(" BNS Conv2 Filter0 Full Map ");
        $display(" 196 outputs, 288 MAC terms each ");
        $display("=====================================");

        $readmemh("conv2_filter0_x_hex.txt", x_mem);
        $readmemh("conv2_filter0_w_hex.txt", w_mem);
        $readmemh("conv2_filter0_bias_hex.txt", bias_mem);
        $readmemh("conv2_filter0_goldens_hex.txt", golden_mem);

        for (out_idx = 0; out_idx < NUM_OUTPUTS; out_idx = out_idx + 1) begin

            base = out_idx * NUM_TERMS;
            acc = bias_mem[out_idx];

            for (i = 0; i < NUM_TERMS; i = i + 1) begin
                acc = acc + (x_mem[base + i] * w_mem[base + i]);
            end

            if ($signed(acc[31:0]) !== $signed(golden_mem[out_idx])) begin
                $display("MISMATCH output=%0d expected=%0d got=%0d",
                         out_idx, $signed(golden_mem[out_idx]), $signed(acc[31:0]));
                mismatch_count = mismatch_count + 1;
            end
        end

        if (mismatch_count == 0)
            $display("ALL %0d BNS CONV2 FILTER0 OUTPUTS PASSED", NUM_OUTPUTS);
        else
            $display("FAILED: %0d mismatches out of %0d", mismatch_count, NUM_OUTPUTS);

        $finish;
    end

endmodule