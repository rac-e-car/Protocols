module spi_slave #(parameter DIV = 50
                   parameter DATA_WIDTH = 8);

                   (
                            
                     ( input clk, rst_n, mosi, cs, sclk,
                       output miso, done,
                       input {DATA_WIDTH-1:0] tx_data,
                       output [DATA_WIDTH-1:0] rx_data );


                   reg [DATA_WIDTH-1:0] tx_shift_register;
                   reg [DATA_WIDTH-1:0] rx_shift_register;

                   reg [$clog2(DATA_WIDTH):0] counter;
                   
                 //===============================
                 //CLK EDGE DETECTION
                 //===============================
                 
                 reg sclk_prev;

                 wire rising_edge, falling_edge;

                 assign rising_edge = (sclk_pev == 0 && sclk == 1);
                 assign falling_edge = (sclk_prev == 1 && sclk == 0);

                 //===============================
                 //STATE DECLARATIOn
                 //===============================
                 
                 localparam [1:0]
                 IDLE: 2'b00;
                 TRANSFER: 2'b01;
                 DONE; 2'b10;

                 reg [1:0] current_state, next_state;

                 //================================
                 //ALWAYS BLOCK 1 -- state register
                 //================================

                 always@(posedge clk or negedge rst_n) begin
                    
                     if(!rst_n) 
                         current_state <= IDLE;
                         
                     else
                         current_state <= next_state;
                     end

                 //==================================
                 //ALWAYS BLOCK 2 -- next state logic
                 //==================================

                 always @(*) begin

                     next_state = current_state;

                     case(current_state)
                         IDLE: begin

                             if(cs == 0 )
                                 next_state = TRANSFER;
                         end

                         TRANSFER: begin

                             if(count == DATA_WIDTH)
                                 next_state = DONE;
                         end

                         DONE: begin

                             if(cs == 1)
                                 next_state = IDLE;
                         end

                         default:
                                next_state = IDLE;
                        endcase
                    end

                    //===============================
                    //ALWAYS BLOCK 3 -- output logic
                    //===============================
                   
                  always @(posedge clk or negedge rst_n) begin

                      if(!rst_n) begin

                          miso <= 0;
                          rx_data <= 0;

                          tx_shift_register <= 0;
                          rx_shift_register <= 0;

                          counter <= 0;
                          done <= 0;

                          sclk_prev <= 0;

                      end else begin

                          sclk_prev <= sclk;

                          case (current_state)

                              IDLE: begin

                                  done <= 0;
                                  counter <= 0;

                                  tx_shift_register <= tx_data;

                              end

                              TRANSFER: begin

                                  //===================
                                  //falling edge tansfer
                                  //===================

                                  if(falling_edge) begin
                                      miso <= tx_shift_register[DATA_WIDTH-1];
                                      tx_shift_register <= { [tx_shift_register-2:0],1'b0 };
                                  end

                                  //===================
                                  //rising edge sampling
                                  //===================

                                  if(rising_edge) begin
                                      rx_shift_register <= { [rx_shift_register-2:0],mosi };

                                      count <= count+1;
                                  end
                              end

                              DONE: begin

                                  done <= 1;
                                  rx_shift_register <= rx_data;

                              end
                          endcase
                      end
                  end
                  endmodule



                                  










                          
                                                    




                             


                     



