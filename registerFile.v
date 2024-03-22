
module registerFile
#(
    parameter NB_ADD_MEM = 14
)(
    output [31:0] o_gpi,
    output        o_rst,
    output        o_enbTx,
    output        o_enbRx,
    output  [1:0] o_phase_sel,

    output        o_run_log,
    output        o_read_log,
    output [14:0] o_addr_log_to_mem,
    
    input  [31:0] i_gpo,
    input  [31:0] i_data_log_from_mem,
    input         i_mem_full,

    input  [63:0] i_ber_samp_I ,
    input  [63:0] i_ber_samp_Q ,
    input  [63:0] i_ber_error_I,
    input  [63:0] i_ber_error_Q,    

    input         i_rst,
    input         clk
);
//  COMANDOS DEL UP
    localparam RESET    = 4'd0;   
    localparam EN_TX    = 4'd1;   
    localparam EN_RX    = 4'd2;   
    localparam PH_SEL   = 4'd3;
    localparam RUN_MEM  = 4'd4;
    localparam READ_MEM = 4'd5;
    localparam ADDR_MEM = 4'd6;

    reg           [31:0] gpi;
    reg                  rst;
    reg                  enbTx;
    reg                  enbRx;
    reg            [1:0] phase_sel;
    reg                  run_log;
    reg                  read_log;
    reg [NB_ADD_MEM-1:0] addr_log_to_mem;

    reg                  prev_enable;
    reg                  BER_flag;
    reg            [1:0] BER_cnt;
    reg          [127:0] BER_buffer;

    wire           [7:0] gpo_command;
    wire                 gpo_enable;
    wire          [22:0] gpo_data;

    assign gpo_command = i_gpo[31:24];
    assign gpo_enable  = i_gpo[23];
    assign gpo_data    = i_gpo[22:0];

    assign o_gpi              = gpi;
    assign o_rst              = rst;
    assign o_enbTx            = enbTx;
    assign o_enbRx            = enbRx;
    assign o_phase_sel        = phase_sel;
    assign o_run_log          = run_log;
    assign o_read_log         = read_log;
    assign o_addr_log_to_mem  = addr_log_to_mem;

    always @(posedge clk) begin
        if(i_rst) begin
            // gpo             <= 32'b0;
            rst             <= 1'b0;
            enbTx           <= 1'b0;
            enbRx           <= 1'b0;
            phase_sel       <= 2'b0;
            run_log         <= 1'b0;
            read_log        <= 1'b0;
            addr_log_to_mem <= {NB_ADD_MEM{1'b0}};
            prev_enable     <= 1'b0;
            BER_flag        <= 4'b0;
        end else begin
            if((gpo_enable == 1'b1) && (prev_enable == 1'b0)) begin
                case(gpo_command)
                    RESET:     rst             <= gpo_data[0];
                    EN_TX:     enbTx           <= gpo_data[0];
                    EN_RX:     enbRx           <= gpo_data[0];
                    PH_SEL:    phase_sel       <= gpo_data[1:0];
                    RUN_MEM:   run_log         <= 1'b1;
                               read_log        <= 1'b0;
                    READ_MEM:   begin
                        if( !i_mem_full ) begin
                            read_log        <= 1'b1;
                            // run_log         <= 1'b0;
                            addr_log_to_mem <= gpo_data[13:0];
                        end 
                    end

                    BER_S_I :
                        begin
                        gpi <= i_ber_samp_I[31:0];
                        ber_buffer <= i_ber_samp_I;
                        end

                    BER_S_Q :
                        begin
                        gpi <= i_ber_samp_Q[31:0];
                        ber_buffer <= i_ber_samp_Q;
                        end

                    BER_E_I :
                        begin
                        gpi <= i_ber_error_I[31:0];
                        ber_buffer <= i_ber_error_I;
                        end

                    BER_E_Q :
                        begin
                        gpi <= i_ber_error_Q[31:0];
                        ber_buffer <= i_ber_error_Q;
                        end
                        
                    BER_HIGH :
                        begin
                        gpi <= ber_buffer[63:32];  
                        end

                    IS_MEM_FULL:  gpi <= i_mem_full;

                    // default:
                endcase
            end
            else if(read_log)
                gpi <= i_data_log_from_mem;
            else if(run_log) begin
                run_log <= 0;
            end
            
            prev_enable <= gpo_enable;
        end
    end



endmodule