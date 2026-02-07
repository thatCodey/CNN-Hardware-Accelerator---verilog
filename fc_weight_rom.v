// ============================================================================
// File: fc_weight_rom.v
// Description:
//   ROM for Fully Connected (FC) layer parameters.
//
// Contents:
//   - 8 weights (for inputs index 0..7)
//   - 1 bias
//
// Address Mapping (IMPORTANT):
//   addr = 0  -> weight for input 0
//   addr = 1  -> weight for input 1
//   addr = 2  -> weight for input 2
//   addr = 3  -> weight for input 3
//   addr = 4  -> weight for input 4
//   addr = 5  -> weight for input 5
//   addr = 6  -> weight for input 6
//   addr = 7  -> weight for input 7
//   addr = 8  -> bias
//
// Example usage:
//   - During FC MAC cycle i (0..7): read addr = i
//   - After final MAC: read addr = 8 for bias
//
// Notes:
//   - Initial values are temporary for RTL bring-up:
//       weights = +1
//       bias    =  0
//   - Replace initialization with $readmemh/$readmemb
//     when trained weights are available.
// ============================================================================

module fc_weight_rom (
    input  wire        clk,
    input  wire [3:0]  addr,        // 0 to 8
    output reg  signed [7:0] weight_out,
    output reg  signed [15:0] bias_out
);

    // ------------------------------------------------------------
    // ROM storage
    // ------------------------------------------------------------
    reg signed [7:0]  weight_mem [0:7];
    reg signed [15:0] bias_mem;

    integer i;

    // ------------------------------------------------------------
    // Initial block: temporary values for testing
    // ------------------------------------------------------------
    initial begin
        for (i = 0; i < 8; i = i + 1) begin
            weight_mem[i] = 8'sd1;   // temporary weight
        end
        bias_mem = 16'sd0;           // temporary bias
    end

    // ------------------------------------------------------------
    // Synchronous read
    // ------------------------------------------------------------
    always @(posedge clk) begin
        if (addr < 4'd8) begin
            weight_out <= weight_mem[addr];
            bias_out   <= 16'sd0;
        end else begin
            // addr == 8 → bias
            weight_out <= 8'sd0;
            bias_out   <= bias_mem;
        end
    end

endmodule
