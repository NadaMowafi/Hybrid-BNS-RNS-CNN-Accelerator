`timescale 1ns/1ps

module tb_rns_conv2_parallel_one_pixel;

    parameter NUM_TERMS = 288;

    logic [31:0] x [0:287];
    logic [31:0] w [0:287];

    logic [31:0] bias;
    logic [31:0] y_out;

    logic [31:0] x_mem      [0:287];
    logic [31:0] w_mem      [0:287];
    logic [31:0] bias_mem   [0:0];
    logic [31:0] golden_mem [0:0];

    integer i;

    time start_time;
    time end_time;
    time total_time;

    real latency_ns;
    real throughput;

    rns_conv2_parallel_one_pixel dut (
        .x(x),
        .w(w),
        .bias(bias),
        .y_out(y_out)
    );

parameter [63:0] M_VAL = 64'd2145747229;

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

        $display("==============================================");
        $display(" Fully Parallel RNS Conv2 One-Pixel Validation ");
        $display(" 32 MAC9 blocks = 288 multiplications ");
        $display("==============================================");

        $readmemh("conv2_one_pixel_x_hex.txt", x_mem);
        $readmemh("conv2_one_pixel_w_hex.txt", w_mem);
        $readmemh("conv2_one_pixel_bias_hex.txt", bias_mem);
        $readmemh("conv2_one_pixel_golden_hex.txt", golden_mem);
        
        for (i = 0; i < NUM_TERMS; i = i + 1) begin
            x[i] = signed_to_rns_input(x_mem[i]);
            w[i] = signed_to_rns_input(w_mem[i]);
        end

        bias = signed_to_rns_input(bias_mem[0]);

        start_time = $time;

        #20;

        end_time = $time;
        total_time = end_time - start_time;

        latency_ns = total_time * 1.0;
        throughput = 1.0e9 / latency_ns;

        $display("----------------------------------------------");
        $display("Expected = %0d", $signed(golden_mem[0]));
        $display("Got      = %0d", $signed(y_out));

        if ($signed(y_out) == $signed(golden_mem[0]))
            $display("PASS");
        else
            $display("FAIL");

        $display("----------------------------------------------");
        $display("Parallel Conv2 One-Pixel Performance Report");
        $display("Total simulation time = %0d ns", total_time);
        $display("Latency/output        = %0.3f ns", latency_ns);
        $display("Throughput            = %0.3f outputs/s", throughput);
        $display("----------------------------------------------");

        $finish;
    end

endmodule