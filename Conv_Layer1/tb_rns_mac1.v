`timescale 1ns/1ps

module tb_rns_mac1;

    reg  [31:0] x_in;
    reg  [31:0] w_in;
    reg  [31:0] bias_in;
    wire [31:0] y_out;

    parameter [63:0] M_VAL = 64'd2145747229;

    integer expected;

    rns_mac1 dut (
        .x_in(x_in),
        .w_in(w_in),
        .bias_in(bias_in),
        .y_out(y_out)
    );

    // Convert signed integer to canonical RNS input representation
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
        input integer x;
        input integer w;
        input integer b;
        begin
            expected = (x * w) + b;

            x_in    = signed_to_rns_input(x);
            w_in    = signed_to_rns_input(w);
            bias_in = signed_to_rns_input(b);

            #10;

            $display("x=%0d, w=%0d, bias=%0d", x, w, b);
            $display("Expected = %0d", expected);
            $display("Got      = %0d", $signed(y_out));

            if ($signed(y_out) == expected)
                $display("PASS\n");
            else
                $display("FAIL\n");
        end
    endtask

    initial begin
        $display("=================================");
        $display(" Testing RNS MAC1: y = x*w + b ");
        $display("=================================");

        run_test(5, 3, 2);        // 5*3 + 2 = 17
        run_test(-5, 3, 2);       // -15 + 2 = -13
        run_test(5, -3, 2);       // -15 + 2 = -13
        run_test(-5, -3, 2);      // 15 + 2 = 17
        run_test(12, -7, -4);     // -84 - 4 = -88
        run_test(100, 25, -30);   // 2500 - 30 = 2470

        $finish;
    end

endmodule