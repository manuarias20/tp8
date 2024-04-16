`timescale 1ns/1ps
//! @title Bit Error Rate (BER)
//! @file BER.v

//! - BER with phase and delay selector
//! - **i_rst** is the system reset.
//! - **i_en** controls the enable (1) of the FIR. The value (0) stops the systems without change of the current state of the FIR.


module BER
  #(
    parameter NB_INPUT   = 8,      //! NB of output
    parameter NBF_INPUT  = 7,      //! NBF of output
    parameter N_SAMPLES  = 511,    //! Number of samples for each position of the delay register
    parameter N_POS      = 511,    //! Number of positions of the delay register
    parameter N_PHASES   = 4,      //! Number of phases
    parameter SEED       = 9'h1AA, //! PRBS seed
    parameter NB_BER_CNT = 64      //! NB of BER counters
  ) 
  (
    output                        o_ber_zero ,   //! Output BER equal to zero
    output       [NB_BER_CNT-1:0] o_ber_samp ,   //! Output BER sample counter
    output       [NB_BER_CNT-1:0] o_ber_error,   //! Output BER error counter
    input          [NB_INPUT-1:0] i_data     ,   //! Input Sample
    input                         i_en       ,   //! Enable
    input                         i_valid    ,   //! Valid
    input          [N_PHASES-1:0] i_phase_sel,   //! Phase selector
    input                         i_rst      ,   //! Reset
    input                         clk            //! Clock
  );

  //! Local parameters
  localparam NB_STATE    = 2;
  localparam RESET_MODE  = 2'b00;
  localparam SYNCH_MODE  = 2'b01;
  localparam COUNT_MODE  = 2'b10;
  localparam STOP_MODE   = 2'b11;

  localparam NB_PHASES   = $clog2(N_PHASES);
  localparam NB_SAMPLES  = $clog2(N_SAMPLES);
  localparam NB_POS      = $clog2(N_POS);
  // localparam MAX_SAMPLES = 2 ** NB_BER_CNT - 1;

  //! Internal Signals
  reg    [NB_INPUT-1:0]            phase       ; //! Phase selected
  reg    [NB_INPUT-1:0]   phase_register  [3:0]; //! Shift register for phases
  reg   [NB_PHASES-1:0]        phase_cnt       ; //! Phase cunter
  wire                       slice_value       ; //! Output value of slicer
  wire                   prbs9_rx_o_data       ; //! PRBS Rx Output 
  reg       [N_POS-1:0]     dly_register       ; //! Delay shift Register for 2^N-1 with N = 9
  reg  [NB_SAMPLES-1:0]      min_cnt_pos       ; //! Minimun error count position of delay shift register
  reg  [NB_SAMPLES-1:0]      min_err_cnt       ; //! Minimun error count of delay shift register
  reg  [NB_BER_CNT-1:0]          err_cnt       ; //! Error count of selected delay shift register
  reg  [NB_BER_CNT-1:0]         samp_cnt       ; //! Samples counter
  reg      [NB_POS-1:0]          pos_cnt       ; //! Current position of delay shift register
  reg    [NB_STATE-1:0]            state       ; //! Current state
  reg    [NB_STATE-1:0]       next_state       ; //! Next state
  reg                     inter_ber_zero       ; //! Internal BER equal to zero

  // Assignments
  assign o_ber_samp  = samp_cnt;
  assign o_ber_error = err_cnt;

  //! PRBS Rx
  prbs9
  #(
    .SEED(SEED)
  )
  prbs9_rx
  (
    .o_data(prbs9_rx_o_data),
    .i_valid(i_valid), 
    .i_en(i_en), 
    .i_rst(i_rst), 
    .clk(clk)      
  );

  //! Phase counter
  always @(posedge clk) begin : phase_cnt_cal
    if(i_rst) begin
      phase_cnt <= {NB_POS{1'b0}};
    end
    else begin
      if (i_en) begin
        if (phase_cnt == (N_PHASES-1))
          phase_cnt <= {NB_POS{1'b0}};
        else
          phase_cnt <= phase_cnt + 1'b1;
      end
    end
  end

  //! Register with 4 phases
  integer ptr1;
  always @(posedge clk) begin : proc_phase_register
    if(i_rst) begin
      for (ptr1 = 0; ptr1 < N_PHASES; ptr1=ptr1+1) begin
        phase_register[ptr1] <= {NB_INPUT{1'b0}};
      end
    end
    else begin
      if (i_en) begin
        if (phase_cnt == 0) 
          phase_register[0] <= i_data;
        else if (phase_cnt == 1) 
          phase_register[1] <= i_data;
        else if (phase_cnt == 2) 
          phase_register[2] <= i_data;
        else
          phase_register[3] <= i_data;
      end
    end
  end

  //! Downsampling
  always @(*) begin : downsampling
    case (i_phase_sel)
      2'b00:
      begin
        phase = phase_register[0];
      end
      2'b01:
      begin
        phase = phase_register[1];
      end
      2'b10:
      begin
        phase = phase_register[2];
      end
      2'b11:
      begin
        phase = phase_register[3];
      end
      default:
      begin
        phase = phase_register[0];
      end
    endcase
    // phase = phase_register[i_phase_sel];
  end

  //! Slicer
  assign slice_value = phase[NB_INPUT-1];

  //! DelayShiftRegister model
  integer ptr2;
  always @(posedge clk) begin:delayShiftRegister
    if (i_rst == 1'b1) begin:init
      for (ptr2 = 0; ptr2 < N_POS; ptr2=ptr2+1)
        dly_register[ptr2] <= 1'b0;
    end
    else if (i_en && i_valid) begin :dsrmove
      dly_register <= {dly_register[N_POS-2:0],prbs9_rx_o_data}; 
    end
  end

  //! Sample counter
  always @(posedge clk) begin : samp_cnt_cal
    if(i_rst) begin
      samp_cnt <= {NB_BER_CNT{1'b0}};
    end
    else if (state == RESET_MODE) begin
      samp_cnt <= {NB_BER_CNT{1'b0}};
    end
    else if(state == SYNCH_MODE) begin
      if (i_en && i_valid) begin
        if (samp_cnt == (N_SAMPLES-1))
          samp_cnt <= {NB_BER_CNT{1'b0}};
        else
          samp_cnt <= samp_cnt + 1'b1;
      end
    end
    else if(state == COUNT_MODE) begin
      if (i_en && i_valid) begin
        if (samp_cnt < (64'hFFFF_FFFF_FFFF_FFFF)) // samp_cnt < MAX_SAMPLES = 2 ** 64 - 1
          samp_cnt <= samp_cnt + 1'b1;
      end
    end
  end

  //! Current position counter
  always @(posedge clk) begin : pos_cnt_cal
    if(i_rst) begin
      pos_cnt <= {NB_POS{1'b0}};
    end
    else if (state == RESET_MODE) begin
      pos_cnt <= {NB_POS{1'b0}};
    end
    else if(state == SYNCH_MODE) begin
      if (i_en && i_valid && (samp_cnt == (N_SAMPLES-1))) begin
        if (pos_cnt == (N_SAMPLES-1)) begin
          if (err_cnt > min_err_cnt)            
            pos_cnt <= min_cnt_pos;
        end
        else
          pos_cnt <= pos_cnt + 1'b1;
      end
    end
  end

  //! Error Counter
  always @(posedge clk) begin : err_cnt_cal
    if(i_rst) begin
      err_cnt <= {NB_BER_CNT{1'b0}};
    end
    else if (state == RESET_MODE) begin
      err_cnt <= {NB_BER_CNT{1'b0}};
    end
    else if(state == SYNCH_MODE) begin
      if (i_en && i_valid) begin
        if (samp_cnt == (N_SAMPLES-1))
          err_cnt <= {NB_BER_CNT{1'b0}};
        else
          err_cnt <= err_cnt + (dly_register[pos_cnt] ^ slice_value);
      end
    end
    else if(state == COUNT_MODE) begin
      if (i_en && i_valid) begin
        if (err_cnt < (64'hFFFF_FFFF_FFFF_FFFF)) // samp_cnt < MAX_SAMPLES = 2 ** 64 - 1
          err_cnt <= err_cnt + (dly_register[pos_cnt] ^ slice_value);
      end
    end
  end

  //! Minimun error count
  always @(posedge clk) begin : min_err_cnt_cal
    if(i_rst) begin
      min_err_cnt <= {NB_SAMPLES{1'b1}};
    end
    else if (state == RESET_MODE) begin
      min_err_cnt <= {NB_SAMPLES{1'b1}};
    end
    else if(state == SYNCH_MODE) begin
      if (i_en && i_valid && samp_cnt == (N_SAMPLES-1)) begin
        if (err_cnt < min_err_cnt)
          min_err_cnt <= err_cnt;
      end
    end
  end

  //! Minimun error count position
  always @(posedge clk) begin : min_cnt_pos_cal
    if(i_rst) begin
      min_cnt_pos <= {NB_SAMPLES{1'b0}};
    end
    else if (state == RESET_MODE) begin
      min_cnt_pos <= {NB_SAMPLES{1'b0}};
    end
    else if(state == SYNCH_MODE) begin
      if (i_en && i_valid && samp_cnt == (N_SAMPLES-1)) begin
        if (err_cnt < min_err_cnt)
          min_cnt_pos <= pos_cnt;
      end
    end
  end

  /////////////////////////////////////////////////////////////
  // State Machine

  //! State machine next state model
  always @(posedge clk) begin : state_calc
    if(i_rst) begin
      state <= RESET_MODE;
    end else begin
      state <= next_state;
    end
  end

  always @(*) begin : next_state_calc
    case(state)
      RESET_MODE:
      begin
        if (i_en == 1)
          next_state = SYNCH_MODE;
        else
          next_state = RESET_MODE;

      end
      SYNCH_MODE:
      begin
        if ((i_en == 1) && (i_valid==1) && (pos_cnt == N_SAMPLES-1) && (samp_cnt == N_SAMPLES-1))
          next_state = COUNT_MODE;
        else
          next_state = state;
      end
      COUNT_MODE:
      begin
        if ((!i_en) || ((pos_cnt == 64'hFFFF_FFFF_FFFF_FFFE) && (samp_cnt == 64'hFFFF_FFFF_FFFF_FFFE) && i_en && i_valid)) // MAX_SAMPLES-1 = 64'hFFFF_FFFF_FFFF_FFFE
          next_state = STOP_MODE;
        else
          next_state = state;
      end
      STOP_MODE:
      begin
        if (i_en) 
          next_state = RESET_MODE;
        else
          next_state = state;
      end
      default:
      begin
        next_state = RESET_MODE;
      end
    endcase // state
  end

  /////////////////////////////////////////////////////////////


  // Output
  always @(posedge clk) begin : proc_inter_ber_zero
    if(i_rst) begin
      inter_ber_zero <= 1'b0;
    end else begin
      if (i_en && err_cnt == {NB_BER_CNT{1'b0}}) begin
        inter_ber_zero <= 1'b1;
      end
      else
        inter_ber_zero <= 1'b0;
    end
  end


  assign o_ber_zero = inter_ber_zero;


endmodule
