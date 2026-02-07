module maxpool2x2 (
    input  wire clk,
    input  wire rst,
    input  wire pool_en,

    input  wire signed [15:0] in_data,
    input  wire              valid_in,

    output reg  signed [15:0] out_data,
    output reg               valid_out
);

    reg signed [15:0] max_val;
    reg [1:0] sample_count;
    reg busy;

    always @(posedge clk) begin
        if (rst) begin
            max_val <= 0;
            sample_count <= 0;
            valid_out <= 0;
            busy <= 0;
        end else begin
            valid_out <= 0;

            if (pool_en && !busy) begin
                sample_count <= 0;
                busy <= 1;
            end

            if (busy && valid_in) begin
                // Track max over 4 samples
                if (sample_count == 0)
                    max_val <= in_data;
                else if (in_data > max_val)
                    max_val <= in_data;

                sample_count <= sample_count + 1;

                // Emit pooled output every 4 inputs
                if (sample_count == 2'd3) begin
                    out_data <= max_val;
                    valid_out <= 1'b1;
                    sample_count <= 0;
                end
            end
        end
    end
endmodule
