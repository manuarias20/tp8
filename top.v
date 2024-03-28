module top #(
    parameter NB_GPIOS = 32,
    parameter NB_LEDS  =  4,
    parameter BRAM_ADDR_WIDTH = 15,
    parameter BRAM_DATA_WIDTH = 16
  )
  (
   output wire  [NB_LEDS - 1 : 0] o_led      , //! lock_clk -> o_led[0]. o_rst -> o_led[1]. o_enb[0] -> o_led[2]. o_enb[1] -> o_led[3].
   output             [3 - 1 : 0] o_led_RGB0 ,
   output             [3 - 1 : 0] o_led_RGB1 ,
  //  output wire                   out_tx_uart,
   output wire [NB_GPIOS - 1 : 0] gpi0       ,
   input  wire [NB_GPIOS - 1 : 0] gpo0       ,
  //  input  wire                   in_rx_uart ,
   input  wire                    i_resetn   ,
   input  wire                    i_sw       ,
   input                          clk100
   );

   ///////////////////////////////////////////
   // Vars
   ///////////////////////////////////////////
   // Descomentar para usar el uBlaze
  //  wire [NB_GPIOS                 - 1 : 0]           gpo0;
  //  wire [NB_GPIOS                 - 1 : 0]           gpi0;

   wire                                              clockdsp;

   /////////////////////////////////////////////////////////////////////////////////////
   // For output LEDs
   /////////////////////////////////////////////////////////////////////////////////////
   // LEDs
   wire                                              lock_clk;         // o_led[0]
   wire                                              reset;            // o_led[1]
   wire                                              i_reset_from_vio; 
   wire                                              EnbTx;            // o_led[2]
   wire                                              EnbRx;            // o_led[3]
   // RGB LEDs
   wire                                              run_log;          // o_led_RGB0[2]
   wire                                              read_log;         // o_led_RGB0[1]
   wire                                              mem_full;         // o_led_RGB0[0]
   wire                            [1 : 0]           phase_sel;        // o_led_RGB1[1:0]

   /////////////////////////////////////////////////////////////////////////////////////
   // For DSP
   /////////////////////////////////////////////////////////////////////////////////////
   wire                            [3 : 0]           rst_RF_to_DSP;   
   wire                            [3 : 0]           dsp_sw;           // dsp_sw[3:0]->dsp.i_sw[3:0]
   wire                            [3 : 0]           dsp_o_led;        // dsp.o_led[3:0]->dsp_o_led[3:0]->vio
   wire                           [63 : 0]           ber_samp_I;       
   wire                           [63 : 0]           ber_samp_Q;       
   wire                           [63 : 0]           ber_error_I;       
   wire                           [63 : 0]           ber_error_Q;       

   /////////////////////////////////////////////////////////////////////////////////////
   // For MEMLog
   /////////////////////////////////////////////////////////////////////////////////////
   wire          [2*BRAM_DATA_WIDTH-1 : 0]           data_log_from_mem;       
   wire            [BRAM_ADDR_WIDTH-1 : 0]           addr_log_to_mem;       
   wire            [BRAM_DATA_WIDTH-1 : 0]           filter_data;       
   



   //////////////////////////////////////////////////////////////
   // Descomentar en caso de incluir el VIO
  //  wire                                              fromHard;
  //  wire [3  : 0]                                     fromVio;
   
   ///////////////////////////////////////////
   // MicroBlaze
   ///////////////////////////////////////////
   //design_1
   /*MicroGPIO
     u_micro
       (.clock100         (clockdsp    ),  // Clock aplicacion
        .gpio_rtl_tri_o   (gpo0        ),  // GPIO
        .gpio_rtl_tri_i   (gpi0        ),  // GPIO
        .reset            (i_resetn    ),  // Hard Reset
        .sys_clock        (clk100      ),  // Clock de FPGA
        .o_lock_clock     (lock_clk    ),  // Senal Lock Clock
        .usb_uart_rxd     (in_rx_uart  ),  // UART
        .usb_uart_txd     (out_tx_uart )   // UART
        );
   */
   assign reset = ~i_resetn;
  //  assign reset = (fromHard) ? ~i_resetn : i_reset_from_vio;

  //  assign gpi0[3  : 0] = (fromHard) ? i_sw : fromVio; // Descomentar en caso de incluir el VIO
  //  assign gpi0[3  : 0] = i_sw; // Comentar en caso de incluir el VIO
  //  assign gpi0[31 : 4] = {28{1'b0}};

   ///////////////////////////////////////////
   // Descomentar en caso de incluir el VIO
   /*
   vio
   u_vio
   (.clk_0        (clockdsp),
    .probe_in0_0  ({gpo0[2] ,gpo0[1] ,gpo0[0]}),
    .probe_in1_0  ({gpo0[5] ,gpo0[4] ,gpo0[3]}),
    .probe_in2_0  ({gpo0[8] ,gpo0[7] ,gpo0[6]}),
    .probe_in3_0  ({gpo0[11],gpo0[10],gpo0[9]}),
    .probe_in4_0  (dsp_o_led[3],dsp_o_led[2],dsp_o_led[1],dsp_o_led[0]),
    .probe_out0_0 (fromHard),
    .probe_out1_0 (fromVio),
    .probe_out2_0 (i_reset_from_vio)
    );
    */
   ///////////////////////////////////////////
   // Register File
   ///////////////////////////////////////////
   registerFile
    u_registerFile 
      (.o_gpio(gpi0)                          ,
       .o_rst(rst_RF_to_DSP)                  ,
       .o_enbTx(EnbTx)                        ,
       .o_enbRx(EnbRx)                        ,
       .o_phase_sel(phase_sel)                ,
       .o_run_log(run_log)                    ,
       .o_read_log(read_log)                  ,
       .o_addr_log_to_mem(addr_log_to_mem)    ,
       .i_gpio(gpo0)                          ,
       .i_data_log_from_mem(data_log_from_mem),
       .i_mem_full(mem_full)                  ,
       .i_ber_samp_I(ber_samp_I)              ,   
       .i_ber_samp_Q(ber_samp_Q)              ,   
       .i_ber_error_I(ber_error_I)            ,   
       .i_ber_error_I(ber_error_Q)            ,   
       .i_rst(reset)                          ,   //! Reset
       .clk(clk100)                               //! Clock
   );

   ///////////////////////////////////////////
   // MEMLog
   ///////////////////////////////////////////
   MEMLog
    u_MEMLog
      (.o_mem_full(mem_full)                  ,
       .o_data_log_from_mem(data_log_from_mem),
       .i_filter_data(filter_data)            ,
       .i_run_log(run_log)                    ,
       .i_read_log(read_log)                  ,
       .i_addr_log_to_mem(addr_log_to_mem)    ,
       .i_rst(reset)                          ,   //! Reset
       .clk(clk100)                               //! Clock
   );

   ///////////////////////////////////////////
   // DSP
   ///////////////////////////////////////////
   DSP
    u_dsp 
    (
     .o_filter_data(filter_data),  //! Tx Filter outputs. I ([15:8]) & Q ([7:0]).
     .o_led(dsp_o_led)          ,  //! i_rstn->o_led[0]. EnbTx->o_led[1]. EnbRx->o_led[2]. BER=0->o_led[3].
     .o_ber_samp_I(ber_samp_I)  ,
     .o_ber_samp_Q(ber_samp_Q)  ,
     .o_ber_error_I(ber_error_I),
     .o_ber_error_Q(ber_error_Q),
     .i_sw(dsp_sw)              ,  //! i_sw[0]->EnbTx. i_sw[1]->EnbRx. i_sw[3:2]->Phase selector.
     .i_rstn(rst_RF_to_DSP)     ,  //! Reset (active low)
     .clk(clk100)                  //! Clock
    );

    assign dsp_sw[0] = EnbTx;
    assign dsp_sw[1] = EnbRx;
    assign dsp_sw[2] = phase_sel[0];
    assign dsp_sw[3] = phase_sel[1];


   ///////////////////////////////////////////
   // Leds
   ///////////////////////////////////////////
   assign o_led[0] = lock_clk;
   assign o_led[1] = reset;
   assign o_led[2] = EnbTx;
   assign o_led[3] = EnbRx;

   assign out_led_RGB0[0] = mem_full;
   assign out_led_RGB0[1] = read_log;
   assign out_led_RGB0[2] = run_log;

   assign out_led_RGB1[0] = phase_sel[0];
   assign out_led_RGB1[1] = phase_sel[1];
   assign out_led_RGB1[2] = 1'b0;



   //.out_rf_to_micro_data  (gpi0),

endmodule // top
