
module registerFile
#(
    parameter NB_ADDR_MEM = 15
)(
    output            [31:0] o_gpi,
    output                   o_rst,
    output                   o_enbTx,
    output                   o_enbRx,
    output             [1:0] o_phase_sel,

    output                   o_run_log,
    output                   o_read_log,
    output [NB_ADDR_MEM-1:0] o_addr_log_to_mem,
    
    input             [31:0] i_gpo,
    input             [31:0] i_data_log_from_mem,
    input                    i_mem_full,

    input             [63:0] i_ber_samp_I,
    input             [63:0] i_ber_samp_Q,
    input             [63:0] i_ber_error_I,
    input             [63:0] i_ber_error_Q,    

    input                    i_rst,
    input                    clk
);

//  COMANDOS DEL UP
    localparam RESET       = 8'd0;     // Resetear el sistema
    localparam EN_TX       = 8'd1;     // Habilitar el Tx
    localparam EN_RX       = 8'd2;     // Habilitar el Rx
    localparam PH_SEL      = 8'd3;     // Selección de fase del filtro
    localparam RUN_MEM     = 8'd4;     // Comenzar el logueo de datos en memoria
    localparam READ_MEM    = 8'd5;     // Habilitar la lectura de memoria
    localparam ADDR_MEM    = 8'd6;     // Leer memoria en la direccion indicada
    localparam BER_S_I     = 8'd7;     // Leer cantidad de muestras de la BER del canal I
    localparam BER_S_Q     = 8'd8;     // Leer cantidad de muestras de la BER del canal Q
    localparam BER_E_I     = 8'd9;     // Leer cantidad de errores de la BER del canal I
    localparam BER_E_Q     = 8'd10;    // Leer cantidad de errores de la BER del canal Q
    localparam BER_H       = 8'd11;    // Leer parte alta del ultimo valor de BER
    localparam IS_MEM_FULL = 8'd12;

    reg            [31:0] gpi;
    reg                   rst;
    reg                   enbTx;
    reg                   enbRx;
    reg             [1:0] phase_sel;
    reg                   run_log;       // Inicia la captura de datos en memoria con un flanco positivo
    reg                   read_log;      // Habilita la lectura de memoria cuando está en alto
    reg [NB_ADDR_MEM-1:0] addr_log_to_mem;

    reg                   prev_enable;
    reg             [1:0] BER_cnt;
    reg           [127:0] BER_buffer;

    reg             [1:0] cont_read_log;

    wire            [7:0] gpo_command;
    wire                  gpo_enable;
    wire           [22:0] gpo_data;

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
            gpi             <= {32{1'b0}};
            rst             <= 1'b0;
            enbTx           <= 1'b0;
            enbRx           <= 1'b0;
            phase_sel       <= 2'b00;
            run_log         <= 1'b0;
            read_log        <= 1'b0;
            addr_log_to_mem <= {NB_ADDR_MEM{1'b0}};
            prev_enable     <= 1'b0;
            cont_read_log   <= 2'b00;
        end else begin
            if((gpo_enable == 1'b1) && (prev_enable == 1'b0)) begin
                case(gpo_command)
                    RESET:     rst             <= gpo_data[0];
                    EN_TX:     enbTx           <= gpo_data[0];
                    EN_RX:     enbRx           <= gpo_data[0];
                    PH_SEL:    phase_sel       <= gpo_data[1:0];
                    RUN_MEM:   begin
                               run_log         <= 1'b1;
                               read_log        <= 1'b0;
                    end
                    READ_MEM:   begin
                        if( i_mem_full ) begin
                            read_log        <= 1'b1;
                            cont_read_log   <= 2'b10;
                            addr_log_to_mem <= gpo_data[NB_ADDR_MEM-1:0];
                        end 
                    end

                    BER_S_I :
                        begin
                        gpi <= i_ber_samp_I[31:0];
                        BER_buffer <= i_ber_samp_I;
                        end

                    BER_S_Q :
                        begin
                        gpi <= i_ber_samp_Q[31:0];
                        BER_buffer <= i_ber_samp_Q;
                        end

                    BER_E_I :
                        begin
                        gpi <= i_ber_error_I[31:0];
                        BER_buffer <= i_ber_error_I;
                        end

                    BER_E_Q :
                        begin
                        gpi <= i_ber_error_Q[31:0];
                        BER_buffer <= i_ber_error_Q;
                        end
                        
                    BER_H :
                        begin
                        gpi <= BER_buffer[63:32];  
                        end

                    IS_MEM_FULL:  gpi <= i_mem_full;

                    // default:
                endcase
            end
            else if(cont_read_log > 0) begin
                if (cont_read_log == 2'b10) begin
                    read_log <= 0;
                end
                else if (cont_read_log == 2'b01) begin
                    gpi      <= i_data_log_from_mem;
                end
                cont_read_log <= cont_read_log - 1'b1;
            end
            else if(run_log) begin
                run_log <= 0;
            end
            
            prev_enable <= gpo_enable;
        end
    end



endmodule