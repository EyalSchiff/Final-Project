module gc_edram_model #(
    parameter ADDR_WIDTH = 9,       
    parameter DATA_WIDTH = 64,      
    parameter NUM_LINES  = 512
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

    reg [DATA_WIDTH-1:0] mem [0:NUM_LINES-1];

 
    integer drt_values [0:NUM_LINES-1];


    integer decay_counters [0:NUM_LINES-1];

    initial begin
        $readmemh("drt_times.mem", drt_values);
    end

    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < NUM_LINES; i = i + 1) begin
                decay_counters[i] <= 0;
                mem[i] <= {DATA_WIDTH{1'b0}};
            end
        end else begin
            for (i = 0; i < NUM_LINES; i = i + 1) begin
                
                if (we && (write_addr == i)) begin
                    mem[i] <= din;
                    decay_counters[i] <= 0;
                end 
                
                else begin
                    if (decay_counters[i] < drt_values[i]) begin
                        decay_counters[i] <= decay_counters[i] + 1;
                    end else begin
                        mem[i] <= {DATA_WIDTH{1'bx}};
                    end
                end
            end
        end
    end

    always @(*) begin
        if (re) begin
            dout = mem[read_addr];
        end else begin
            dout = {DATA_WIDTH{1'bz}};
        end
    end

endmodule