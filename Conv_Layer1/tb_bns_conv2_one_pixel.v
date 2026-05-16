`timescale 1ns/1ps

module tb_bns_conv2_one_pixel;

    parameter NUM_TERMS = 288;

    reg [31:0] x_mem [0:NUM_TERMS-1];
    reg [31:0] w_mem [0:NUM_TERMS-1];
    reg [31:0] bias_mem [0:0];
    reg [31:0] golden_mem [0:0];

    reg signed [31:0] x_val;
    reg signed [31:0] w_val;
    reg signed [31:0] bias;

    integer i;
    reg signed [63:0] acc;
    reg signed [63:0] product;

    initial begin
        $display("=====================================");
        $display(" BNS Conv2 One-Pixel Validation ");
        $display("=====================================");

        $readmemh("conv2_one_pixel_x_hex.txt", x_mem);
        $readmemh("conv2_one_pixel_w_hex.txt", w_mem);
        $readmemh("conv2_one_pixel_bias_hex.txt", bias_mem);
        $readmemh("conv2_one_pixel_golden_hex.txt", golden_mem);

        bias = bias_mem[0];
        acc = bias;

        for (i = 0; i < NUM_TERMS; i = i + 1) begin
            x_val = x_mem[i];
            w_val = w_mem[i];

            product = x_val * w_val;
            acc = acc + product;
        end

        $display("Expected = %0d", $signed(golden_mem[0]));
        $display("Got      = %0d", $signed(acc[31:0]));

        if ($signed(acc[31:0]) == $signed(golden_mem[0]))
            $display("PASS");
        else
            $display("FAIL");

        $finish;
    end

endmodule