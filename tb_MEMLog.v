//! @title MEMLog
//! @file tb_MEMLOG.v

`timescale 1ns/1ps

module tb_MEMLOG #(
    parameter BRAM_ADDR_WIDTH = 15,
    parameter BRAM_DATA_WIDTH = 16
  );

  //! Local parameters
  localparam IDLE = 2'd0; 
  localparam RUN  = 2'd1;
  localparam FULL = 2'd2;
  localparam READ = 2'd3;


  //! DUT inputs
  reg [BRAM_DATA_WIDTH-1:0] i_filter_data;
  reg i_run_log;
  reg i_read_log;
  reg [BRAM_ADDR_WIDTH-1:0] i_addr_log_to_mem;
  reg tb_rst;
  reg tb_clk;

  //! DUT outputs
  wire o_mem_full;
  wire [2*BRAM_DATA_WIDTH-1:0] o_data_log_from_mem;

  //! Internal signals

  //! Signals assign


  //! Instance of FIR

  // Clock
  always #5 tb_clk = ~tb_clk;

  MEMLog
#(
    .BRAM_ADDR_WIDTH(BRAM_ADDR_WIDTH),
    .BRAM_DATA_WIDTH(BRAM_DATA_WIDTH)
)
u_MEMLog
(
    .clk(tb_clk),
    .i_rst(tb_rst),
    .i_filter_data(i_filter_data),
    .i_run_log(i_run_log),
    .i_read_log(i_read_log),
    .i_addr_log_to_mem(i_addr_log_to_mem),
    .o_mem_full(o_mem_full),
    .o_data_log_from_mem(o_data_log_from_mem)
);

  integer i;
  reg [2*BRAM_DATA_WIDTH-1:0] mem_aux [(1<<(BRAM_ADDR_WIDTH))-1:0];
  // Stimulus
  initial begin
    tb_clk = 0;
    tb_rst = 1;
    #10;
    tb_rst = 0;
    #10;
    i_filter_data = 0;
    i_run_log = 0;
    i_read_log = 0;
    i_addr_log_to_mem = 0;

    for (i = 0; i<(2**BRAM_ADDR_WIDTH); i=i+1) begin
        mem_aux [i] = $urandom;
    end

    $display("");
    $display("Simulation Started");

    #10000;
    i_run_log = 1;
    for (i = 0; i<(2**BRAM_ADDR_WIDTH); i=i+1) begin
        #10;
        if (i==0) begin
            i_run_log = 0;
        end
        
        i_filter_data = mem_aux[i][BRAM_DATA_WIDTH-1:0];
        
        #10;
        
        i_filter_data = mem_aux[i][2*BRAM_DATA_WIDTH-1:BRAM_DATA_WIDTH];
    end

    #10000;
    i_read_log = 1;
    #10;
    for (i = 0; i<(2**BRAM_ADDR_WIDTH); i=i+1) begin
        i_addr_log_to_mem = i;
        #10;
        if (i==0) begin
            i_read_log = 0;
        end
        if(o_data_log_from_mem == mem_aux [i])
        begin
            $display("Ta todo bien loco, no pasa nada. i=%0d", i);
        end
        else
        begin
            $display("Todo mal. addr=%0d. dato esperado = %x. dato leido = %x", i, mem_aux [i], o_data_log_from_mem);
        end
    end

   
    $display("Simulation Finished");
    $display("");
    $finish;
  end

endmodule
