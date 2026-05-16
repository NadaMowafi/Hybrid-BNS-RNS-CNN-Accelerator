
`timescale 1ns/1ps

// =============================================================================
// Module definition
// =============================================================================

module bns_to_rns (
    input  wire [31:0] x_in,   
    output wire [15:0] r1,     
    output wire [15:0] r2      
);

    // -----------------------------------------------------------------------
    // Modulus constants
    // -----------------------------------------------------------------------
    localparam [31:0] M1 = 32'd32749;
    localparam [31:0] M2 = 32'd65521;

    

    // --- Precomputed shift constants (evaluated at elaboration, not runtime) ---
    localparam [31:0] POW16_MOD_M1 = (32'd65536) % M1;   
    localparam [31:0] POW16_MOD_M2 = (32'd65536) % M2;   

    // --- Split input ---
    wire [15:0] x_lo = x_in[15:0];
    wire [15:0] x_hi = x_in[31:16];

    // --- Reduce low half 
    wire [31:0] lo_mod_m1 = (x_lo >= M1) ? (x_lo - M1) : x_lo;
    wire [31:0] lo_mod_m2 = (x_lo >= M2) ? (x_lo - M2) : x_lo;

    // --- Reduce high half (x_hi < 2^16, same bounds as above) ---
    wire [31:0] hi_mod_m1 = (x_hi >= M1) ? (x_hi - M1) : x_hi;
    wire [31:0] hi_mod_m2 = (x_hi >= M2) ? (x_hi - M2) : x_hi;

    // --- Scale high residue 

    wire [31:0] hi_scaled_m1 = (hi_mod_m1 * POW16_MOD_M1) % M1;
    wire [31:0] hi_scaled_m2 = (hi_mod_m2 * POW16_MOD_M2) % M2;

    // --- Combine: (hi_scaled + lo_mod) mod m ---

    wire [31:0] sum_m1 = hi_scaled_m1 + lo_mod_m1;
    wire [31:0] sum_m2 = hi_scaled_m2 + lo_mod_m2;

    wire [31:0] res_m1 = (sum_m1 >= M1) ? (sum_m1 - M1) : sum_m1;
    wire [31:0] res_m2 = (sum_m2 >= M2) ? (sum_m2 - M2) : sum_m2;

    // --- Output assignment ---
    assign r1 = res_m1[15:0];
    assign r2 = res_m2[15:0];

endmodule