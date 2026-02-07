// ============================================================================
// File: global_avg_pool.v
// Description:
//   TEMPORARY GAP bypass for FPGA demo
//   Passes first valid sample through and completes immediately
// ============================================================================

module global_avg_pool (
    input  wire clk,
    input  wire rst,
    input  wire gap_en,

    input  wire signed [15:0] in_data,
    input  wire              valid_in,

    output reg  signed [15:0] out_data,
    output reg               valid_out,
    output reg               done,

    // Debug (kept for compatibility)
    output reg signed [31:0] dbg_accumulator,
    output reg [15:0]        dbg_sample_count
);

    reg busy;

    always @(posedge clk) begin
        if (rst) begin
            out_data <= 0;
            valid_out <= 0;
            done <= 0;
            busy <= 0;
            dbg_accumulator <= 0;
            dbg_sample_count <= 0;
        end else begin
            // Pulse signals should be 0 by default
            valid_out <= 0;
            done <= 0;

            if (gap_en) begin
                if (valid_in) begin
                    // 1. Accumulate the data
                    dbg_accumulator <= dbg_accumulator + in_data;
                    // 2. Increment the count
                    dbg_sample_count <= dbg_sample_count + 1;
                end
                
                // 3. Check if we have processed the whole 64x64 image
                // 4096 in decimal is 16'h1000
                if (dbg_sample_count == 16'h1000) begin
                    // Average = Total Sum / 4096 (which is a right shift by 12)
                    out_data <= dbg_accumulator[27:12]; 
                    valid_out <= 1'b1;
                    done <= 1'b1;
                end
            end 
        end
    end

endmodule
