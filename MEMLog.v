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
    .BRAM_ADDR_WIDTH(15),  // 32K x 32 bits
    .BRAM_DATA_WIDTH(32)
) 
(
    .clk          (clk),
    .addr         (i_addr_log_to_mem),
    .chipselect_n (bram_cs),
    .write_n      (bram_rw),
    .read_n       (~bram_rw),
    .bram_data_in (i_filter_data),
    .bram_data_out(bram_data_out)
)

reg mem_full;
reg data_log_from_mem;
wire bram_data_out;
wire bram_cs;
wire bram_rw;   // 0 -> Write, 1 -> Read

assign o_mem_full = mem_full;
assign o_data_log_from_mem = data_log_from_mem;
assign bram_cs = 1'b0;

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
                if (addr_count == {BRAM_ADDR_WIDTH{1'b1}} )     // si se llena la memoria
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
            mem_full = 0;
            data_log_from_mem = 32'b0;
        end 
        RUN: 
        begin
            mem_full = 0;
            data_log_from_mem = 32'b0;
        end 
        FULL: 
        begin
            mem_full = 1;
            data_log_from_mem = 32'b0;
        end 
        READ: 
        begin
            mem_full = 1;
            data_log_from_mem = bram_data_out;
        end 
    endcase

    end

    // Internal signals 
    always @(posedge clk) begin
        if(i_rst) begin
            addr_count <= {BRAM_ADDR_WIDTH{1'b0}};
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
    end


endmodule


