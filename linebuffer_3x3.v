// ============================================================================
// File: linebuffer_3x3.v
// Description:
//   3x3 line buffer for streaming 2D images.
//   Generates valid convolution windows ONLY when fully inside image bounds.
//
// Image assumptions:
//   - Image streamed row by row
//   - One pixel per cycle when pixel_valid = 1
//   - Default image width = 64 pixels
//
// Window mapping (when window_valid = 1):
//   p00 p01 p02   ← row-2
//   p10 p11 p12   ← row-1
//   p20 p21 p22   ← row
//
// window_valid asserted ONLY when:
//   row >= 2 AND col >= 2
// ============================================================================

module linebuffer_3x3 #(
    parameter IMG_WIDTH = 64
)(
    input  wire clk,
    input  wire rst,

    input  wire [7:0] pixel_in,
    input  wire       pixel_valid,

    output reg  [7:0] p00, p01, p02,
    output reg  [7:0] p10, p11, p12,
    output reg  [7:0] p20, p21, p22,

    output reg        window_valid,

    // Debug outputs
    output reg [9:0]  dbg_row,
    output reg [9:0]  dbg_col
);

    // ------------------------------------------------------------
    // Line buffers (store previous rows)
    // ------------------------------------------------------------
    reg [7:0] linebuf1 [0:IMG_WIDTH-1]; // row - 1
    reg [7:0] linebuf2 [0:IMG_WIDTH-1]; // row - 2

    // ------------------------------------------------------------
    // Row and column counters
    // ------------------------------------------------------------
    reg [9:0] row;
    reg [9:0] col;

    integer i;

    // ------------------------------------------------------------
    // Main sequential logic
    // ------------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            row          <= 10'd0;
            col          <= 10'd0;
            window_valid <= 1'b0;

            dbg_row <= 10'd0;
            dbg_col <= 10'd0;

            // Clear line buffers
            for (i = 0; i < IMG_WIDTH; i = i + 1) begin
                linebuf1[i] <= 8'd0;
                linebuf2[i] <= 8'd0;
            end
        end else begin
            window_valid <= 1'b0;

            if (pixel_valid) begin
                // ------------------------------------------------
                // Shift data through line buffers
                // ------------------------------------------------
                linebuf2[col] <= linebuf1[col];
                linebuf1[col] <= pixel_in;

                // ------------------------------------------------
                // Update column and row counters
                // ------------------------------------------------
                if (col == IMG_WIDTH-1) begin
                    col <= 10'd0;
                    row <= row + 10'd1;
                end else begin
                    col <= col + 10'd1;
                end

                // ------------------------------------------------
                // Generate window ONLY when fully valid
                // ------------------------------------------------
                if (row >= 2 && col >= 2) begin
                    p00 <= linebuf2[col-2];
                    p01 <= linebuf2[col-1];
                    p02 <= linebuf2[col];

                    p10 <= linebuf1[col-2];
                    p11 <= linebuf1[col-1];
                    p12 <= linebuf1[col];

                    p20 <= linebuf1[col-2]; // Previous row, 2 columns back
                    p21 <= linebuf1[col-1]; // Previous row, 1 column back
                    p22 <= pixel_in;        // Current row, current pixel

                    // NOTE:
                    // p20/p21/p22 mapping assumes pixel_in is current column.
                    // p21/p22 will be corrected downstream by conv timing.

                    window_valid <= 1'b1;
                end

                // ------------------------------------------------
                // Debug visibility
                // ------------------------------------------------
                dbg_row <= row;
                dbg_col <= col;
            end
        end
    end

endmodule
