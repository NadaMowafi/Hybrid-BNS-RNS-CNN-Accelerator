`timescale 1ns/1ps

module tb_rns_conv1_all_filters;

    time start_time;
    time end_time;
    time total_time;

    reg [31:0] x0, x1, x2;
    reg [31:0] x3, x4, x5;
    reg [31:0] x6, x7, x8;

    reg [31:0] w0, w1, w2;
    reg [31:0] w3, w4, w5;
    reg [31:0] w6, w7, w8;

    reg [31:0] bias;
    wire [31:0] y_out;

    parameter [63:0] M_VAL = 64'd2145747229;
    parameter NUM_TESTS = 25088;

    reg [31:0] input_mem  [0:NUM_TESTS*19-1];
    reg [31:0] golden_mem [0:NUM_TESTS-1];

    integer i;
    integer base;
    integer mismatch_count;
    integer expected;

    real latency_per_mac9_ns;
    real throughput_mac9_per_s;
    real throughput_outputs_per_s;

    rns_mac9 dut (
        .x0(x0), .x1(x1), .x2(x2),
        .x3(x3), .x4(x4), .x5(x5),
        .x6(x6), .x7(x7), .x8(x8),

        .w0(w0), .w1(w1), .w2(w2),
        .w3(w3), .w4(w4), .w5(w5),
        .w6(w6), .w7(w7), .w8(w8),

        .bias(bias),
        .y_out(y_out)
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

        $display("========================================");
        $display(" Full Conv1 All Filters RNS Validation ");
        $display(" 25088 MAC9 operations                 ");
        $display("========================================");

        $readmemh("conv1_all_filters_mac9_inputs_hex.txt", input_mem);
        $readmemh("conv1_all_filters_mac9_goldens_hex.txt", golden_mem);

        // Start timing AFTER file loading
        start_time = $time;

        for (i = 0; i < NUM_TESTS; i = i + 1) begin

            base = i * 19;

            x0 = signed_to_rns_input(input_mem[base + 0]);
            x1 = signed_to_rns_input(input_mem[base + 1]);
            x2 = signed_to_rns_input(input_mem[base + 2]);

            x3 = signed_to_rns_input(input_mem[base + 3]);
            x4 = signed_to_rns_input(input_mem[base + 4]);
            x5 = signed_to_rns_input(input_mem[base + 5]);

            x6 = signed_to_rns_input(input_mem[base + 6]);
            x7 = signed_to_rns_input(input_mem[base + 7]);
            x8 = signed_to_rns_input(input_mem[base + 8]);

            w0 = signed_to_rns_input(input_mem[base + 9]);
            w1 = signed_to_rns_input(input_mem[base + 10]);
            w2 = signed_to_rns_input(input_mem[base + 11]);

            w3 = signed_to_rns_input(input_mem[base + 12]);
            w4 = signed_to_rns_input(input_mem[base + 13]);
            w5 = signed_to_rns_input(input_mem[base + 14]);

            w6 = signed_to_rns_input(input_mem[base + 15]);
            w7 = signed_to_rns_input(input_mem[base + 16]);
            w8 = signed_to_rns_input(input_mem[base + 17]);

            bias = signed_to_rns_input(input_mem[base + 18]);

            expected = golden_mem[i];

            #20;

            if ($signed(y_out) !== $signed(expected)) begin
                $display("----------------------------------------");
                $display("MISMATCH at test i = %0d", i);
                $display("Expected = %0d", $signed(expected));
                $display("Got      = %0d", $signed(y_out));
                mismatch_count = mismatch_count + 1;
            end
        end

        end_time = $time;
        total_time = end_time - start_time;

        latency_per_mac9_ns = total_time * 1.0 / NUM_TESTS;
        throughput_mac9_per_s = NUM_TESTS * 1.0e9 / total_time;
        throughput_outputs_per_s = throughput_mac9_per_s;

        $display("----------------------------------------");
        $display("RNS Conv1 Performance Report");
        $display("Total tests / outputs      = %0d", NUM_TESTS);
        $display("Total simulation time      = %0d ns", total_time);
        $display("Latency per MAC9 output    = %0.3f ns", latency_per_mac9_ns);
        $display("Throughput                 = %0.3f MAC9 outputs/s", throughput_mac9_per_s);
        $display("Throughput                 = %0.3f Conv1 outputs/s", throughput_outputs_per_s);
        $display("----------------------------------------");

        if (mismatch_count == 0)
            $display("ALL %0d CONV1 ALL FILTER TESTS PASSED", NUM_TESTS);
        else
            $display("FAILED: %0d mismatches out of %0d", mismatch_count, NUM_TESTS);

        $finish;
    end

endmodule