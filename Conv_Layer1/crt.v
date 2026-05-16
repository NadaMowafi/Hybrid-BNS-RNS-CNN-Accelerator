// =============================================================================
// Module  : rns_to_bns
// Purpose : RNS-to-Binary decoder via Chinese Remainder Theorem (CRT)
//
// Moduli  : m1 = 32749 ,  m2 = 65521
// Dynamic range  M = m1 × m2 = 2 145 747 229   (fits in 31 bits)
//
// CRT formula:
//   X = ( r1 * w1  +  r2 * w2 ) mod M
//
//   where the "Garner weights" w1, w2 are precomputed OFFLINE:
//
//   M1  = M / m1 = 65521
//   M2  = M / m2 = 32749
//   w1  = M1 * modInv(M1, m1)  mod M  =  746 349 711
//   w2  = M2 * modInv(M2, m2)  mod M  = 1 399 397 519
//
// Signed-number support (for CNN weights / activations):
//   After CRT reconstruction X ∈ [0, M).
//   Interpret as signed by mapping:
//       if X > M/2  →  X_signed = X − M
//   This gives the symmetric range  ( −M/2 , +M/2 ).
//
//   Output x_out is a 32-bit 2's-complement signed integer.
//
// Overflow analysis (why 64-bit intermediates are needed):
//   r1  ≤ m1 − 1 = 32 748         (16-bit)
//   w1  = 746 349 711              (30-bit)
//   r1*w1  ≤ 32748 × 746349711  ≈ 2.44 × 10^13   → 45 bits
//
//   r2  ≤ m2 − 1 = 65 520         (16-bit)
//   w2  = 1 399 397 519            (31-bit)
//   r2*w2  ≤ 65520 × 1399397519 ≈ 9.17 × 10^13   → 47 bits
//
//   sum = r1*w1 + r2*w2  ≤ 1.16 × 10^14            → 47 bits
//   → Use 64-bit integer arithmetic throughout.
//
// Latency  : Combinational (register outputs externally for pipelining)
// =============================================================================

`timescale 1ns/1ps

module rns_to_bns (
    input  wire [15:0] r1,      // residue mod 32749  (0 … 32748)
    input  wire [15:0] r2,      // residue mod 65521  (0 … 65520)
    output reg  [31:0] x_out    // reconstructed signed 32-bit integer
);

    // -----------------------------------------------------------------------
    // Precomputed CRT constants  (all verified by offline Python script)
    // -----------------------------------------------------------------------
    localparam [63:0] W1   = 64'd746349711;    // M1 * inv1 mod M
    localparam [63:0] W2   = 64'd1399397519;   // M2 * inv2 mod M
    localparam [63:0] MVAL = 64'd2145747229;   // M = m1 * m2
    localparam [63:0] MHALF= 64'd1072873614;   // floor(M / 2)  — sign threshold

    // -----------------------------------------------------------------------
    // 64-bit intermediate signals  (prevents overflow at every stage)
    // -----------------------------------------------------------------------
    wire [63:0] r1_ext = {48'd0, r1};   // zero-extend to 64 bits
    wire [63:0] r2_ext = {48'd0, r2};

    // r1 * w1  and  r2 * w2  — at most 47 bits each, safe in 64-bit
    wire [63:0] term1  = r1_ext * W1;
    wire [63:0] term2  = r2_ext * W2;

    // Sum before final mod
    wire [63:0] crt_sum = term1 + term2;

    // -----------------------------------------------------------------------
    // Final modulo M
    //
    // We cannot use Verilog '%' on a 64-bit variable modulus efficiently in
    // all tools, but here MVAL is a CONSTANT, so synthesis will convert it
    // to a multiply-add sequence.  This is synthesisable and avides a divider.
    // -----------------------------------------------------------------------
    wire [63:0] x_unsigned = crt_sum % MVAL;

    // -----------------------------------------------------------------------
    // Signed interpretation
    //   If x_unsigned > M/2  →  x_signed = x_unsigned − M
    //   Result fits in a 32-bit signed integer because |x_signed| < M/2 < 2^31
    //
    //   NOTE: Verilog-2001 does NOT allow bit-selecting an expression directly,
    //   e.g.  (a - b)[31:0]  is a syntax error (vlog-13069).
    //   Solution: store the subtraction result in a 64-bit reg first, then index.
    // -----------------------------------------------------------------------
    reg [63:0] x_diff;   // intermediate: x_unsigned - M  (wraps to 2's-complement)

    always @(*) begin
        if (x_unsigned > MHALF) begin
            // Negative value: subtract M, then take the lower 32 bits.
            // Because x_unsigned < M, the subtraction underflows — the lower
            // 32 bits of the 64-bit 2's-complement result are exactly the
            // correct signed 32-bit output.
            x_diff = x_unsigned - MVAL;
            x_out  = x_diff[31:0];
        end else begin
            x_out = x_unsigned[31:0];
        end
    end

endmodule