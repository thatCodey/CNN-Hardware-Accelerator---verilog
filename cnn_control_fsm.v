module cnn_control_fsm (
    input  wire clk,
    input  wire rst,
    input  wire start,

    // Stage completion inputs
    input  wire conv_done,   // not used
    input  wire gap_done,
    input  wire fc_done,

    // Stage enables
    output reg  conv_en,
    output reg  relu_en,
    output reg  pool_en,   // unused
    output reg  gap_en,
    output reg  fc_en,

    // Global done
    output reg  done,

    // Debug
    output reg [2:0] debug_state
);

    // FSM states
    localparam [2:0]
        IDLE = 3'd0,
        CONV = 3'd1,
        FC   = 3'd2,
        DONE = 3'd3;

    reg [2:0] state, next_state;

    // ------------------------------------------------------------
    // State register
    // ------------------------------------------------------------
    always @(posedge clk) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // ------------------------------------------------------------
    // Next-state and output logic
    // ------------------------------------------------------------
    always @(*) begin
        // defaults
        conv_en = 1'b0;
        relu_en = 1'b0;
        pool_en = 1'b0;
        gap_en  = 1'b0;
        fc_en   = 1'b0;
        done    = 1'b0;

        next_state = state;

        case (state)

            IDLE: begin
                if (start)
                    next_state = CONV;
            end

            // Streaming stage
            CONV: begin
                conv_en = 1'b1;
                relu_en = 1'b1;
                gap_en  = 1'b1;

                if (gap_done)
                    next_state = FC;
            end

            // Fully connected stage
            FC: begin
                fc_en = 1'b1;

                if (fc_done)
                    next_state = DONE;
            end

            DONE: begin
                done = 1'b1;
            end

            default: begin
                next_state = IDLE;
            end

        endcase
    end

    // ------------------------------------------------------------
    // Debug
    // ------------------------------------------------------------
    always @(*) begin
        debug_state = state;
    end

endmodule
