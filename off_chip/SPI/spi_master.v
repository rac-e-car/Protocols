module spi_master #(parameter DIV = 50,
                    parameter DATA_WIDTH = 8) 
                (
                    input clk, rst_n, start, miso,
                    input [DATA_WIDTH-1:0] tx_data,
                    output reg done, mosi, cs, sclk,
                    output reg [DATA_WIDTH-1:0] rx_data
                );

                reg [DATA_WIDTH-1:0] rx_shift_register, tx_shift_register;
                reg [$clog2(DATA_WIDTH):0] count; 
                wire sclk_int;

                //================================
                //instantiating clk div ckt
                //================================

                clk_div #(DIV) 
                        inst_div_master (
                                 .clk(clk), .rst(~rst_n), .spi_tick(sclk_int)
                                 );

                //=================================
                //CLK EDGE DETECTION
                //=================================
                reg sclk_prev;

                wire falling_edge, rising_edge;

                assign rising_edge = (sclk_prev == 0 && sclk_int == 1);
                assign falling_edge = (sclk_prev == 1 && sclk_int == 0);

                //=================================
                //STATE DECLARATION
                //=================================


                localparam [1:0]
                IDLE = 2'b00,
                LOAD = 2'b01,
                TRANSFER = 2'b10,
                DONE = 2'b11;

                reg [1:0] current_state, next_state;

                //==================================
                //ALWAYS BLOCK 1 STATE REGISTER
                //==================================

        always @(posedge clk or negedge rst_n) begin
                if(!rst_n)
                    current_state <= IDLE;
                else
                    current_state <= next_state;

        end
                //==================================
                //ALWAYS BLOCK 2 NEXT STATE LOGIC
                //==================================

        always @(*) begin

                 next_state = current_state;

                case(current_state)
                    IDLE: begin
                        
                        if(start)
                        next_state = LOAD;
                        end

                    LOAD: begin
                        
                        next_state = TRANSFER;
                        end

                    TRANSFER: begin

                        if(count == DATA_WIDTH-1)
                        next_state = DONE;          
                        end

                    DONE: begin
                      
                        next_state = IDLE;
                        end

                    default: next_state = IDLE;
                endcase
            end

                //==================================
                //ALWAYS BLOCK 3 OUTPUT LOGIC
                //==================================


        always @(posedge clk or negedge rst_n) begin

            if(!rst_n) begin
                        done <= 0;
                        mosi <= 0;
                        cs <= 0;
                        sclk <= 0;
                        rx_data <= 0;
                        
                        tx_shift_register <= 0;
                        rx_shift_register <= 0;

                        count<=0;
                        sclk_prev<=0;
                    end
                    else begin

                    sclk_prev <= sclk_int;

                case(current_state)
                  
                    IDLE: begin
                        
                        done <= 0;
                        sclk <= 0;
                        cs <= 1;
                        
                        count <= 0;
                        sclk_prev <= 0;
                    end

                    LOAD: begin

                        cs <= 0;
                        tx_shift_register <= tx_data;
                        rx_shift_register <= 0;
                        count <= 0;

                        mosi <= tx_data[DATA_WIDTH-1];

                        end

                    TRANSFER: begin

                        cs <= 0;
                        sclk <= sclk_int;

                        //==================================
                        //TRANSFER AT NEGEDGE
                        //==================================

                        if (falling_edge) begin

                        mosi <= tx_shift_register[DATA_WIDTH-1];

                        tx_shift_register <= { tx_shift_register[DATA_WIDTH-2:0], 1'b0 };
                    end

                        if (rising_edge) begin
                        //==================================
                        //SAMPLING AT POSEDGE
                        //==================================

                            rx_shift_register <= {rx_shift_register[DATA_WIDTH-2:0], miso};

                            count <= count +1;
                            
                        end
                    end

                      DONE: begin
                            
                        done = 1;
                        cs = 1;
                        sclk <= 0;

                        rx_data <= rx_shift_register;
                         end
                     endcase
                 end
             end
             endmodule                            

                             
                         

                

