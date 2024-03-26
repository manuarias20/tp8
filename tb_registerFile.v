//! @title registerFile
//! @file tb_registerFile.v

`timescale 1ns/1ps

module tb_registerFile #(
    parameter NB_ADDR_MEM = 15
);

  //  COMANDOS DEL UP
  localparam RESET    = 4'd0;     // Resetear el sistema
  localparam EN_TX    = 4'd1;     // Habilitar el Tx
  localparam EN_RX    = 4'd2;     // Habilitar el Rx
  localparam PH_SEL   = 4'd3;     // Selección de fase del filtro
  localparam RUN_MEM  = 4'd4;     // Comenzar el logueo de datos en memoria
  localparam READ_MEM = 4'd5;     // Habilitar la lectura de memoria
  localparam ADDR_MEM = 4'd6;     // Leer memoria en la direccion indicada
  
  //! DUT inputs
  reg                    tb_rst;
  reg                    tb_clk;
  reg             [31:0] i_gpo,
  reg             [31:0] i_data_log_from_mem,
  reg                    i_mem_full,
  reg             [63:0] i_ber_samp_I,
  reg             [63:0] i_ber_samp_Q,
  reg             [63:0] i_ber_error_I,
  reg             [63:0] i_ber_error_Q,    

  
  //! DUT outputs
  reg            [31:0] o_gpi,
  reg                   o_rst,
  reg                   o_enbTx,
  reg                   o_enbRx,
  reg             [1:0] o_phase_sel,
  reg                   o_run_log,
  reg                   o_read_log,
  reg [NB_ADDR_MEM-1:0] o_addr_log_to_mem,
  
  // Clock
  always #5 tb_clk = ~tb_clk;

  registerFile
#(
    .NB_ADDR_MEM(NB_ADDR_MEM)
)
u_registerFile
(
    .clk(tb_clk),
    .i_rst(tb_rst),
    .i_gpo(i_gpo),
    .i_data_log_from_mem(i_data_log_from_mem),
    .i_mem_full(i_mem_full),
    .i_ber_samp_I(i_ber_samp_I),
    .i_ber_samp_Q(i_ber_samp_Q),
    .i_ber_error_I(i_ber_error_I),
    .i_ber_error_Q(i_ber_error_Q),    
    .o_gpi(o_gpi),
    .o_rst(o_rst),
    .o_enbTx(o_enbTx),
    .o_enbRx(o_enbRx),
    .o_phase_sel(o_phase_sel),
    .o_run_log(o_run_log),
    .o_read_log(o_read_log),
    .o_addr_log_to_mem(o_addr_log_to_mem)
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
