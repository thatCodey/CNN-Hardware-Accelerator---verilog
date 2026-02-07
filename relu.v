/*
 * Module: relu
 * Standard: Verilog-2001
 * Purpose: Implements out = max(0, in_data) with registered output.
 */

module relu (
    input                       clk,
    input                       rst,
    input  signed [15:0]        in_data,
    input                       valid_in,
    output reg signed [15:0]    out_data,
    output reg                  valid_out
);

    // Sequential Logic with 1-cycle latency
    always @(posedge clk) begin
        if (rst) begin
            out_data  <= 16'sd0;
            valid_out <= 1'b0;
        end else begin
            // Pass the valid signal through the register stage
            valid_out <= valid_in;

            if (valid_in) begin
                /* * LOGIC PATH:
                 * In Two's Complement, the Most Significant Bit (MSB) 
                 * determines the sign.
                 * - MSB = 1: Value is Negative -> Output 0
                 * - MSB = 0: Value is Positive -> Output input
                 */
                if (in_data[15] == 1'b1) begin
                    // Input is negative
                    out_data <= 16'sd0;
                end else begin
                    // Input is positive or zero
                    out_data <= in_data;
                end
            end
        end
    end

endmodule
