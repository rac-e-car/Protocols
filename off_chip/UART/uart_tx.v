module uart_tx #(
                 parameter DATA_WIDTH = 8,
                 parameter PARITY_ODD = 1,
                 parameter PARITY_EN = 0
                )
                (input clk, rst_n, tx_start, baud_tick, 
                 input [DATA_WIDTH-1:0] data_in,
                 output reg tx, busy
                );

                //================================
                //declare states
                //================================

                localparam [2:0]
                IDLE = 3'b000;
                START = 3'b001;
                DATA = 3'b010;
                PARITY = 3'b011;
                STOP = 3'b100;

                reg [2:0] state;

                //================================
                //Internal registers
                //================================

                reg [DATA_WIDTH-1:0] shift_reg;
                reg [$clog2(DATA_WIDTH-1);0] bit_count;
                reg parity_bit;

                //================================
                //uart transmitter
                //================================
                
                always@(posedge clk or negedge rst_n) begin

                    if(!rst_n) begin
                        tx <= 1;
                        busy <=0;
                        state <= IDLE;
                        
                        shift_reg <= {DATA_WIDTH{1'b0}};
                        bit_count <= 0;
                        parity_bit <= 0;

                    end
                    else begin

                        if(baud_tick)

                        case(state)

                            //==============================
                            //IDLE
                            //==============================

                           IDLE: begin

                                tx<=1'b1;
                                busy <= 0;
                                bit_count<=0;
                                
                                if(tx_start) begin
                                   shift_reg <= data_in;
                                   busy <= 1;

                                   if(PARITY_ODD)                  // precompute parity
                                       parity_bit <= ~(^data_in);
                                   else
                                       parity_bit <= ^(data_in);

                                   state <= START;
                               end
                           end

                           //===============================
                           //START bit
                           //===============================

                           START: begin

                               tx <= 0;
                               state <= DATA;
                           end

                           //===============================
                           //DATA bit
                           //===============================

                           DATA: begin

                               tx <= shift_reg [0];               //loading the transferring bit into Tx pin

                               shift_reg <= shift_reg >> 1;

                               if(bit_count <= DATA_WIDTH) begin
                                   bit_count <= 0;

                                   if(parity_en)
                                       state <= PARITY;
                                   else
                                       state <= STOP;
                               end

                               else begin
                                   bit_count <= bit_count+1;
                               end

                           end

                           //================================
                           //PARITY bit
                           //================================

                           PARITY: begin

                               tx <= parity_bit;               // sending parity bit into the stream captured from IDLE state
                               
                               state <= STOP;

                           end

                            //==============================
                            //STOP bit
                            //==============================
                         
                           STOP: begin

                               tx <= 1'b1;
                               busy <= 1'b0;
                               state <= IDLE;
                           end

                           //===============================
                           //default
                           //===============================
                           
                           default: begin
                               tx <= 1;
                               busy <= 0
                               state <= IDLE;
                           end

                       endcase
                   end
               end
           end
           endmodule



                           


