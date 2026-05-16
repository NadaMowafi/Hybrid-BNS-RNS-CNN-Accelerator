`timescale 1ns/1ps

module tb_rns_conv2_parallel_all_filters;

    parameter NUM_OUTPUTS = 12544;
    parameter NUM_TERMS   = 288;
    parameter TOTAL_TERMS = NUM_OUTPUTS * NUM_TERMS;

    parameter [63:0] M_VAL = 64'd2145747229;

    logic [31:0] x [0:287];
    logic [31:0] w [0:287];
    logic [31:0] bias;
    logic [31:0] y_out;

    logic [31:0] x_mem      [0:TOTAL_TERMS-1];
    logic [31:0] w_mem      [0:TOTAL_TERMS-1];
    logic [31:0] bias_mem   [0:NUM_OUTPUTS-1];
    logic [31:0] golden_mem [0:NUM_OUTPUTS-1];

    integer out_idx;
    integer i;
    integer base;
    integer mismatch_count;

    time start_time;
    time end_time;
    time total_time;

    real latency_per_output_ns;
    real throughput_outputs_per_s;

    rns_conv2_parallel_one_pixel dut (
        .x(x),
        .w(w),
        .bias(bias),
        .y_out(y_out)
    );

    function logic [31:0] signed_to_rns_input;
        input logic [31:0] val;

        logic signed [31:0] sval;
        logic [63:0] temp;

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

        $display("================================================");
        $display(" Fully Parallel RNS Conv2 All Filters ");
        $display(" 12544 outputs, 288 MAC terms/output ");
        $display("================================================");

        $readmemh("conv2_all_filters_x_hex.txt", x_mem);
        $readmemh("conv2_all_filters_w_hex.txt", w_mem);
        $readmemh("conv2_all_filters_bias_hex.txt", bias_mem);
        $readmemh("conv2_all_filters_goldens_hex.txt", golden_mem);

        start_time = $time;

        for (out_idx = 0; out_idx < NUM_OUTPUTS; out_idx = out_idx + 1) begin

            base = out_idx * NUM_TERMS;

            for (i = 0; i < NUM_TERMS; i = i + 1) begin
                x[i] = signed_to_rns_input(x_mem[base + i]);
                w[i] = signed_to_rns_input(w_mem[base + i]);
            end

            bias = signed_to_rns_input(bias_mem[out_idx]);

            #20;

            if ($signed(y_out) !== $signed(golden_mem[out_idx])) begin
                $display("MISMATCH output=%0d expected=%0d got=%0d",
                         out_idx,
                         $signed(golden_mem[out_idx]),
                         $signed(y_out));

                mismatch_count = mismatch_count + 1;
            end
        end

        end_time = $time;
        total_time = end_time - start_time;

        latency_per_output_ns = total_time * 1.0 / NUM_OUTPUTS;
        throughput_outputs_per_s = NUM_OUTPUTS * 1.0e9 / total_time;

        $display("----------------------------------------------");
        $display("Parallel RNS Conv2 All Filters Performance Report");
        $display("Total outputs            = %0d", NUM_OUTPUTS);
        $display("Total simulation time    = %0d ns", total_time);
        $display("Latency/output           = %0.3f ns", latency_per_output_ns);
        $display("Throughput               = %0.3f outputs/s", throughput_outputs_per_s);
        $display("----------------------------------------------");

        if (mismatch_count == 0)
            $display("ALL %0d PARALLEL RNS CONV2 OUTPUTS PASSED", NUM_OUTPUTS);
        else
            $display("FAILED: %0d mismatches out of %0d", mismatch_count, NUM_OUTPUTS);

        $finish;
    end

endmodule