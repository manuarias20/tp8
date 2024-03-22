`timescale 1ns/1ps
//! @title Polyphase FIR Filter
//! @file poly_fir_filter.v

//! - Fir filter with 24 coefficients. 4 phases of 6 coefficients. 
//! - **i_rst** is the system reset.
//! - **i_en** controls the enable (1) of the FIR. The value (0) stops the systems without change of the current state of the FIR.
//! - **i_valid** controls the counter, that change the set of coefficients. When enable (1), the counter start counting. When disable (0) stops the counting when counter is 0.
//! - Coefficients [ 0.0,       0.015625, 0.015625,  0.0,
//! -               -0.0625,   -0.125,   -0.125,    -0.0078125,
//! -                0.2578125, 0.59375,  0.8828125, 0.9921875,
//! -                0.8828125, 0.59375,  0.2578125, 0.0,
//! -               -0.125,    -0.125,   -0.0625,   -0.0078125,
//! -                0.015625,  0.015625, 0.0,       0.0]


module poly_fir_filter
  #(
    parameter NB_OUTPUT  = 8, //! NB of output
    parameter NBF_OUTPUT = 7, //! NBF of output
    parameter NB_COEFF   = 8, //! NB of Coefficients
    parameter NBF_COEFF  = 7  //! NBF of Coefficients
  ) 
  (
    output signed [NB_OUTPUT-1:0] o_data ,   //! Output Sample
    input                         i_data ,   //! Input Sample
    input                         i_en   ,   //! Enable
    input                         i_valid,   //! Valid
    input                         i_rst  ,   //! Reset
    input                         clk        //! Clock
  );

  localparam NB_ADD     = NB_COEFF + 5;
  localparam NBF_ADD    = NBF_COEFF;
  localparam NBI_ADD    = NB_ADD - NBF_ADD;
  localparam NBI_OUTPUT = NB_OUTPUT - NBF_OUTPUT;
  localparam NB_SAT     = (NBI_ADD) - (NBI_OUTPUT);

  //! Internal Signals
  reg                  [1:0] counter             ; //! Counter
  reg                  [5:1] register            ; //! Vector for registers
  wire signed [NB_COEFF-1:0] coeff         [23:0]; //! Matrix for Coefficients
  wire signed [NB_COEFF-1:0] set_coeff [3:0][5:0]; //! Set of Coefficients

  //! Coefficients
  assign coeff [0] = 8'b0000_0000; assign coeff [1] = 8'b0000_0010;
  assign coeff [2] = 8'b0000_0010; assign coeff [3] = 8'b0000_0000;
  assign coeff [4] = 8'b1111_1000; assign coeff [5] = 8'b1111_0000;
  assign coeff [6] = 8'b1111_0000; assign coeff [7] = 8'b1111_1111;
  assign coeff [8] = 8'b0010_0001; assign coeff [9] = 8'b0100_1100;
  assign coeff[10] = 8'b0111_0001; assign coeff[11] = 8'b0111_1111;
  assign coeff[12] = 8'b0111_0001; assign coeff[13] = 8'b0100_1100;
  assign coeff[14] = 8'b0010_0001; assign coeff[15] = 8'b0000_0000;
  assign coeff[16] = 8'b1111_0000; assign coeff[17] = 8'b1111_0000;
  assign coeff[18] = 8'b1111_1000; assign coeff[19] = 8'b1111_1111;
  assign coeff[20] = 8'b0000_0010; assign coeff[21] = 8'b0000_0010;
  assign coeff[22] = 8'b0000_0000; assign coeff[23] = 8'b0000_0000;

  //! Set of coefficients
  generate
    genvar ptr1, ptr2;
    for(ptr1=0;ptr1<4;ptr1=ptr1+1) begin
      for (ptr2=0;ptr2<6;ptr2=ptr2+1) begin
        assign set_coeff[ptr1][ptr2] = coeff[ptr1+ptr2*4];
      end
    end    
  endgenerate

  //! Counter model;
  always @(posedge clk) begin:Counter
    if (i_rst == 1'b1) begin
      counter <= 2'b00;
    end
    else begin
      if (i_en) begin
        if (counter != 2'b00) begin
          if (counter == 2'b11) begin
            counter <= 2'b00;
          end
          else begin
            counter <= counter + 1'b1;
          end
        end
        else
          if (i_valid) begin
            counter <= counter + 1'b1;
        end
      end
    end
  end

  //! ShiftRegister model
  integer ptr3;
  integer ptr4;
  always @(posedge clk) begin:shiftRegister
    if (i_rst == 1'b1) begin
      for(ptr3=1;ptr3<6;ptr3=ptr3+1) begin:init
        register[ptr3] <= 1'b0;
      end
    end else begin
      if (counter == 2'b11 && i_en) begin
        for(ptr4=1;ptr4<6;ptr4=ptr4+1) begin:srmove
          if(ptr4==1)
            register[ptr4] <= i_data;
          else
            register[ptr4] <= register[ptr4-1];
         end   
      end
    end
  end

  //! Products
  reg signed [NB_COEFF-1:0] prod     [5:0]; //! Partial Products
  integer ptr;
  always @(*) begin
    for (ptr = 0; ptr < 6; ptr=ptr+1) begin
      if (ptr==0) 
        prod[ptr] =        (i_data) ? -set_coeff[counter][ptr]
                                    :  set_coeff[counter][ptr];
      else
        prod[ptr] = (register[ptr]) ? -set_coeff[counter][ptr]
                                    :  set_coeff[counter][ptr];
    end
  end

  //! Additions
  //integer ptr3;
  reg signed [NB_ADD-1:0] sum;
  always @(*) begin:accum
    sum = {NB_ADD{1'b0}};
    for(ptr3=0;ptr3<6;ptr3=ptr3+1) begin:adder 
      sum = sum + prod[ptr3];
    end
  end
  // Output
  assign o_data = ( ~|sum[NB_ADD-1 -: NB_SAT+1] || &sum[NB_ADD-1 -: NB_SAT+1]) ? sum[NB_ADD-(NB_SAT) - 1 -: NB_OUTPUT] :
                    (sum[NB_ADD-1]) ? {{1'b1},{NB_OUTPUT-1{1'b0}}} : {{1'b0},{NB_OUTPUT-1{1'b1}}};


endmodule
