module cnn_top (
    input  wire clk,
    input  wire rst,
    input  wire start,

    // NEW PORTS: These connect to your AXI BRAM Controller (Port B)
    output reg  [11:0] img_rd_addr, 
    input  wire [7:0]  img_pixel,   

    output wire class_out,
    output wire done,

    // Debug
    output wire [2:0] debug_state,
    output wire [3:0] active_stage,
    output wire signed [15:0] final_score
);

    // ============================================================
    // FSM signals
    // ============================================================
    wire conv_en, relu_en, pool_en, gap_en, fc_en;
    wire conv_done, gap_done, fc_done;

    cnn_control_fsm u_fsm (
        .clk(clk),
        .rst(rst),
        .start(start),
        .conv_done(conv_done),
        .gap_done(gap_done),
        .fc_done(fc_done),
        .conv_en(conv_en),
        .relu_en(relu_en),
        .pool_en(pool_en),
        .gap_en(gap_en),
        .fc_en(fc_en),
        .done(done),
        .debug_state(debug_state)
    );

    assign active_stage =
        conv_en ? 4'b0001 :
        relu_en ? 4'b0010 :
        pool_en ? 4'b0100 :
        gap_en  ? 4'b1000 :
                  4'b0000;

    wire lb_valid;
    wire [7:0] p00,p01,p02,p10,p11,p12,p20,p21,p22;

    // ============================================================
    // ADDRESS LOGIC (Feeds the img_rd_addr output pin)
    // ============================================================
    always @(posedge clk) begin
        if (rst)
            img_rd_addr <= 12'd0;
        else if (conv_en && lb_valid)
            img_rd_addr <= img_rd_addr + 12'd1;
        else if (!conv_en)
            img_rd_addr <= 12'd0;
    end

    // ============================================================
    // DATA PATH: Pixel data comes in directly from img_pixel pin
    // ============================================================
    linebuffer_3x3 u_lb (
        .clk(clk),
        .rst(rst),
        .pixel_in(img_pixel), // Data from external BRAM
        .pixel_valid(conv_en),
        .p00(p00), .p01(p01), .p02(p02),
        .p10(p10), .p11(p11), .p12(p12),
        .p20(p20), .p21(p21), .p22(p22),
        .window_valid(lb_valid),
        .dbg_row(),
        .dbg_col()
    );

    // ... (The rest of your Convolution, ReLU, GAP, and FC code stays exactly the same) ...

endmodule
