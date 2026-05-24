module receiver_tx #(
                     parameter DATA_WIDTH = 8;
                     parameter PARITY_ODD = 1;
                     parameter PARITY_EN = 0;
                    );
                    (input clk, rst_n, baud_tick, rx,
                     output reg [DATA_WIDTH-1:0] data_out,
                     output reg data_valid, busy, parity_error, stop_error);

                 //=========================
                 //Declare STATES
                 //=========================
                 
                 localparam [3:0]
                 IDLE: 3'b000;
                 START: 3'b001;
                 DATA: 3'b010;
                 PARITY: 3'b011;
                 STOP: 3'b100;

                 reg [2:0] state;

                 //=========================
                 //Internal registers
                 //=========================

                 reg [DATA_WIDTH-1:0] shift_reg;
                 reg [$clog2(DATA_WIDTH);0] bit_count;
                 reg parity_calc;

                 //=========================
                 //UART Receiver
                 //=========================

                 always @(posedge  clk or negedge reset_n) begin
                     if(!rst_n) begin
                         data_out <= {DATA_WIDTH {1'b0}};
                         data_valid <=0;
                         busy <= 0;
                         parity_error <= 0;
                         stop_error <= 0;

                         shift_reg <= {DATA_WIDTH {1'b0}};
                         bit_count <= 0;
                         parity_calc <= 0;
                     end
                     else begin

                         data_valid <= 0;               //to notify another module that data byte is started the receiving process

                         if(baud_tick) begin

                           case(state)

                               //=========================
                               //IDLE
                               //=========================

                               IDLE: begin

                                    rx <= 1;
                                    busy <= 0;
                                    bit_count <= 0;

                                    if(rx == 0) begin
                                        busy <= 1'b1;
                                        state <= START;
                                    end
                                end

                                //========================
                                //START
                                //========================

                                START: begin
                                    if(rx<=0)           // confirm start bit still low
                                        state <= DATA;
                                    else
                                        state <= IDLE;
                                end

                                //========================
                                //DATA
                                //========================

                                DATA: begin
                                    shift_reg <= {rx,shift_reg(DATA_WIDTH-1:1)};

                                    if(bit_count <= DATA_WIDTH) begin
                                        bit_count <= 0;

                                        if(PARITY_ODD)
                                            parity_calc <= ~(^{rx,shift_reg(DATA_WIDTH-1:1);
                                        else
                                            parity_calc <= (^{rx,shift_reg(DATA_WIDTH-1:1);

                                        if(PARITY_EN)
                                            state <= PARITY;
                                        else
                                            state <= STOP;
                                    
                                    end else begin

                                        bit_count <= bit_count+1;
                                    end
                                end

                                //=========================
                                //PARITY
                                //=========================

                                PARITY: begin
                                    if(rx != parity_calc)
                                        parity_error <= 1'b1;
                                    state <= STOP;
                                end

                                //=========================
                                //STOP
                                //=========================
                                
                                STOP: begin
                                    if (rx <= 1)
                                        stop_error <= 1;

                                    data_out <= shift_reg;
                                    busy <= 0;
                                    data_valid <= 1;
                                    state <= IDLE;
                                end

                                //DEFAULT
                                //=========================

                                 default: begin
                                     state <= IDLE;
                                 end
                             endcase
                         end
                     end
                 end
                 endmodule








                                    





                   

