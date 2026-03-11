`timescale 1ns/1ps

module gc_edram_model_TB;
    parameter ADDR_WIDTH = 9;
    parameter DATA_WIDTH = 64; 
    parameter NUM_LINES  = 512;
 
    reg                   clk;
    reg                   rst_n;
    reg                   we;        
    reg                   re;           
    reg [ADDR_WIDTH-1:0]  write_addr; 
    reg [ADDR_WIDTH-1:0]  read_addr;   
    reg [DATA_WIDTH-1:0]  din;    
    wire [DATA_WIDTH-1:0] dout;

    // Instantiate the DRAM module
    gc_edram_model dram (
        .clk(clk),
        .rst_n(rst_n),
        .we(we),
        .re(re),
        .write_addr(write_addr),
        .read_addr(read_addr),
        .din(din),
        .dout(dout)
    );

    // Waveform setup for SimVision
    initial begin
        $shm_open("waves.shm");
        $shm_probe("AS");
    end

    // Clock generation (10ns period)
    initial clk = 0;
    always #5 clk = ~clk;

    // Main Test Sequence
    initial begin
        // --- 1. System Reset ---
        rst_n = 0;
        we = 0; re = 0;
        write_addr = 0; read_addr = 0; din = 0;
        
        #25 rst_n = 1; 
        $display("Time %0t: Reset de-asserted. DRT for Addr 0 is %0d cycles.", $time, dram.drt_values[0]);

        // --- 2. Write Operation to Address 0 ---
        @(posedge clk);
        we = 1;
        write_addr = 9'd0;
        din = 64'hFFFFFFFFFFFFFFFF; 
        
        @(posedge clk);
        we = 0;
        $display("Time %0t: Data written to Address 0.", $time);

        // --- 3. Immediate Read Verification ---
        @(posedge clk);
        re = 1;
        read_addr = 9'd0;
        #1; 
        $display("Time %0t: Immediate Read. Data = %h", $time, dout);

        // --- 4. Periodic Sampling (Total 2000ns) ---
        
        $display("Time %0t: Starting periodic sampling every 100ns...", $time);
        
        // We keep 're' and 'read_addr' constant to observe the data changing to X
        re = 1;
        read_addr = 9'd0;

        #2000
        // --- 5. Final Pass/Fail Check ---
        if (dout === 64'bx) 
            $display("Time %0t: SUCCESS! Data decayed to X within 2000ns.", $time);
        else
            $display("Time %0t: FAIL! Data is still %h. Is DRT value > 200 cycles?", $time, dout);
        
        $display("Simulation finished.");
        $finish;
    end

endmodule