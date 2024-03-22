`timescale 1ns/1ps
//! @title Top module
//! @file top.v

//! - Top module of a basic communications system
//! - **i_rstn** is the system reset (active low).


module register_file
  #(
    parameter SEED_I       = 9'h1AA, //! PRBS9I seed
    parameter SEED_Q       = 9'h1FE, //! PRBS9Q seed
    parameter N_SAMPLES  = 511,   //! Number of samples for each position of the delay register (BER)
    parameter N_POS      = 511,   //! Number of positions of the delay register (BER)
    parameter N_PHASES   = 4,     //! Number of phases
    parameter NB_OUTPUT_TX  = 8, //! NB of the Tx Filter output
    parameter NBF_OUTPUT_TX = 7, //! NBF of the Tx Filter output
    parameter NB_COEFF   = 8, //! NB of Coefficients
    parameter NBF_COEFF  = 7,  //! NBF of Coefficients
    parameter NB_SWITCH  = 4,  //! NB of switch
    parameter NB_LEDS  = 4  //! NB of output leds
  ) 
  (
    output             o_rst              ,
    output       [1:0] o_enb              , //! o_enb[0] -> EnbTx. o_enb[1] -> EnbRx 
    output       [1:0] o_phase_sel        ,
    
    output             o_run_log          ,
    output             o_read_log         ,
    output      [14:0] o_addr_log_to_mem  ,

    input       [31:0] i_data_log_from_mem,
    input              i_mem_full         ,
    input       [63:0] i_ber_samp_I       ,   
    input       [63:0] i_ber_samp_Q       ,   
    input       [63:0] i_ber_error_I      ,   
    input       [63:0] i_ber_error_I      ,   

    input              i_rst              ,   //! Reset
    input              clk                    //! Clock
  );



  //! Internal Signals
  wire                    control_o_valid         ; //! Control o_valid
  wire                    data_prbs9I_tx_to_RC_TxI; //! Data from prbs9I_tx to RC_TxI
  wire                    data_prbs9Q_tx_to_RC_TxQ; //! Data from prbs9Q_tx to RC_TxQ
  wire [NB_OUTPUT_TX-1:0] data_RC_TxI_to_BER_I;     //! Data from RC_TxI to BER_I
  wire [NB_OUTPUT_TX-1:0] data_RC_TxQ_to_BER_Q;     //! Data from RC_TxQ to BER_Q
  wire                    o_ber_zero_I;             //! Ber equal to zero (I)
  wire                    o_ber_zero_Q;             //! Ber equal to zero (Q)

  //! Vars ILA
  wire    [NB_SWITCH-1:0] sw_from_vio;
  wire                    reset_from_vio;
  wire                    sel_mux;
  wire    [NB_SWITCH-1:0] sw_w;
  wire                    reset;

  assign  sw_w = (sel_mux) ?  sw_from_vio    :  i_sw;
  assign reset = (sel_mux) ? ~reset_from_vio : ~i_rstn;

  //! Assignments
  assign o_led[0] = reset; 
  assign o_led[1] = sw_w[0]; 
  assign o_led[2] = sw_w[1]; 
  assign o_led[3] = o_ber_zero_I & o_ber_zero_Q; 

  //! Instances
  //! Control
  control
  #(
    .N(N_PHASES)
  )
  u_control
  (
    .o_valid(control_o_valid),
    .i_rst(reset), 
    .clk(clk)      
  );

  //! PRBS9I Tx
  prbs9
  #(
    .SEED(SEED_I)
  )
  u_prbs9I_tx
  (
    .o_data(data_prbs9I_tx_to_RC_TxI),
    .i_valid(control_o_valid), 
    .i_en(sw_w[0]), 
    .i_rst(reset), 
    .clk(clk)      
  );

  //! PRBS9Q Tx
  prbs9
  #(
    .SEED(SEED_Q)
  )
  u_prbs9Q_tx
  (
    .o_data(data_prbs9Q_tx_to_RC_TxQ),
    .i_valid(control_o_valid), 
    .i_en(sw_w[0]), 
    .i_rst(reset), 
    .clk(clk)      
  );

  //! RC TxI
  poly_fir_filter
    #(
      .NB_OUTPUT  (NB_OUTPUT_TX), //! NB of output
      .NBF_OUTPUT (NBF_OUTPUT_TX), //! NBF of output
      .NB_COEFF   (NB_COEFF), //! NB of Coefficients
      .NBF_COEFF  (NBF_COEFF)  //! NBF of Coefficients
    )
    u_RC_TxI
      (
        .o_data  (data_RC_TxI_to_BER_I),
        .i_data  (data_prbs9I_tx_to_RC_TxI),
        .i_en        (sw_w[0]),
        .i_valid  (control_o_valid),
        .i_rst      (reset),
        .clk        (clk)
      );

  //! RC TxQ
  poly_fir_filter
    #(
      .NB_OUTPUT  (NB_OUTPUT_TX), //! NB of output
      .NBF_OUTPUT (NBF_OUTPUT_TX), //! NBF of output
      .NB_COEFF   (NB_COEFF), //! NB of Coefficients
      .NBF_COEFF  (NBF_COEFF)  //! NBF of Coefficients
    )
    u_RC_TxQ
      (
        .o_data  (data_RC_TxQ_to_BER_Q),
        .i_data  (data_prbs9Q_tx_to_RC_TxQ),
        .i_en        (sw_w[0]),
        .i_valid  (control_o_valid),
        .i_rst      (reset),
        .clk        (clk)
      );

  //! BER I
  BER
    #(
      .NB_INPUT  (NB_OUTPUT_TX),
      .NBF_INPUT (NBF_OUTPUT_TX), 
      .N_SAMPLES   (N_SAMPLES),
      .N_POS  (N_POS),
      .N_PHASES  (N_PHASES),
      .SEED  (SEED_I)
    )
    u_BER_I 
      (
        .o_ber_zero (o_ber_zero_I),
        .i_data (data_RC_TxI_to_BER_I),
        .i_en   (sw_w[1]),
        .i_valid(control_o_valid),
        .i_phase_sel(sw_w[3:2]),
        .i_rst  (reset),
        .clk    (clk)
      );

  //! BER Q
  BER
    #(
      .NB_INPUT  (NB_OUTPUT_TX),
      .NBF_INPUT (NBF_OUTPUT_TX), 
      .N_SAMPLES   (N_SAMPLES),
      .N_POS  (N_POS),
      .N_PHASES  (N_PHASES),
      .SEED  (SEED_Q)
    )
    u_BER_Q 
      (
        .o_ber_zero (o_ber_zero_Q),
        .i_data (data_RC_TxQ_to_BER_Q),
        .i_en   (sw_w[1]),
        .i_valid(control_o_valid),
        .i_phase_sel(sw_w[3:2]),
        .i_rst  (reset),
        .clk    (clk)
      );
      
    ila
    u_ila
    (.clk_0(clk),
     .probe0_0(o_led));
    
    vio u_vio
    (.clk_0(clk),
     .probe_in0_0(o_led),
     .probe_out0_0(sel_mux),
     .probe_out1_0(sw_from_vio),
     .probe_out2_0(reset_from_vio));

endmodule
