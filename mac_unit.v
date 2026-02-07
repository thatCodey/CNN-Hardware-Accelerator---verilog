/*
 * Module: mac_unit
 * Standard: Verilog-2001
 * * Purpose: Performs acc = acc + (a * b) using signed fixed-point logic.
 * Designed for Vivado synthesis.
 */

module mac_unit (
    input                      clk,      // Clock
    input                      rst,      // Asynchronous Reset (Active High)
    input                      enable,   // Enable MAC operation
    input                      clear,    // Synchronous Clear for accumulator
    input  signed [7:0]        a,        // Multiplicand (8-bit signed)
    input  signed [7:0]        b,        // Multiplier   (8-bit signed)
    output reg signed [23:0]   acc_out   // Accumulator  (24-bit signed)
);

    // Internal wire for the product
    // 8-bit signed * 8-bit signed results in a 15-bit value + sign bit (16 bits)
    wire signed [15:0] product;
    assign product = a * b;

    // Sequential Logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            acc_out <= 24'd0;
        end else begin
            if (clear) begin
                acc_out <= 24'd0;
            end else if (enable) begin
                /* * FIXED-POINT SAFETY:
                 * Adding a 16-bit signed product to a 24-bit accumulator.
                 * The sign-extension is handled automatically by the 'signed' 
                 * reg/wire types. 24 bits provides 8 bits of "guard" overhead,
                 * preventing overflow for up to 256 consecutive MAC cycles.
                 */
                acc_out <= acc_out + product;
            end
            // Implicit else: acc_out <= acc_out (hold value)
        end
    end

    // Simulation-only Debugging
    `ifndef SYNTHESIS
    always @(posedge clk) begin
        if (enable && !rst && !clear) begin
            $display("DEBUG [MAC]: Time=%0t | a=%d b=%d | Prod=%d | Acc_New=%d", 
                      $time, a, b, product, acc_out + product);
        end
    end
    `endif

endmodule
