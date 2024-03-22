`timescale 1ns/1ps
//! @title Control
//! @file control.v

//! - Frequency control for the system modules.


module control
  #(
    parameter N = 4 //! PRBS Seed
  )
  (
    output  o_valid, //! Output valid
    input   i_rst  , //! Reset
    input   clk      //! Clock
  );

  //! Local parameters
  localparam NB_COUNTER = $clog2(N);

  //! Internal Signals
  reg  [NB_COUNTER-1:0]     counter; //! Counter
  reg                   inter_valid; //! Internal valid

  //! ShiftRegister model
  always @(posedge clk) begin : counter_calc
    if(i_rst) begin
      counter <= {NB_COUNTER{1'b0}};
    end
    else begin
      if (counter == (N-1)) begin
        counter <= {NB_COUNTER{1'b0}};
      end
      else begin
        counter <= counter + 1'b1;
      end
    end
  end

  always @(posedge clk) begin : inter_valid_calc
    if(i_rst) begin
      inter_valid <= 1'b0;
    end else begin
      if (counter == (N-1)) begin
        inter_valid <= 1'b1;
      end
      else begin
        inter_valid <= 1'b0;
      end
    end
  end

  //! Output assignment
  assign o_valid = inter_valid;

endmodule
