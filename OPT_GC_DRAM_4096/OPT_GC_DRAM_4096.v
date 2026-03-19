`timescale 1ns/1ps
`include "../GC_DRAM_4096/GC_DRAM_4096.v"
`include "../LUT_512/LUT_512.v"
`include "../SRAM_512/SRAM_512.v"

module OPT_GC_DRAM_4096 #(
    parameter ADDR_WIDTH = 12,       
    parameter DATA_WIDTH = 64,      
    parameter NUM_LINES  = 4096
)(
    input  wire                   clk,
    input  wire                   rst_n,
    input  wire                   we,           
    input  wire                   re,           
    input  wire [ADDR_WIDTH-1:0]  write_addr,   
    input  wire [ADDR_WIDTH-1:0]  read_addr,    
    input  wire [DATA_WIDTH-1:0]  din,          
    output reg  [DATA_WIDTH-1:0]  dout          
);


wire write_hit;
wire [8:0]write_SRAM_addr;
wire sram_write_en;

wire read_hit;
wire [8:0]read_SRAM_addr;
wire sram_read_en;

assign  sram_read_en = read_hit & re ; 
assign  sram_write_en = write_hit & we ;

wire [DATA_WIDTH-1:0]dout_SRAM;
wire [DATA_WIDTH-1:0]dout_GC;

    // Instantiate the DRAM module
    gc_edram_model_4096 dram (
        .clk(clk),
        .rst_n(rst_n),
        .we(we),
        .re(re),
        .write_addr(write_addr),
        .read_addr(read_addr),
        .din(din),
        .dout(dout_GC)
    );

    // Instantiate the write_LUT module
    gc_lut_512  write_LUT (
        .global_addr(write_addr),
        .hit(write_hit),
        .sram_addr(write_SRAM_addr)
    );


    // Instantiate the read_LUT module
    gc_lut_512  read_LUT (
        .global_addr(read_addr),
        .hit(read_hit),
        .sram_addr(read_SRAM_addr)
    );


    // Instantiate the SRAM 
    sram_512 SRAM_512 (
        .clk(clk),
        .we(sram_write_en),
        .re(sram_read_en),
        .write_addr(write_SRAM_addr),
        .read_addr(read_SRAM_addr),
        .din(din),
        .dout(dout_SRAM)
    );

    always @(*) begin
        if(read_hit)begin
            dout = dout_SRAM ;
        end
        else begin
            dout = dout_GC ; 
        end
        end


endmodule
