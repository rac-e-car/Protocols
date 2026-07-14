module byte_ctrl
(
    input clk,
    input rst_n,
    input ena,
    input din_from_bit8,
    input cmd_ack_from_bit8,
    input [7:0] din_byte,
    input [2:0] cmd_in,
    output reg din,
    output reg [7:0] read_byte,
    output reg cmd_ack,
    output reg rx_ack,
    output reg read_valid,
    output reg [2:0] cmd_out
);

    reg [7:0] write_data;
    reg write_cycle_ena;


    //==========================================================
    //Declaring the states
    //==========================================================

    localparam [2:0]
    IDLE = 3'b000,
    START = 3'b001,
    WRITE = 3'b010,
    READ = 3'b011,
    STOP = 3'b100,
    WACK = 3'b101,
    RACK = 3'b110;

    localparam [2:0]
    CMD_START = 3'b000,
    CMD_WRITE = 3'b001,
    CMD_READ = 3'b010,
    CMD_STOP = 3'b011;
 
    reg [2:0] state, next_state;
    reg [2:0] ack_count_bit8;

    //==========================================================
    // ALWAYS block 1 -- STATE REGISTER
    // =========================================================

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            end else begin
                state <= next_state;
            end
        end

    //==========================================================
    //ALWAYS block 2 -- NEXT STATE LOGIC
    //==========================================================

    always @(*) begin
        
        next_state = state;

        case (state)

            IDLE: begin
                if (ena) begin

                    case(cmd_in)
                        CMD_START: next_state = START;
                        CMD_STOP: next_state = STOP;
                        CMD_WRITE: next_state = WRITE;
                        CMD_READ: next_state = READ;
                        default: next_state = IDLE;
                    endcase
                end
            end

            START: begin
                if(cmd_ack_from_bit8)
                    next_state = IDLE;
                end

            STOP: begin
                if(cmd_ack_from_bit8)
                    next_state = IDLE;
                end
            
            WRITE: begin
                if(cmd_ack)
                    next_state = WACK;
                end

            READ: begin
                if(cmd_ack)
                    next_state = RACK;
                end

            WACK: begin
                if(cmd_ack_from_bit8)
                    next_state = IDLE;
            end

            RACK: begin
                if(cmd_ack_from_bit8)
                    next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end

            endcase
        end

        //======================================================
        //ALWAYS BLOCK 3 -- OUTPUT LOGIC
        //======================================================

        always @(posedge clk or negedge rst_n) begin
            if(!rst_n) begin
                cmd_ack <= 0;
                din <= 1;
                ack_count_bit8 <= 0;
                read_valid <= 0;
                read_byte <= 0;
                write_cycle_ena <= 1;
                             
            end 

            else begin

                cmd_ack <= 0;
                read_valid <= 0;
                
                case (state)

                    IDLE: begin
                        din <= 1;
                        ack_count_bit8 <= 0;
                        write_cycle_ena <= 1;                                   
                    end

                    START: begin
                        cmd_out <= CMD_START;
                        din <= 0;
                        cmd_ack <= cmd_ack_from_bit8;
                    end

                    STOP: begin
                        cmd_out <= CMD_STOP;
                        din <= 1;
                        cmd_ack <= cmd_ack_from_bit8;
                    end

                    WRITE: begin
                        cmd_out <= CMD_WRITE;
                        // This makes sure write_data is stored with input byte for 1 cycle and is shifted properly, not re-written with same din_byte every cycle
                        if(write_cycle_ena) begin
                            write_data <= din_byte;
                            write_cycle_ena <= 0;                           
                        end

                        if(ack_count_bit8 <= 7) begin
                            if(cmd_ack_from_bit8) begin
                                din <= write_data[7];
                                write_data <= {write_data[6:0] , 1'b0};
                            
                                ack_count_bit8 <= ack_count_bit8 + 1;
                                cmd_ack <= (ack_count_bit8 == 7);
                            end
                        end
                    end
                                      
                    
                    READ: begin
                        cmd_out <= CMD_READ;

                        if(ack_count_bit8 <= 7) begin
                                                   
                            if(cmd_ack_from_bit8) begin
                                read_byte <= {read_byte [6:0], din_from_bit8};
                                ack_count_bit8 <= ack_count_bit8 + 1;
                                cmd_ack <= (ack_count_bit8 == 7);

                                // flagging the top module of byte_ctrl that 7 bits have been received and it can read the data
                        
                                if(ack_count_bit8 == 7) begin
                                    read_valid <= 1;                        
                                end
                            end
                        end
                    end

                    WACK: begin
                        cmd_out <= CMD_READ;

                        if(cmd_ack_from_bit8) begin
                        rx_ack <= din_from_bit8;
                        cmd_ack <= 1;
                        end
                    end

                    RACK: begin
                        cmd_out <= CMD_WRITE;
                        din <= 1'b0;
                        cmd_ack <= cmd_ack_from_bit8;
                    end
                        
                    default: begin
                        din <= 1;
                    end

                    endcase
                end
            end
        endmodule
