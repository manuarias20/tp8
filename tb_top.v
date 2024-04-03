//! @title top
//! @file tb_top.v

`timescale 1ns/1ps

module tb_top #(
    parameter NB_GPIOS = 32,
    parameter NB_LEDS  =  4,
    parameter BRAM_ADDR_WIDTH = 15,
    parameter BRAM_DATA_WIDTH = 16
);

  //  COMANDOS DEL UP
  localparam RESET       = 8'd0;     // Resetear el sistema
  localparam EN_TX       = 8'd1;     // Habilitar el Tx
  localparam EN_RX       = 8'd2;     // Habilitar el Rx
  localparam PH_SEL      = 8'd3;     // Selección de fase del filtro
  localparam RUN_MEM     = 8'd4;     // Comenzar el logueo de datos en memoria
  localparam READ_MEM    = 8'd5;     // Habilitar la lectura de memoria
  localparam ADDR_MEM    = 8'd6;     // Leer memoria en la direccion indicada
  localparam BER_S_I     = 8'd7;     // Leer cantidad de muestras de la BER del canal I
  localparam BER_S_Q     = 8'd8;     // Leer cantidad de muestras de la BER del canal Q
  localparam BER_E_I     = 8'd9;     // Leer cantidad de errores de la BER del canal I
  localparam BER_E_Q     = 8'd10;    // Leer cantidad de errores de la BER del canal Q
  localparam BER_H       = 8'd11;    // Leer parte alta del ultimo valor de BER
  localparam IS_MEM_FULL = 8'd12;
  //! DUT inputs
  reg                     tb_rst;
  reg                     tb_clk;
  reg              [31:0] i_gpo;
  
  //! DUT outputs
  wire  [NB_LEDS - 1 : 0] o_led;
  wire        [3 - 1 : 0] o_led_RGB0;
  wire        [3 - 1 : 0] o_led_RGB1;
  wire [NB_GPIOS - 1 : 0] o_gpi;

  top
#(
    .NB_GPIOS(NB_GPIOS),
    .NB_LEDS(NB_LEDS),
    .BRAM_ADDR_WIDTH(BRAM_ADDR_WIDTH),
    .BRAM_DATA_WIDTH(BRAM_DATA_WIDTH)
)
u_top
(
    .o_led(o_led),
    .o_led_RGB0(o_led_RGB0),
    .o_led_RGB1(o_led_RGB1),
    .o_gpi(o_gpi),
    .i_gpo(i_gpo),
    .i_resetn(~tb_rst),
    .clk100(tb_clk)
);
//  Ingresar comandos y chequear las salidas

    always #5 tb_clk = ~tb_clk;

// Stimulus
    initial begin
        tb_clk              = 0;
        tb_rst              = 1;

        $display("");
        $display("Simulation Started");
        $display("\t\t\t\t Time,        i_gpo,        o_gpi");
        // $monitor("%1t: %d      %d       %d        %d       %d        %d                %d",$time, o_rst, o_enbTx, o_enbRx, o_phase_sel, o_run_log, o_read_log, o_addr_log_to_mem);

        i_gpo[23] = 32'h00000000;   //toggle enable

        #10     tb_rst    = 0;
        #20     i_gpo     = {RESET, 1'b1, 23'b1}; //comando de reset
        #10     i_gpo[23] = 1'b0;   //toggle enable
        $display("%1t:      %x        %x      RESET",$time, i_gpo, o_gpi);
        #20     i_gpo     = {EN_TX, 1'b1, 23'b1}; // Enable Tx
        #10     i_gpo[23] = 1'b0;
        $display("%1t:      %x        %x      EN_TX",$time, i_gpo, o_gpi);
        #20     i_gpo     = {EN_RX, 1'b1, 23'b1}; // Enable Rx
        #10     i_gpo[23] = 1'b0;   
        $display("%1t:      %x        %x      EN_RX",$time, i_gpo, o_gpi);
        #20     i_gpo     = {PH_SEL, 1'b1, 23'd0}; // Fase = 0
        #10     i_gpo[23] = 1'b0;   
        $display("%1t:      %x        %x      PH_SEL = 0",$time, i_gpo, o_gpi);
        #20     i_gpo     = {PH_SEL, 1'b1, 23'd1}; // Fase = 1
        #10     i_gpo[23] = 1'b0;   
        $display("%1t:      %x        %x      PH_SEL = 1",$time, i_gpo, o_gpi);
        #20     i_gpo     = {PH_SEL, 1'b1, 23'd2}; // Fase = 2
        #10     i_gpo[23] = 1'b0;   
        $display("%1t:      %x        %x      PH_SEL = 2",$time, i_gpo, o_gpi);
        #20     i_gpo     = {PH_SEL, 1'b1, 23'd3}; // Fase = 3
        #10     i_gpo[23] = 1'b0;   
        $display("%1t:      %x        %x      PH_SEL = 3",$time, i_gpo, o_gpi);
        #20     i_gpo     = {BER_S_I, 1'b1, 23'b0}; // 
        #10     i_gpo[23] = 1'b0;   
        $display("%1t:      %x        %x      BER_S_I",$time, i_gpo, o_gpi);
        #20     i_gpo     = {BER_S_Q, 1'b1, 23'b0}; // 
        #10     i_gpo[23] = 1'b0;   
        $display("%1t:      %x        %x      BER_S_Q",$time, i_gpo, o_gpi);
        #20     i_gpo     = {BER_E_I, 1'b1, 23'b0}; // 
        #10     i_gpo[23] = 1'b0;   
        $display("%1t:      %x        %x      BER_E_I",$time, i_gpo, o_gpi);
        #20     i_gpo     = {BER_E_Q, 1'b1, 23'b0}; // 
        #10     i_gpo[23] = 1'b0;   
        $display("%1t:      %x        %x      BER_E_Q",$time, i_gpo, o_gpi);
        #20     i_gpo     = {BER_H, 1'b1, 23'b0}; // 
        #10     i_gpo[23] = 1'b0;   
        $display("%1t:      %x        %x      BER_H",$time, i_gpo, o_gpi);
        #20     i_gpo     = {IS_MEM_FULL, 1'b1, 23'b0}; // 
        #10     i_gpo[23] = 1'b0;
        $display("%1t:      %x        %x      IS_MEM_FULL",$time, i_gpo, o_gpi);
        #2000000;
        #20     i_gpo     = {RUN_MEM, 1'b1, 23'b0}; // 
        #10     i_gpo[23] = 1'b0;
        $display("%1t:      %x        %x      RUN_MEM",$time, i_gpo, o_gpi);
        #20     i_gpo     = {IS_MEM_FULL, 1'b1, 23'b0}; // 
        #10     i_gpo[23] = 1'b0;
        $display("%1t:      %x        %x      IS_MEM_FULL",$time, i_gpo, o_gpi);
        #2000000;
        #20     i_gpo     = {IS_MEM_FULL, 1'b1, 23'b0}; // 
        #10     i_gpo[23] = 1'b0;
        $display("%1t:      %x        %x      IS_MEM_FULL",$time, i_gpo, o_gpi);
        #20     i_gpo     = {READ_MEM, 1'b1, 23'b010101010011100}; // 
        #20     i_gpo[23] = 1'b0;
        $display("%1t:      %x        %x      READ_MEM",$time, i_gpo, o_gpi);
        #20     i_gpo     = {READ_MEM, 1'b1, 23'b100001100011100}; // 
        #20     i_gpo[23] = 1'b0;
        $display("%1t:      %x        %x      READ_MEM",$time, i_gpo, o_gpi);
        #20     i_gpo     = {READ_MEM, 1'b1, 23'b000100000011100}; // 
        #20     i_gpo[23] = 1'b0;
        $display("%1t:      %x        %x      READ_MEM",$time, i_gpo, o_gpi);
        #20     i_gpo     = {READ_MEM, 1'b1, 23'b010101101111001}; // 
        #20     i_gpo[23] = 1'b0;
        $display("%1t:      %x        %x      READ_MEM",$time, i_gpo, o_gpi);
        #100;
        

        $display("Simulation Finished");
        $display("");
        $finish;
  end

endmodule
