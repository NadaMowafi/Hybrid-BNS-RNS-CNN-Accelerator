module mod_add #(
    parameter M     = 32749,
    parameter WIDTH = 16
)(
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    output wire [WIDTH-1:0] y
);

    wire [WIDTH:0] sum;
    wire [WIDTH:0] M_ext;

    assign sum   = {1'b0, a} + {1'b0, b};
    assign M_ext = M;

    assign y = (sum >= M_ext) ? (sum - M_ext) : sum[WIDTH-1:0];

endmodule