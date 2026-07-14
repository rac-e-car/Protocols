module bit8_ctrl
(
    input clk,                //clock of the board
    input rst_n,              //asynchronous
    input ena,                //bit is transferred only when enable is ON
    input din,                //the data after start
    input int_tick,           //the reduced clock pulse for I2C
    input [2:0] cmd,          //bit information (start/stop/data)
    output reg cmd_ack,       //acknowledgement from phase-D for a bit's completion
    output reg dout,          //Data from slave (read)
    output reg busy,          //denotes protocol's state
    output reg scl,           //serial clock
    output reg sda_out,       //data write by controller
    input sda_in,             //data from the slave
    output reg al             //arbitration lost - adv feature
);

//=======================================================
//Declaring the states
//=======================================================

localparam [2:0]
    IDLE = 3'b000,
    START = 3'b001,
    WRITE = 3'b011,
    READ = 3'b100,
    STOP = 3'b101;
    
localparam [2:0]
    CMD_START = 3'b000,
    CMD_WRITE = 3'b001,
    CMD_READ = 3'b010,
    CMD_STOP = 3'b011;

localparam [1:0]
    PH_A = 2'b00,
    PH_B = 2'b01,
    PH_C = 2'b10,
    PH_D = 2'b11;
    
    reg [2:0] state, next_state;
    reg [1:0] phase;

//=======================================================
// ALWAYS BLOCK 1 -- STATE REGISTER
//=======================================================

    always @(posedge clk or negedge rst_n) begin
            if(!rst_n) begin
                state <= IDLE;
            end else begin
                state <= next_state;
            end
        end
//=======================================================
// ALWAYS BLOCK 2 -- NEXT STATE LOGIC (Combinational)
//=======================================================

    always @(*) begin

        next_state = state;

        case (state)

            IDLE: begin

                if(ena) begin

                    case(cmd)
                        CMD_START: next_state = START;
                        CMD_STOP: next_state = STOP;
                        CMD_WRITE: next_state = WRITE;
                        CMD_READ: next_state = READ;
                        default: next_state = IDLE;                 
                    endcase
                end
            end


            START: begin
                if(int_tick && cmd_ack ==1)
                    next_state = IDLE;
            end

            WRITE: begin
               if(int_tick && cmd_ack ==1)
                    next_state = IDLE;
            end

            READ: begin
                if(int_tick && cmd_ack ==1)
                    next_state = IDLE;
            end

            STOP: begin
                if(int_tick && cmd_ack ==1)
                    next_state = IDLE;            
            end
        endcase
    end

//========================================================
//ALWAYS BLOCK 3 -- OUTPUT LOGIC
//========================================================

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            scl <= 1;
            sda_out <= 1;
            cmd_ack <= 0;
            dout <= 0;
            busy <= 0;
            al <= 0;
            phase <= PH_A;
        end

        else begin
           cmd_ack <= 0;        //pulse only at PH_D, by-default --> 0
          
        if (int_tick) begin

            phase <= phase + 1;

        case (state)

            IDLE: begin

                 busy <= 0;
                 sda_out <= 1;
                 scl <= 1;
                 phase <= PH_A;

             end

             START: begin

                 busy <= 1;
            
                case (phase)

                    PH_A: begin scl <= 1; sda_out <= 1; end
                    PH_B: begin scl <= 1; sda_out <= 1; end
                    PH_C: begin scl <= 1; sda_out <= 0; end
                    PH_D: begin scl <= 0; sda_out <= 0; 
                                busy <= 0; cmd_ack <= 1; end
                //4: scl <= 0;
                  // sda <= 0;
                
                endcase
            end

            STOP: begin

                busy <= 1;
            
                case (phase)

                    PH_A: begin scl <= 0; sda_out <= 0; end
                    PH_B: begin scl <= 1; sda_out <= 0; end
                    PH_C: begin scl <= 1; sda_out <= 1; end
                    PH_D: begin scl <= 1; sda_out <= 1;  
                                busy <= 0; cmd_ack <= 1; end
                //4: scl <= 0;
                  // sda <= 0;
                
                endcase
            end

             // =======================================================
                // WRITE
                // Master drives din onto SDA, slave samples at Phase C
                //
                // Phase A : SCL low,  SDA = din  (master sets data)
                // Phase B : SCL high, SDA = din  (SCL rises)
                // Phase C : SCL high, SDA = din  (slave samples here)
                // Phase D : SCL low,  SDA = din  (SCL falls)
                // ====================================================
            
            WRITE: begin

                busy <= 1;
            
                case (phase)

                    PH_A: begin scl <= 0; sda_out <= din; end
                    PH_B: begin scl <= 1; sda_out <= din; end
                    PH_C: begin scl <= 1; sda_out <= din; end
                    PH_D: begin scl <= 0; sda_out <= din;  
                                cmd_ack <= 1; end
                //4: scl <= 0;
                  // sda <= 0;
                
                endcase
            end

             // =======================================================
                // READ
                // Master releases SDA, slave drives it, master samples at Phase C
                //
                // Phase A : SCL low,  SDA released (1 = high-Z, slave takes over)
                // Phase B : SCL high, SDA released
                // Phase C : SCL high, sample SDA → dout
                // Phase D : SCL low
                // ====================================================

            READ: begin

                busy <= 1;
            
                case (phase)

                    PH_A: begin scl <= 0; sda_out <= 1; end
                    PH_B: begin scl <= 1; sda_out <= 1; end
                    PH_C: begin scl <= 1; dout<=sda_in; end
                    PH_D: begin scl <= 0;  
                                cmd_ack <= 1; end
               endcase
            end

            /*R_START: begin
            
                case (phase)

                2'd0: scl <= 1;
                   sda <= 1;
                
                2'd1: scl <= 1;
                   sda <= 1;

                2'd2: scl <= 1;
                   sda <= 0;
                
                2'd3: scl <= 1;
                   sda <= 0;                

               endcase
            end*/
           default: begin
                    scl <= 1;
                    sda_out <= 1;
                end
       endcase
   end
   end
   end
   endmodule











