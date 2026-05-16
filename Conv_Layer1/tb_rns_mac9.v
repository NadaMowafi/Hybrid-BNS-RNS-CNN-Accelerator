`timescale 1ns/1ps

module tb_rns_mac9;

    reg [31:0] x0, x1, x2;
    reg [31:0] x3, x4, x5;
    reg [31:0] x6, x7, x8;

    reg [31:0] w0, w1, w2;
    reg [31:0] w3, w4, w5;
    reg [31:0] w6, w7, w8;

    reg [31:0] bias;
    wire [31:0] y_out;

    parameter [63:0] M_VAL = 64'd2145747229;

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

    task run_test;
        input integer tx0, tx1, tx2;
        input integer tx3, tx4, tx5;
        input integer tx6, tx7, tx8;

        input integer tw0, tw1, tw2;
        input integer tw3, tw4, tw5;
        input integer tw6, tw7, tw8;

        input integer tbias;

        begin
            expected =
                (tx0*tw0) + (tx1*tw1) + (tx2*tw2) +
                (tx3*tw3) + (tx4*tw4) + (tx5*tw5) +
                (tx6*tw6) + (tx7*tw7) + (tx8*tw8) +
                tbias;

            x0 = signed_to_rns_input(tx0);
            x1 = signed_to_rns_input(tx1);
            x2 = signed_to_rns_input(tx2);
            x3 = signed_to_rns_input(tx3);
            x4 = signed_to_rns_input(tx4);
            x5 = signed_to_rns_input(tx5);
            x6 = signed_to_rns_input(tx6);
            x7 = signed_to_rns_input(tx7);
            x8 = signed_to_rns_input(tx8);

            w0 = signed_to_rns_input(tw0);
            w1 = signed_to_rns_input(tw1);
            w2 = signed_to_rns_input(tw2);
            w3 = signed_to_rns_input(tw3);
            w4 = signed_to_rns_input(tw4);
            w5 = signed_to_rns_input(tw5);
            w6 = signed_to_rns_input(tw6);
            w7 = signed_to_rns_input(tw7);
            w8 = signed_to_rns_input(tw8);

            bias = signed_to_rns_input(tbias);

            #20;

            $display("------------------------------------");
            $display("Expected = %0d", expected);
            $display("Got      = %0d", $signed(y_out));

            if ($signed(y_out) == expected)
                $display("PASS");
            else
                $display("FAIL");
        end
    endtask

    initial begin
        $display("=====================================");
        $display(" Testing RNS MAC9: 3x3 convolution ");
        $display("=====================================");

        run_test(
            1, 2, 3,
            4, 5, 6,
            7, 8, 9,

            1, 1, 1,
            1, 1, 1,
            1, 1, 1,

            0
        );

        run_test(
            1, 2, 3,
            4, 5, 6,
            7, 8, 9,

            -1, 2, -3,
            4, -5, 6,
            -7, 8, -9,

            10
        );

        run_test(
            -5, 3, 2,
            7, -1, 4,
            6, 0, -2,

            3, -2, 5,
            -1, 4, -6,
            2, 7, -3,

            -20
        );

        run_test(
            0, 0, 0,
            0, -868, -868,
            0, -868, -868,

            -93, -191, 366,
            -620, 162, 312,
            -227, 46, 150,

            -496735
        );

        $finish;
    end

endmodule