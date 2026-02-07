// ============================================================================
// File: threshold.v
// Description:
//   Final classification threshold stage.
//
// Behavior:
//   - Compares signed fixed-point input against a parameterized threshold
//   - Produces binary class_out
//   - Output is REGISTERED (no combinational glitches)
//   - valid_out asserted for exactly one cycle
//   - done asserted for exactly one cycle (FSM handshake)
//
// Notes:
//   - Arithmetic format is NOT changed
//   - Designed to be the final stage before DONE state
// ============================================================================

module threshold #(
    parameter signed [15:0] THRESHOLD = 16'sd0   // default threshold
)(
    input  wire clk,
    input  wire rst,

    // Control
    input  wire valid_in,
    output reg  valid_out,
    output reg  done,          // to FSM

    // Data
    input  wire signed [15:0] in_data,
    output reg                class_out
);

    // ------------------------------------------------------------
    // Sequential logic
    // ------------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            class_out <= 1'b0;
            valid_out <= 1'b0;
            done      <= 1'b0;
        end else begin
            // Default deassertions
            valid_out <= 1'b0;
            done      <= 1'b0;

            // ----------------------------------------------------
            // Threshold comparison (registered)
            // ----------------------------------------------------
            if (valid_in) begin
                if (in_data > THRESHOLD)
                    class_out <= 1'b1;
                else
                    class_out <= 1'b0;

                valid_out <= 1'b1;
                done      <= 1'b1;
            end
        end
    end

endmodule
