`timescale 1ns/1ps

module tb_bns_conv2_all_filters;

    parameter NUM_OUTPUTS = 12544;
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

    time start_time;
    time end_time;
    real total_time_ns;
    real latency_ns;
    real throughput;

    initial begin

        mismatch_count = 0;

        $display("========================================");
        $display(" Full Conv2 All Filters BNS Validation ");
        $display(" 12544 outputs, 288 MAC terms each ");
        $display("========================================");

        $readmemh("conv2_all_filters_x_hex.txt", x_mem);
        $readmemh("conv2_all_filters_w_hex.txt", w_mem);
        $readmemh("conv2_all_filters_bias_hex.txt", bias_mem);
        $readmemh("conv2_all_filters_goldens_hex.txt", golden_mem);

        start_time = $time;

        for (out_idx = 0; out_idx < NUM_OUTPUTS; out_idx = out_idx + 1) begin

            base = out_idx * NUM_TERMS;

            acc = bias_mem[out_idx];

            for (i = 0; i < NUM_TERMS; i = i + 1) begin
                acc = acc + (x_mem[base+i] * w_mem[base+i]);
            end

            #20;

            if ($signed(acc[31:0]) !== $signed(golden_mem[out_idx])) begin

                $display("MISMATCH output=%0d expected=%0d got=%0d",
                         out_idx,
                         $signed(golden_mem[out_idx]),
                         $signed(acc[31:0]));

                mismatch_count = mismatch_count + 1;
            end
        end

        end_time = $time;

        total_time_ns = end_time - start_time;
        latency_ns = total_time_ns / NUM_OUTPUTS;
        throughput = 1e9 / latency_ns;

        $display("----------------------------------------");
        $display("BNS Conv2 Performance Report");
        $display("Total outputs            = %0d", NUM_OUTPUTS);
        $display("Total simulation time    = %0f ns", total_time_ns);
        $display("Latency/output           = %0.3f ns", latency_ns);
        $display("Throughput               = %0.3f outputs/s", throughput);
        $display("----------------------------------------");

        if (mismatch_count == 0)
            $display("ALL %0d BNS CONV2 OUTPUTS PASSED", NUM_OUTPUTS);
        else
            $display("FAILED: %0d mismatches", mismatch_count);

        $finish;
    end

endmodule