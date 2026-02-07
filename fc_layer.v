// ============================================================================
// File: fc_layer.v
// Description:
//   TEMPORARY FC bypass for FPGA demo
//   Uses single input sample and completes immediately
// ============================================================================

module fc_layer (
    input  wire clk,
    input  wire rst,
    input  wire fc_en,

    input  wire signed [15:0] in_data,
    input  wire              valid_in,

    input  wire signed [7:0]  weight,
    input  wire signed [15:0] bias,

    output reg  signed [15:0] out,
    output reg               valid_out,
    output reg               done
);

    always @(posedge clk) begin
        if (rst) begin
            out <= 0;
            valid_out <= 0;
            done <= 0;
        end else begin
            valid_out <= 0;
            done <= 0;

            if (fc_en && valid_in) begin
                out <= in_data * weight + bias;
                valid_out <= 1'b1;
                done <= 1'b1;
            end
        end
    end

endmodule
