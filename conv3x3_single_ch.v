// ============================================================================
// File: conv3x3_single_ch.v
// Description:
//   Single-channel 3x3 convolution engine with strict sequencing.
//   - Uses exactly 9 MAC cycles per output pixel
//   - Bias is added ONLY after final MAC
//   - valid_out is asserted for exactly one cycle
//   - done is asserted for exactly one cycle
//
// Control:
//   - conv_en must remain high during computation
//   - Module is idle when conv_en = 0
//
// FSM Contract:
//   - FSM asserts conv_en
//   - Module asserts done when one convolution result is complete
//
// ============================================================================

module conv3x3_single_ch (
    input  wire clk,
    input  wire rst,

    // Control
    input  wire conv_en,      // From FSM
    output reg  done,         // To FSM

    // Data valid
    input  wire valid_in,
    output reg  valid_out,

    // Pixel window (unsigned input pixels)
    input  wire [7:0] p00, p01, p02,
    input  wire [7:0] p10, p11, p12,
    input  wire [7:0] p20, p21, p22,

    // Weight input (one weight per cycle, from ROM)
    input  wire signed [7:0] weight_in,

    // Bias
    input  wire signed [15:0] bias,

    // Output
    output reg  signed [15:0] out
);

    // ------------------------------------------------------------
    // Internal signals
    // ------------------------------------------------------------
    reg signed [23:0] acc;          // Accumulator
    reg [3:0]         mac_step;     // 0 to 8
    reg               busy;

    // Selected pixel for current MAC step
    reg [7:0] pixel_sel;

    // ------------------------------------------------------------
    // Pixel selection logic (MAC step → pixel mapping)
    // ------------------------------------------------------------
    always @(*) begin
        case (mac_step)
            4'd0: pixel_sel = p00;
            4'd1: pixel_sel = p01;
            4'd2: pixel_sel = p02;
            4'd3: pixel_sel = p10;
            4'd4: pixel_sel = p11;
            4'd5: pixel_sel = p12;
            4'd6: pixel_sel = p20;
            4'd7: pixel_sel = p21;
            4'd8: pixel_sel = p22;
            default: pixel_sel = 8'd0;
        endcase
    end

    // ------------------------------------------------------------
    // Main sequential logic
    // ------------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            acc       <= 24'sd0;
            mac_step  <= 4'd0;
            busy      <= 1'b0;
            out       <= 16'sd0;
            valid_out <= 1'b0;
            done      <= 1'b0;
        end else begin
            // Default deassertions
            valid_out <= 1'b0;
            done      <= 1'b0;

            // ----------------------------------------------------
            // Start of convolution
            // ----------------------------------------------------
            if (conv_en && !busy && valid_in) begin
    busy     <= 1'b1;
    acc      <= 24'sd0;
    mac_step <= 4'd0;
end

            // ----------------------------------------------------
            // MAC operation (exactly 9 cycles)
            // ----------------------------------------------------
            if (busy) begin
                acc <= acc + ($signed({1'b0, pixel_sel}) * weight_in);
                // Debug: MAC trace (simulation only)
                `ifndef SYNTHESIS
                $display("[CONV] step=%0d pixel=%0d weight=%0d acc=%0d",
                          mac_step, pixel_sel, weight_in, acc);
                `endif

                if (mac_step == 4'd8) begin
    out       <= acc[15:0] + bias;
    valid_out <= 1'b1;
    done      <= 1'b0;   // do not signal done per pixel
    busy      <= 1'b0;
    mac_step  <= 4'd0;
end
 else begin
                    mac_step <= mac_step + 4'd1;
                end
            end
        end
    end

endmodule
