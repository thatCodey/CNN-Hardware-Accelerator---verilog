// ============================================================================
// File: feature_map_bram.v
// Description:
//   Generic BRAM for storing intermediate CNN feature maps.
//
// Key properties:
//   - Parameterized depth and data width
//   - Signed fixed-point storage
//   - Synchronous write and synchronous read (Vivado BRAM friendly)
//   - No combinational reads
//   - No unintended latches
//
// Reuse model (IMPORTANT):
//   - The SAME BRAM can be reused across CNN stages by the FSM
//   - FSM controls:
//       * write enable (we)
//       * address sequencing
//   - Typical usage:
//       * CONV output  -> write to BRAM
//       * POOL reads   -> read from BRAM
//       * GAP reads    -> read from BRAM
//
// Addressing:
//   - Address meaning is stage-dependent and controlled by FSM
//   - Example:
//       addr = row * WIDTH + col   (for 2D feature maps)
//
// This module is intentionally simple and safe.
// ============================================================================

module feature_map_bram #(
    parameter DEPTH = 2048,                // number of entries
    parameter WIDTH = 16                   // data width (signed fixed-point)
)(
    input  wire                   clk,

    // Write port
    input  wire                   we,
    input  wire [$clog2(DEPTH)-1:0] addr,
    input  wire signed [WIDTH-1:0] data_in,

    // Read port
    output reg  signed [WIDTH-1:0] data_out
);

    // ------------------------------------------------------------
    // BRAM storage
    // ------------------------------------------------------------
    reg signed [WIDTH-1:0] mem [0:DEPTH-1];

    integer i;

    // ------------------------------------------------------------
    // Optional initialization (simulation safety)
    // ------------------------------------------------------------
    initial begin
        for (i = 0; i < DEPTH; i = i + 1) begin
            mem[i] = {WIDTH{1'b0}};
        end
    end

    // ------------------------------------------------------------
    // Synchronous write
    // ------------------------------------------------------------
    always @(posedge clk) begin
        if (we) begin
            mem[addr] <= data_in;
        end
    end

    // ------------------------------------------------------------
    // Synchronous read
    // ------------------------------------------------------------
    always @(posedge clk) begin
        data_out <= mem[addr];
    end

endmodule
