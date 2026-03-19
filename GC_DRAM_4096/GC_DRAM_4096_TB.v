`timescale 1ns/1ps

module gc_edram_model_4096_TB;
    parameter ADDR_WIDTH = 12;
    parameter DATA_WIDTH = 64; 
    parameter NUM_LINES  = 4096;
 
    reg                   clk;
    reg                   rst_n;
    reg                   we;        
    reg                   re;           
    reg [ADDR_WIDTH-1:0]  write_addr; 
    reg [ADDR_WIDTH-1:0]  read_addr;   
    reg [DATA_WIDTH-1:0]  din;    
    wire [DATA_WIDTH-1:0] dout;

    // Instantiate the DRAM module
    gc_edram_model_4096 dram (
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
        $display("Time %0t: Reset de-asserted. DRT for Addr 0 is %0d cycles.", $time, dram.global_drt_values[0]);
        $display("Time %0t: Reset de-asserted. DRT for Addr 4095 is %0d cycles.", $time, dram.global_drt_values[4095]);


        //  Write Operation to Address 0 ---
        @(posedge clk);
        we = 1;
        write_addr = 12'd0;
        din = 64'hFFFFFFFFFFFFFFFF; 

        @(posedge clk);
        we = 0;
        $display("Time %0t: Data written to Address 0.", $time);


        //  Write Operation to Address 4095 ---
        @(posedge clk);
        we = 1;
        write_addr = 12'd4095;
        din = 64'hAAAAAAAAAAAAAAAA; 

        @(posedge clk);
        we = 0;
        $display("Time %0t: Data written to Address 4095.", $time);

        re = 1;

        // read every 2 cycles first and last mem
        repeat(200)begin
        @(posedge clk);
        read_addr = 12'd0;
        #1; 
        $display("Time %0t: Immediate Read. Data = %h", $time, dout);

        @(posedge clk);
        read_addr = 12'd4095;
        #1; 
        $display("Time %0t: Immediate Read. Data = %h", $time, dout);
        end



        #20
        // --- 5. Final Pass/Fail Check ---
        if (dout === 64'bx) 
            $display("Time %0t: SUCCESS! Data decayed to X .", $time);
        else
            $display("Time %0t: FAIL! Data is still %h. Is DRT value > 200 cycles?", $time, dout);
        
        $display("Simulation finished.");
        $finish;
    end

endmodule