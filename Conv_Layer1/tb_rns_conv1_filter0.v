`timescale 1ns/1ps

module tb_rns_conv1_filter0;

    reg [31:0] x0, x1, x2;
    reg [31:0] x3, x4, x5;
    reg [31:0] x6, x7, x8;

    reg [31:0] w0, w1, w2;
    reg [31:0] w3, w4, w5;
    reg [31:0] w6, w7, w8;

    reg [31:0] bias;
    wire [31:0] y_out;

    parameter [63:0] M_VAL = 64'd2145747229;
    parameter NUM_TESTS = 784;

    integer inputs [0:NUM_TESTS-1][0:18];
    integer goldens [0:NUM_TESTS-1];

    integer i;
    integer mismatch_count;
    integer expected;

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
        input integer val;
        reg [63:0] temp;
        begin
            if (val < 0)
                temp = M_VAL + val;
            else
                temp = val;

            signed_to_rns_input = temp[31:0];
        end
    endfunction

    initial begin
        mismatch_count = 0;

        $display("========================================");
        $display(" Testing full Conv1 filter0 feature map ");
        $display(" 784 MAC9 operations                    ");
        $display("========================================");

        $readmemh("conv1_filter0_mac9_inputs_hex.txt", inputs);
        $readmemh("conv1_filter0_mac9_goldens_hex.txt", goldens);

        for (i = 0; i < NUM_TESTS; i = i + 1) begin

            x0 = signed_to_rns_input(inputs[i][0]);
            x1 = signed_to_rns_input(inputs[i][1]);
            x2 = signed_to_rns_input(inputs[i][2]);
            x3 = signed_to_rns_input(inputs[i][3]);
            x4 = signed_to_rns_input(inputs[i][4]);
            x5 = signed_to_rns_input(inputs[i][5]);
            x6 = signed_to_rns_input(inputs[i][6]);
            x7 = signed_to_rns_input(inputs[i][7]);
            x8 = signed_to_rns_input(inputs[i][8]);

            w0 = signed_to_rns_input(inputs[i][9]);
            w1 = signed_to_rns_input(inputs[i][10]);
            w2 = signed_to_rns_input(inputs[i][11]);
            w3 = signed_to_rns_input(inputs[i][12]);
            w4 = signed_to_rns_input(inputs[i][13]);
            w5 = signed_to_rns_input(inputs[i][14]);
            w6 = signed_to_rns_input(inputs[i][15]);
            w7 = signed_to_rns_input(inputs[i][16]);
            w8 = signed_to_rns_input(inputs[i][17]);

            bias = signed_to_rns_input(inputs[i][18]);

            expected = goldens[i];

            #20;

            if ($signed(y_out) !== expected) begin
                $display("MISMATCH i=%0d expected=%0d got=%0d",
                         i, expected, $signed(y_out));
                mismatch_count = mismatch_count + 1;
            end
        end

        if (mismatch_count == 0)
            $display("ALL %0d CONV1 FILTER0 TESTS PASSED", NUM_TESTS);
        else
            $display("FAILED: %0d mismatches out of %0d", mismatch_count, NUM_TESTS);

        $finish;
    end

endmodule