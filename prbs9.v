`timescale 1ns/1ps
//! @title PRBS9
//! @file prbs9.v

//! - Pseudorandom binary sequence 9.


module prbs9
  #(
    parameter SEED = 9'h1AA //! PRBS Seed
  )
  (
    output  o_data   , //! Output Value
    input   i_valid  , //! Valid
    input   i_en     , //! Enable
    input   i_rst    , //! Reset
    input   clk        //! Clock
  );

  //! Internal Signals
  reg  [8:0] register; //! ShiftRegister

  //! ShiftRegister model
  always @(posedge clk) begin : ShiftRegister
    if(i_rst) begin
      register <= SEED;
    end
    else begin
      if (i_en && i_valid) begin
          register <= {register[7:0], register[8]^register[4]};
      end
      else begin
        register <= register;
      end
    end
  end

  //! Output assignment
  assign o_data = register[8];

endmodule
