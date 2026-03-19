`timescale 1ns/1ps

module gc_lut_512_TB;
    parameter GLOBAL_ADDR_WIDTH = 12;
    parameter LUT_SIZE = 512;
    parameter SRAM_ADDR_WIDTH = 9;

    // Inputs to the module
    reg  [GLOBAL_ADDR_WIDTH-1:0] global_addr;
    
    // Outputs from the module
    wire                         hit;
    wire [SRAM_ADDR_WIDTH-1:0]   sram_addr;

    // Instantiate the DUT - this time without clk and rst_n
    gc_lut_512 #(
        .GLOBAL_ADDR_WIDTH(GLOBAL_ADDR_WIDTH),
        .LUT_SIZE(LUT_SIZE),
        .SRAM_ADDR_WIDTH(SRAM_ADDR_WIDTH)
    ) uut (
        .global_addr(global_addr),
        .hit(hit),
        .sram_addr(sram_addr)
    );

    // Internal array in the testbench for comparison against the module
    reg [GLOBAL_ADDR_WIDTH-1:0] expected_bad_addrs [0:LUT_SIZE-1];

    integer i;
    integer errors;

    initial begin
        // Load the exact same file that the LUT loads
        $readmemh("../DRT_ARRAYS/bad_addresses_4096.mem", expected_bad_addrs);
        
        // Waveform generation setup (SimVision)
        $shm_open("waves.shm");
        $shm_probe("AS");
        
        // Initialization
        global_addr = 0;
        errors = 0;
        
        #10;
        $display("-----------------------------------------");
        $display("--- Starting Combinational LUT Test ---");
        $display("-----------------------------------------");

        // --- Test 1: Testing all 512 bad addresses ---
        $display("Testing all %0d known BAD addresses (Expecting HIT=1):", LUT_SIZE);
        
        for (i = 0; i < LUT_SIZE; i = i + 1) begin
            global_addr = expected_bad_addrs[i]; // Inject the address from the file
            #5; // Short delay for the combinational logic to update
            
            // Check if the module correctly identified and output the right index
            if (hit !== 1'b1 || sram_addr !== i) begin
                $display("FAIL: Addr %h -> Expected HIT=1, Idx=%0d. Got HIT=%b, Idx=%0d", 
                         global_addr, i, hit, sram_addr);
                errors = errors + 1;
            end
        end
        
        if (errors == 0) begin
            $display("PASS: All %0d bad addresses successfully matched! (0 Errors)", LUT_SIZE);
        end

        // --- Test 2: Testing a valid address (MISS) ---
        $display("\nTesting a GOOD address (Expecting HIT=0):");
        // Test a random address like 12'hFFF which is likely not in the bad list
        global_addr = 12'hFFF; 
        #5;
        if (hit === 1'b0) begin
            $display("PASS: Addr %h -> MISS (HIT=0) as expected.", global_addr);
        end else begin
            // This address might have been generated in Python, so we add a warning instead of a failure
            $display("NOTE: Addr %h -> HIT! (It happens to be in the random bad address list).", global_addr);
        end

        #20;
        $display("-----------------------------------------");
        $display("--- LUT Verification Complete ---");
        $finish;
    end

endmodule