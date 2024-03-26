module MEMLog
#(
    parameter BRAM_ADDR_WIDTH = 15,
    parameter BRAM_DATA_WIDTH = 16
)
(
    input                          clk,
    input                          i_rst,
     
    input  [BRAM_DATA_WIDTH-1:0]   i_filter_data,  // muestras de los canales I ([15:8]) y Q ([7:0])
    input                          i_run_log,
    input                          i_read_log,
    input  [BRAM_ADDR_WIDTH-1:0]   i_addr_log_to_mem,  // dir de memoria
  
    output                         o_mem_full,
    output [2*BRAM_DATA_WIDTH-1:0] o_data_log_from_mem
);
    localparam IDLE = 2'd0; 
    localparam RUN  = 2'd1;
    localparam FULL = 2'd2;
    localparam READ = 2'd3;

    reg [1:0] state, next_state;
    reg [BRAM_ADDR_WIDTH - 1 : 0] addr_count;

    reg                        mem_full;
    wire [BRAM_DATA_WIDTH-1:0] bram_data_out_a;
    wire [BRAM_DATA_WIDTH-1:0] bram_data_out_b;
    reg                        bram_rw;     // 0 -> Write, 1 -> Read
    reg  [BRAM_ADDR_WIDTH-1:0] addr_mem;    // selecciona de donde viene el direccionamiento de la bram
    wire [BRAM_ADDR_WIDTH-1:0] addr_mem_bram;
    reg                        bram_cs_a;
    reg                        bram_cs_b;

bram
#(
    .BRAM_ADDR_WIDTH(BRAM_ADDR_WIDTH),  // 32K x 16 bits
    .BRAM_DATA_WIDTH(BRAM_DATA_WIDTH)
) 
u_bram_a
(
    .clk          (clk),
    .addr         (addr_mem_bram),
    .chipselect_n (bram_cs_a),      
    .write_n      (bram_rw),
    .read_n       (~bram_rw),
    .bram_data_in (i_filter_data),
    .bram_data_out(bram_data_out_a)
);

bram
#(
    .BRAM_ADDR_WIDTH(BRAM_ADDR_WIDTH),  // 32K x 16 bits
    .BRAM_DATA_WIDTH(BRAM_DATA_WIDTH)
) 
u_bram_b
(
    .clk          (clk),
    .addr         (addr_mem_bram),
    .chipselect_n (bram_cs_b),
    .write_n      (bram_rw),
    .read_n       (~bram_rw),
    .bram_data_in (i_filter_data),
    .bram_data_out(bram_data_out_b)
);

assign o_mem_full = mem_full;
assign addr_mem_bram = addr_mem;
assign o_data_log_from_mem = {bram_data_out_b, bram_data_out_a};

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

    // Output signals
    always @(*) begin
    case(state)
        IDLE:
        begin
            addr_mem = 0;
            mem_full = 0;
            bram_rw  = 0;
        end 
        RUN: 
        begin
            addr_mem = addr_count;
            mem_full = 0;
            bram_rw  = 0;
        end 
        FULL: 
        begin
            addr_mem = addr_count;
            mem_full = 1;
            bram_rw  = 1;
        end 
        READ: 
        begin
            addr_mem = i_addr_log_to_mem;
            mem_full = 1;
            bram_rw  = 1;
        end 
    endcase

    end

    // Internal signals 
    always @(posedge clk) begin
        if(i_rst) begin
            addr_count <= {BRAM_ADDR_WIDTH{1'b0}};
            bram_cs_a    <= 1'b0;
            bram_cs_b    <= 1'b1;
        end else begin
            if (state == RUN) begin
                bram_cs_a <= ~(bram_cs_a);
                bram_cs_b <= ~(bram_cs_b);
                if (!bram_cs_a) begin
                    addr_count <= addr_count;
                end
                else
                begin
                    if (addr_count == {BRAM_ADDR_WIDTH{1'b1}}) begin
                        addr_count <= {BRAM_ADDR_WIDTH{1'b0}};                        
                    end
                    else begin
                        addr_count <= addr_count + 1;
                    end
                end
            end
            else if (state == READ) begin
                addr_count <= {BRAM_ADDR_WIDTH{1'b0}};
                bram_cs_a <= 1'b0;
                bram_cs_b <= 1'b0;
            end
            else begin
                addr_count <= {BRAM_ADDR_WIDTH{1'b0}};
                bram_cs_a <= 1'b0;
                bram_cs_b <= 1'b1;
            end
        end
    end


endmodule


