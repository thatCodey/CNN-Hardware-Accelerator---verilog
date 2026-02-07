// ============================================================================
// File: conv_weight_rom.v
// Description:
//   ROM for convolution weights: 3x3 kernel, 1 input channel, 8 filters.
//   Total weights = 3 * 3 * 1 * 8 = 72
//
// Address Mapping (IMPORTANT):
//   addr = filter_index * 9 + kernel_index
//
//   kernel_index mapping (within each filter):
//     0 -> p00   1 -> p01   2 -> p02
//     3 -> p10   4 -> p11   5 -> p12
//     6 -> p20   7 -> p21   8 -> p22
//
// Example:
//   filter_index = 0, kernel_index = 0  -> addr = 0
//   filter_index = 0, kernel_index = 8  -> addr = 8
//   filter_index = 1, kernel_index = 0  -> addr = 9
//   filter_index = 7, kernel_index = 8  -> addr = 71
//
// Notes:
//   - All weights are initialized to +1 for temporary testing.
//   - Later, replace initialization with $readmemh/$readmemb
//     using trained weights without changing RTL.
// ============================================================================

module conv_weight_rom (
    input  wire        clk,
    input  wire [6:0]  addr,        // 0 to 71
    output reg  signed [7:0] weight_out
);

    // ------------------------------------------------------------
    // ROM storage: 72 signed 8-bit weights
    // ------------------------------------------------------------
    reg signed [7:0] weight_mem [0:71];

    integer i;

    // ------------------------------------------------------------
    // Initial block: temporary weights = +1
    // ------------------------------------------------------------
    initial begin
        for (i = 0; i < 72; i = i + 1) begin
            weight_mem[i] = 8'sd1;
        end
    end

    // ------------------------------------------------------------
    // Synchronous ROM read
    // ------------------------------------------------------------
    always @(posedge clk) begin
        weight_out <= weight_mem[addr];
    end

endmodule
