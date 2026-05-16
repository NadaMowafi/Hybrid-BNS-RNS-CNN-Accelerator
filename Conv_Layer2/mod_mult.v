`timescale 1ns/1ps

module mod_mult #(
    parameter M          = 32749,       // RNS modulus (compile-time constant)
    parameter WIDTH      = 16,          // Bit-width of each input operand
    parameter PROD_WIDTH = 2 * WIDTH    // Bit-width of the full product (32 for WIDTH=16)
)(
    input  wire [WIDTH-1:0]      a,     // 0 ≤ a < M
    input  wire [WIDTH-1:0]      b,     // 0 ≤ b < M
    output wire [WIDTH-1:0]      y      // y = (a * b) mod M,  0 ≤ y < M
);

    // -------------------------------------------------------------------------
    // Step 1 – Widen the product
    // -------------------------------------------------------------------------
    // Declare a PROD_WIDTH-wide wire so the full a*b result is captured without
    // truncation.  For WIDTH=16, PROD_WIDTH=32 and the product fits in [0, M²).
    // Since M < 2^16, M² < 2^32 — 32 bits are sufficient.
    // -------------------------------------------------------------------------
    wire [PROD_WIDTH-1:0] product;
    assign product = a * b;             // Zero-extended multiply; no overflow

    // -------------------------------------------------------------------------
    // Step 2 – Reduce modulo M
    // -------------------------------------------------------------------------
    // `product % M` with M a parameter is synthesised as a constant-divisor
    // combinational circuit.  The result is at most WIDTH bits wide because
    // y < M < 2^WIDTH.
    // -------------------------------------------------------------------------
    assign y = product % M;

endmodule


// =============================================================================
// Convenience wrappers — one per RNS channel
// =============================================================================
//
// These thin wrappers fix the modulus and width so the integrating level
// (e.g. rns_mac_cell.v) can instantiate a named, self-documenting module
// without repeating parameter overrides everywhere.
// =============================================================================

// Channel 1 — m1 = 32749 = 2^15 − 19
module mod_mult_m32749 (
    input  wire [15:0] a,
    input  wire [15:0] b,
    output wire [15:0] y
);
    mod_mult #(
        .M          (32749),
        .WIDTH      (16),
        .PROD_WIDTH (32)
    ) u_mult (
        .a (a),
        .b (b),
        .y (y)
    );
endmodule


// Channel 2 — m2 = 65521 = 2^16 − 15
module mod_mult_m65521 (
    input  wire [15:0] a,
    input  wire [15:0] b,
    output wire [15:0] y
);
    mod_mult #(
        .M          (65521),
        .WIDTH      (16),
        .PROD_WIDTH (32)
    ) u_mult (
        .a (a),
        .b (b),
        .y (y)
    );
endmodule