`timescale 1ns/1ps

module sram_512_TB;
    parameter ADDR_WIDTH = 9;
    parameter DATA_WIDTH = 64;
    parameter NUM_LINES  = 512;

    // SRAM Inputs
    reg                   clk;
    reg                   we;
    reg                   re;
    reg  [ADDR_WIDTH-1:0] write_addr;
    reg  [ADDR_WIDTH-1:0] read_addr;
    reg  [DATA_WIDTH-1:0] din;
    
    // SRAM Output
    wire [DATA_WIDTH-1:0] dout;

    integer errors;

    // Instantiate the SRAM (Device Under Test)
    sram_512 #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .NUM_LINES(NUM_LINES)
    ) SRAM_512 (
        .clk(clk),
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
        // SimVision Waveforms setup
        $shm_open("waves.shm");
        $shm_probe("AS");

        // System Initialization
        we = 0;
        re = 0;
        write_addr = 0;
        read_addr  = 0;
        din = 0;
        errors = 0;

        $display("-----------------------------------------");
        $display("--- Starting SRAM Verification ---");
        $display("-----------------------------------------");

        #25; // Short delay after initialization

        // --- Test 1: Write and Read from Address 10 ---
        $display("Test 1: Write and Read from Address 10");
        @(posedge clk);
        we = 1;
        write_addr = 9'd10;
        din = 64'hAAAA_BBBB_CCCC_DDDD;
        
        @(posedge clk);
        we = 0; // Stop writing

        #1; // Small delay for logic update
        re = 1;
        read_addr = 9'd10;
        #5; // Wait for combinational read
        if (dout === 64'hAAAA_BBBB_CCCC_DDDD) begin
            $display("PASS: Read Addr 10 -> %h", dout);
        end else begin
            $display("FAIL: Read Addr 10 -> Expected AAAABBBBCCCCDDDD, Got %h", dout);
            errors = errors + 1;
        end

        // --- Test 2: Write and Read from Last Address (511) ---
        $display("\nTest 2: Write and Read from Last Address (511)");
        @(posedge clk);
        we = 1;
        write_addr = 9'd511;
        din = 64'h1111_2222_3333_4444;
        
        @(posedge clk);
        we = 0; // Stop writing

        #1; // Small delay for logic update
        re = 1;
        read_addr = 9'd511;
        #5; // Wait for combinational read
        if (dout === 64'h1111_2222_3333_4444) begin
            $display("PASS: Read Addr 511 -> %h", dout);
        end else begin
            $display("FAIL: Read Addr 511 -> Expected 1111222233334444, Got %h", dout);
            errors = errors + 1;
        end

        // --- Test 3: Check High-Z state ---
        $display("\nTest 3: Check High-Z when Read Enable is OFF");
        re = 0; // Disable reading
        #5;
        if (dout === 64'hz) begin
            $display("PASS: Output successfully transitioned to High-Z (z).");
        end else begin
            $display("FAIL: Expected High-Z, Got %h", dout);
            errors = errors + 1;
        end

        // --- Summary ---
        $display("-----------------------------------------");
        if (errors == 0)
            $display("SRAM Verification SUCCESS! (0 Errors)");
        else
            $display("SRAM Verification FAILED with %0d errors.", errors);
        $display("-----------------------------------------");
        
        $finish;
    end

endmodule