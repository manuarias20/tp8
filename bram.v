module bram
#(
    parameter BRAM_ADDR_WIDTH = 15;
    parameter BRAM_DATA_WIDTH = 16;
) 
(
    input                            clk, 
    input      [BRAM_ADDR_WIDTH-1:0] addr, 
    input                            chipselect_n,
    input                            write_n, 
    input                            read_n,
    input      [BRAM_DATA_WIDTH-1:0] bram_data_in,
    output reg [BRAM_DATA_WIDTH-1:0] bram_data_out
);

    reg [BRAM_DATA_WIDTH-1:0] mem [(1<<BRAM_ADDR_WIDTH)-1:0];

    always @(posedge clk)
        if (chipselect_n == 1'b0) begin
            begin
                if (write_n == 1'b0) mem[(addr)] <= bram_data_in;
                if (read_n == 1'b0) bram_data_out <= mem[addr];
            end
        end
    endmodule