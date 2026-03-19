`timescale 1ns/1ps

module OPT_GC_DRAM_4096_TB;
    parameter ADDR_WIDTH = 12;
    parameter DATA_WIDTH = 64;
    parameter NUM_LINES  = 4096;
    parameter LUT_SIZE   = 512;

    // --- Inputs to DUT ---
    reg                   clk;
    reg                   rst_n;
    reg                   we;
    reg                   re;
    reg  [ADDR_WIDTH-1:0] write_addr;
    reg  [ADDR_WIDTH-1:0] read_addr;
    reg  [DATA_WIDTH-1:0] din;
    
    // --- Output from DUT ---
    wire [DATA_WIDTH-1:0] dout;

    // Array to dynamically load the bad addresses
    reg [ADDR_WIDTH-1:0] bad_addresses [0:LUT_SIZE-1];
    reg [ADDR_WIDTH-1:0] target_bad_addr;

    // Instantiate the Top-Level System (Device Under Test)
    OPT_GC_DRAM_4096 #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .NUM_LINES(NUM_LINES)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .we(we),
        .re(re),
        .write_addr(write_addr),
        .read_addr(read_addr),
        .din(din),
        .dout(dout)
    );

    // Clock generation (10ns period)
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // Setup waveforms
        $shm_open("waves.shm");
        $shm_probe("AS");

        // Load the bad addresses file so the TB knows where to write
        $readmemh("../DRT_ARRAYS/bad_addresses_4096.mem", bad_addresses);
        
        // Initialization
        we = 0; re = 0;
        write_addr = 0; read_addr = 0; din = 0;
        rst_n = 0;
        
        #25 rst_n = 1;
        
        // Fetch the SECOND bad address from the array (Index 1)
        target_bad_addr = bad_addresses[1]; 
        
        $display("-----------------------------------------------------");
        $display("--- Starting Smart Memory Architecture Test ---");
        $display("Targeting SECOND Bad Address: %h", target_bad_addr);
        $display("-----------------------------------------------------");

        // --- Step 1: Write to the bad address (Using negedge for stability) ---
        @(negedge clk); // Change signals half a cycle BEFORE the clock edge
        we = 1;
        write_addr = target_bad_addr;
        din = 64'hAAAA_BBBB_CCCC_DDDD;
        
        @(negedge clk); // Hold for exactly one clock cycle, then release
        we = 0; 
        $display("Time %0t: Data 'AAAA_BBBB_CCCC_DDDD' written to Address %h.", $time, target_bad_addr);

        @(negedge clk); // Again, prepare the read signals safely
        re = 1;
        read_addr = target_bad_addr;
        #5; // Wait for the combinational read path (LUT -> SRAM -> MUX) to propagate

        // --- Step 2: Wait for GC-eDRAM decay ---
        // We wait 2000ns to ensure the DRT of this bad cell has expired
        $display("Time %0t:time of start naturally decay...", $time);
        #2000;
        $display("Time %0t: Waiting 2000ns for GC-eDRAM cell to naturally decay...", $time);
        
        $display("\nTime %0t: Read operation triggered.", $time);
        
        // --- PROOF 1: Check internal GC-eDRAM output ---
        if (uut.dout_GC === 64'bx) begin
            $display("-> [INTERNAL CHECK] SUCCESS: The internal GC-eDRAM data has correctly decayed to 'X'.");
        end else begin
            $display("-> [INTERNAL CHECK] FAIL: The GC-eDRAM data is still %h (Did we wait long enough?).", uut.dout_GC);
        end

        // --- PROOF 2: Check final output from Top-Level ---
        if (dout === 64'hAAAA_BBBB_CCCC_DDDD) begin
            $display("-> [FINAL OUTPUT CHECK] PASS: The Top-Level 'dout' holds the correct data from SRAM: %h", dout);
        end else begin
            $display("-> [FINAL OUTPUT CHECK] FAIL: Expected AAAABBBBCCCCDDDD, Got: %h", dout);
        end

        $display("-----------------------------------------------------");
        $finish;
    end
endmodule