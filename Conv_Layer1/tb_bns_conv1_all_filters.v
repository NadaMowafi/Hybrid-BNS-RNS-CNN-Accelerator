`timescale 1ns/1ps

module tb_bns_conv1_all_filters;

    time start_time;
    time end_time;
    time total_time;

    reg signed [31:0] x0, x1, x2;
    reg signed [31:0] x3, x4, x5;
    reg signed [31:0] x6, x7, x8;

    reg signed [31:0] w0, w1, w2;
    reg signed [31:0] w3, w4, w5;
    reg signed [31:0] w6, w7, w8;

    reg signed [31:0] bias;
    wire signed [31:0] y_out;

    parameter NUM_TESTS = 25088;

    reg [31:0] input_mem  [0:NUM_TESTS*19-1];
    reg [31:0] golden_mem [0:NUM_TESTS-1];

    integer i;
    integer base;
    integer mismatch_count;
    integer expected;

    real latency_per_mac9_ns;
    real throughput_mac9_per_s;

    bns_mac9 dut (
        .x0(x0), .x1(x1), .x2(x2),
        .x3(x3), .x4(x4), .x5(x5),
        .x6(x6), .x7(x7), .x8(x8),

        .w0(w0), .w1(w1), .w2(w2),
        .w3(w3), .w4(w4), .w5(w5),
        .w6(w6), .w7(w7), .w8(w8),

        .bias(bias),
        .y_out(y_out)
    );

    initial begin
        mismatch_count = 0;

        $display("========================================");
        $display(" Full Conv1 All Filters BNS Validation ");
        $display(" 25088 MAC9 operations                 ");
        $display("========================================");

        $readmemh("conv1_all_filters_mac9_inputs_hex.txt", input_mem);
        $readmemh("conv1_all_filters_mac9_goldens_hex.txt", golden_mem);

        start_time = $time;

        for (i = 0; i < NUM_TESTS; i = i + 1) begin

            base = i * 19;

            x0 = input_mem[base + 0];
            x1 = input_mem[base + 1];
            x2 = input_mem[base + 2];

            x3 = input_mem[base + 3];
            x4 = input_mem[base + 4];
            x5 = input_mem[base + 5];

            x6 = input_mem[base + 6];
            x7 = input_mem[base + 7];
            x8 = input_mem[base + 8];

            w0 = input_mem[base + 9];
            w1 = input_mem[base + 10];
            w2 = input_mem[base + 11];

            w3 = input_mem[base + 12];
            w4 = input_mem[base + 13];
            w5 = input_mem[base + 14];

            w6 = input_mem[base + 15];
            w7 = input_mem[base + 16];
            w8 = input_mem[base + 17];

            bias = input_mem[base + 18];

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

        $display("----------------------------------------");
        $display("BNS Conv1 Performance Report");
        $display("Total tests / outputs      = %0d", NUM_TESTS);
        $display("Total simulation time      = %0d ns", total_time);
        $display("Latency per MAC9 output    = %0.3f ns", latency_per_mac9_ns);
        $display("Throughput                 = %0.3f MAC9 outputs/s", throughput_mac9_per_s);
        $display("----------------------------------------");

        if (mismatch_count == 0)
            $display("ALL %0d CONV1 ALL FILTER TESTS PASSED", NUM_TESTS);
        else
            $display("FAILED: %0d mismatches out of %0d", mismatch_count, NUM_TESTS);

        $finish;
    end

endmodule