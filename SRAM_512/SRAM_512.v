`timescale 1ns/1ps

module sram_512 #(
    parameter ADDR_WIDTH = 9,       // 9 bits to address 512 lines
    parameter DATA_WIDTH = 64,      // 64 bits per line
    parameter NUM_LINES  = 512      // Total number of SRAM cells
)(
    input  wire                   clk,
    input  wire                   we,           // Write Enable
    input  wire                   re,           // Read Enable
    input  wire [ADDR_WIDTH-1:0]  write_addr,   // Address for writing
    input  wire [ADDR_WIDTH-1:0]  read_addr,    // Address for reading
    input  wire [DATA_WIDTH-1:0]  din,          // Data input
    output reg  [DATA_WIDTH-1:0]  dout          // Data output
);

    // --- The SRAM Memory Array ---
    reg [DATA_WIDTH-1:0] mem [0:NUM_LINES-1];

    // --- Synchronous Write Logic ---
    // In standard SRAM, data is written on the clock edge
    always @(posedge clk) begin
        if (we) begin
            mem[write_addr] <= din;
        end
    end

    // --- Combinational Read Logic ---
    // Matched to your eDRAM behavior for seamless integration
    always @(*) begin
        if (re) begin
            dout = mem[read_addr];
        end else begin
            dout = {DATA_WIDTH{1'bz}}; // Drive High-Z when not reading
        end
    end

endmodule