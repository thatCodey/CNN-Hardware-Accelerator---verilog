// ============================================================================
// File: image_bram.v
// Description:
//   BRAM for storing a 64x64 grayscale image (4096 pixels).
//
// Storage format:
//   - Each pixel is 8-bit unsigned
//   - Total entries = 64 * 64 = 4096
//
// Address mapping (IMPORTANT):
//   addr = row * 64 + col
//
// Examples:
//   row=0,  col=0   -> addr = 0
//   row=0,  col=63  -> addr = 63
//   row=1,  col=0   -> addr = 64
//   row=63, col=63  -> addr = 4095
//
// Notes:
//   - Synchronous read (Vivado BRAM friendly)
//   - Write typically controlled by software or testbench
//   - Read typically controlled by FSM during inference
// ============================================================================

module image_bram (
    input  wire        clk,

    // Write port
    input  wire        we,
    input  wire [11:0] write_addr,   // 0 to 4095
    input  wire [7:0]  write_data,

    // Read port
    input  wire [11:0] read_addr,    // 0 to 4095
    output reg  [7:0]  read_data
);

    // ------------------------------------------------------------
    // BRAM storage
    // ------------------------------------------------------------
    reg [7:0] mem [0:4095];

    integer i;

    // ------------------------------------------------------------
    // Optional initialization (simulation safety)
    // ------------------------------------------------------------
    initial begin
        for (i = 0; i < 4096; i = i + 1) begin
            mem[i] = 8'd0;
        end
    end

    // ------------------------------------------------------------
    // Synchronous write
    // ------------------------------------------------------------
    always @(posedge clk) begin
        if (we) begin
            mem[write_addr] <= write_data;
        end
    end

    // ------------------------------------------------------------
    // Synchronous read
    // ------------------------------------------------------------
    always @(posedge clk) begin
        read_data <= mem[read_addr];
    end

endmodule
