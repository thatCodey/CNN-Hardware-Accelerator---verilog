`timescale 1ns / 1ps

module tb_cnn_top;

    // ------------------------------------------------------------
    // Clock / Reset / Control
    // ------------------------------------------------------------
    reg clk;
    reg rst;
    reg start;

    // ------------------------------------------------------------
    // Outputs
    // ------------------------------------------------------------
    wire class_out;
    wire done;
    wire [2:0] debug_state;
    wire [3:0] active_stage;
    wire signed [15:0] final_score;

    // ------------------------------------------------------------
    // DUT (Device Under Test)
    // ------------------------------------------------------------
    cnn_top dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .class_out(class_out),
        .done(done),
        .debug_state(debug_state),
        .active_stage(active_stage),
        .final_score(final_score)
    );

    // ------------------------------------------------------------
    // Clock generation: 100 MHz (10ns period)
    // ------------------------------------------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    // ------------------------------------------------------------
    // Main stimulus
    // ------------------------------------------------------------
    integer i;
    initial begin
        // 1. Initialize signals
        rst   = 1; 
        start = 0; 

        // 2. Reset pulse
        #100;
        @(posedge clk);
        rst = 0; 
        
        // 3. Load image into BRAM (happens instantly in simulation)
        $display("=================================");
        $display("Image loading started...");
        
        for (i = 0; i < 4096; i = i + 1) begin
            dut.u_img.mem[i] = 8'd255; // All white pixels
        end
        
        $display("Image loading complete.");
        $display("=================================");

        // 4. Synchronized Start Signal (Crucial for FSM)
        // Wait 10 clock cycles to ensure everything is stable
        repeat(10) @(posedge clk); 
        
        start = 1;
        @(posedge clk); // Hold start for exactly one clock cycle
        start = 0;

        $display("CNN STARTED AT TIME: %t", $time);
        $display("=================================");

        // 5. WAIT FOR DONE (This will now run for ~45,000ns)
        // If the simulation still stops early, check conv_done and gap_done
        wait (done == 1'b1); 

        $display("=================================");
        $display("CNN FINISHED AT TIME: %t", $time);
        $display("Final score  = %d", final_score);
        $display("Class output = %d", class_out);
        $display("=================================");

        #100;
        $stop;
    end

    // ------------------------------------------------------------
    // HARD TIMEOUT - Prevents infinite loops if 'done' never rises
    // ------------------------------------------------------------
    initial begin
        #1000_000; // Increased to 1ms to ensure enough time for 4096 pixels
        $display("=================================");
        $display("TIMEOUT: 'done' signal never reached high.");
        $display("Current State = %0d", debug_state);
        $display("Active Stage  = %b", active_stage);
        $display("=================================");
        $stop;
    end

endmodule
