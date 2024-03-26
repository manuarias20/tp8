//! @title registerFile
//! @file tb_registerFile.v

`timescale 1ns/1ps

module tb_registerFile #(
    parameter NB_ADDR_MEM = 15
);

  //  COMANDOS DEL UP
  localparam RESET    = 8'd0;     // Resetear el sistema
  localparam EN_TX    = 8'd1;     // Habilitar el Tx
  localparam EN_RX    = 8'd2;     // Habilitar el Rx
  localparam PH_SEL   = 8'd3;     // Selección de fase del filtro
  localparam RUN_MEM  = 8'd4;     // Comenzar el logueo de datos en memoria
  localparam READ_MEM = 8'd5;     // Habilitar la lectura de memoria
  localparam ADDR_MEM = 8'd6;     // Leer memoria en la direccion indicada
  localparam BER_S_I  = 8'd7;     // Leer cantidad de muestras de la BER del canal I
  localparam BER_S_Q  = 8'd8;     // Leer cantidad de muestras de la BER del canal Q
  localparam BER_E_I  = 8'd9;     // Leer cantidad de errores de la BER del canal I
  localparam BER_E_Q  = 8'd10;    // Leer cantidad de errores de la BER del canal Q
  localparam BER_H    = 8'd11;    // Leer parte alta del ultimo valor de BER
  
  //! DUT inputs
  reg                    tb_rst;
  reg                    tb_clk;
  reg             [31:0] i_gpo;
  reg             [31:0] i_data_log_from_mem;
  reg                    i_mem_full;
  reg             [63:0] i_ber_samp_I;
  reg             [63:0] i_ber_samp_Q;
  reg             [63:0] i_ber_error_I;
  reg             [63:0] i_ber_error_Q;
  
  //! DUT outputs
  wire            [31:0] o_gpi;
  wire                   o_rst;
  wire                   o_enbTx;
  wire                   o_enbRx;
  wire             [1:0] o_phase_sel;
  wire                   o_run_log;
  wire                   o_read_log;
  wire [NB_ADDR_MEM-1:0] o_addr_log_to_mem;
  

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
//  Ingresar comandos y chequear las salidas

    always #5 tb_clk = ~tb_clk;

// Stimulus
    initial begin
        tb_clk              = 0;
        tb_rst              = 1;
        i_data_log_from_mem = 32'b0;
        i_mem_full          = 0;
        i_ber_samp_I        = 64'b0;
        i_ber_samp_Q        = 64'b0;
        i_ber_error_I       = 64'b0;
        i_ber_error_Q       = 64'b0;

        $display("");
        $display("Simulation Started");
        $display("\t\t\t\t Time, rst, enbTx, enbRx, phase_sel, run_log, read_log, addr_log_to_mem");
        $monitor("%1t: %d      %d       %d        %d       %d        %d                %d",$time, o_rst, o_enbTx, o_enbRx, o_phase_sel, o_run_log, o_read_log, o_addr_log_to_mem);


                i_gpo     = {RESET, 1'b1, 23'b0}; //comando de reset
        #10     tb_rst    = 0;
                i_gpo[23] = 1'b0;   //toggle enable
        #20     i_gpo     = {EN_TX, 1'b1, 23'b1}; // Enable Tx
        #10     i_gpo[23] = 1'b0;
        #20     i_gpo     = {EN_RX, 1'b1, 23'b1}; // Enable Rx
        #10     i_gpo[23] = 1'b0;   
        #20     i_gpo     = {PH_SEL, 1'b1, 23'd0}; // Fase = 0
        #10     i_gpo[23] = 1'b0;   
        #20     i_gpo     = {PH_SEL, 1'b1, 23'd1}; // Fase = 1
        #10     i_gpo[23] = 1'b0;   
        #20     i_gpo     = {PH_SEL, 1'b1, 23'd2}; // Fase = 2
        #10     i_gpo[23] = 1'b0;   
        #20     i_gpo     = {PH_SEL, 1'b1, 23'd3}; // Fase = 3
        #10     i_gpo[23] = 1'b0;   
        #20     i_gpo     = {BER_S_I, 1'b1, 23'b0}; // 
        #10     i_gpo[23] = 1'b0;   
        #20     i_gpo     = {BER_S_Q, 1'b1, 23'b0}; // 
        #10     i_gpo[23] = 1'b0;   
        #20     i_gpo     = {BER_E_I, 1'b1, 23'b0}; // 
        #10     i_gpo[23] = 1'b0;   
        #20     i_gpo     = {BER_E_Q, 1'b1, 23'b0}; // 
        #10     i_gpo[23] = 1'b0;   
        #20     i_gpo     = {BER_H, 1'b1, 23'b0}; // 
        #10     i_gpo[23] = 1'b0;   
        #100;
        

        $display("Simulation Finished");
        $display("");
        $finish;
  end

endmodule
