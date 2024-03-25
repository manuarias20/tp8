module MEMLog
#(
    parameter NB_ADD_MEM      = 14,
    parameter BRAM_ADDR_WIDTH = 15,
    parameter BRAM_DATA_WIDTH = 32
)
(
    input clk,
    input i_rst,
  
    input i_filter_data,
    input i_run_log,
    input i_read_log,
    input [NB_ADD_MEM-1:0] i_addr_log_to_mem,

    output        o_mem_full,
    output [31:0] o_data_log_from_mem
);
    localparam IDLE = 2'd0; 
    localparam RUN  = 2'd1;
    localparam FULL = 2'd2;
    localparam READ = 2'd3;

    reg state, next_state;
    
    reg [BRAM_ADDR_WIDTH - 1 : 0] addr_count;

bram
u_bram
#(
    .BRAM_ADDR_WIDTH(15),
    .BRAM_DATA_WIDTH(32)
) 
(
    .clk(clk),
    .addr(i_addr_log_to_mem),
    .chipselect_n(),
    .write_n(),
    .read_n(),
    .bram_data_in(i_filter_data),
    .bram_data_out(o_data_log_from_mem)
)


    /////////////////////////////////////////////////////////////
    // State Machine

    //! State machine next state model
    always @(posedge clk) begin : state_calc
        if(i_rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin : next_state_calc
        case(state)
            IDLE:
            begin
                if (i_run_log) 
                    next_state = RUN;
                else 
                    next_state = state;
            end
            RUN:
            begin
                if (addr_count == {BRAM_ADDR_WIDTH{1'b1}} ) 
                    next_state = FULL;
                else
                    next_state = state;
            end
            FULL:
            begin
                if ( i_read_log ) 
                    next_state = READ;
                else
                    next_state = state;
            end
            READ:
            begin
                if ( i_read_log ) 
                    next_state = READ;
                else
                    next_state = state;
            end
            READ:
            begin
                if (i_run_log) 
                    next_state = RUN;
                else if(i_rst)
                    next_state = IDLE;
                else
                    next_state = state;
            end
            default:
            begin
                next_state = IDLE;
            end
        endcase // state
    end

    /////////////////////////////////////////////////////////////


    // Output
    always @(posedge clk) begin
    case(state)
        IDLE:
        begin
            
        end        RUN: 
        FULL: 
        READ: 
    endcase

    end

    // Internal signals 
    always @(posedge clk) begin : proc_inter_ber_zero
    if(i_rst) begin
        addr_count <= 1'b0;
    end else begin
        if (state == RUN) begin
        if (addr_count == {BRAM_ADDR_WIDTH{1'b1}}) begin
            addr_count <= 0;
        end
        else begin
            addr_count <= addr_count + 1;
        end
        end
        else begin
            addr_count <= addr_count;
        end
    end


endmodule


