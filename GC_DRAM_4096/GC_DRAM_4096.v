`timescale 1ns/1ps

// Include the base 512 module
`include "../GC_DRAM_512/GC_DRAM_512.v"

module gc_edram_model_4096 #(
    parameter GLOBAL_ADDR_WIDTH = 12,       
    parameter LOCAL_ADDR_WIDTH  = 9,
    parameter DATA_WIDTH        = 64,      
    parameter BLOCKS            = 8,
    parameter TOTAL_LINES       = 4096
)(
    input  wire                           clk,
    input  wire                           rst_n,
    input  wire                           we,           
    input  wire                           re,           
    input  wire [GLOBAL_ADDR_WIDTH-1:0]   write_addr,   
    input  wire [GLOBAL_ADDR_WIDTH-1:0]   read_addr,    
    input  wire [DATA_WIDTH-1:0]          din,          
    output reg  [DATA_WIDTH-1:0]          dout          
);

    // --- Global DRT Array ---
    // Read the entire file once at the top level
    integer global_drt_values [0:TOTAL_LINES-1];

    initial begin
        $readmemh("../DRT_ARRAYS/drt_times_4096.mem", global_drt_values);
    end

    // --- Wires for structural connections ---
    wire [BLOCKS-1:0]     block_we;
    wire [BLOCKS-1:0]     block_re;
    wire [DATA_WIDTH-1:0] block_dout [0:BLOCKS-1];

    // --- Address Decoding ---
    wire [2:0] write_block_sel = write_addr[GLOBAL_ADDR_WIDTH-1 : LOCAL_ADDR_WIDTH];
    wire [2:0] read_block_sel  = read_addr[GLOBAL_ADDR_WIDTH-1  : LOCAL_ADDR_WIDTH];

    wire [LOCAL_ADDR_WIDTH-1:0] local_write_addr = write_addr[LOCAL_ADDR_WIDTH-1:0];
    wire [LOCAL_ADDR_WIDTH-1:0] local_read_addr  = read_addr[LOCAL_ADDR_WIDTH-1:0];

    // --- Generate 8 Blocks ---
    genvar i;
    generate
        for (i = 0; i < BLOCKS; i = i + 1) begin : DRAM_BANK
            
            // Enable signals logic
            assign block_we[i] = we & (write_block_sel == i);
            assign block_re[i] = re & (read_block_sel == i);

            // Instantiate the 512-line model
            gc_edram_model_512 u_block (
                .clk(clk),
                .rst_n(rst_n),
                .we(block_we[i]),
                .re(block_re[i]),
                .write_addr(local_write_addr),
                .read_addr(local_read_addr),
                .din(din),
                .dout(block_dout[i])
            );

            // --- The Hierarchical Data Injection ---
            integer j;
            initial begin
                #1; // Short delay to ensure global $readmemh completes first
                // Copy exactly 512 values from the global array to this specific instance
                for (j = 0; j < 512; j = j + 1) begin
                    u_block.drt_values[j] = global_drt_values[(i * 512) + j];
                end
            end

        end
    endgenerate

    // --- Read Output Multiplexer ---
    always @(*) begin
        if (re) begin
            dout = block_dout[read_block_sel];
        end else begin
            dout = {DATA_WIDTH{1'bz}};
        end
    end

endmodule