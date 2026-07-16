module apb_i2c_top #(parameter ADDR_WIDTH     = 16,
                     parameter DATA_WIDTH     = 8,
                     parameter SYS_CLK        = 100_000_000,
                     parameter PROTOCOL_SPEED = 100_000
                    )
               
               (
               input pclk, presetn, transfer, write_en,
               input [ADDR_WIDTH-1:0] addr,
               input [DATA_WIDTH-1:0] write_data,
               output [DATA_WIDTH-1:0] read_data,
               output scl,
               inout sda
               );

                localparam [15:0] CLK_CNT = (SYS_CLK / (5 * PROTOCOL_SPEED)) - 1;

                wire psel, penable, pwrite;
                wire [15:0] paddr;            
                wire pready, pslverr;
                wire [7:0] pwdata, prdata;

                //i2c signal wires
                wire [15:0] clk_cnt;
                wire [7:0] din_byte;
                wire [2:0] cmd_in;
                wire [7:0] read_byte;
                wire ena, cmd_ack, rx_ack, read_valid, busy, al;
                
                apb_i2c_master inst_m 
                (
                    //board inputs and user side controls
                    .pclk(pclk), .presetn(presetn), .transfer(transfer), .write_en(write_en), .addr(addr), .write_data(write_data),
                    //outputs from master, inputs to slave
                    .psel(psel),.penable(penable),.pwrite(pwrite),.paddr(paddr),.pwdata(pwdata),
                    //outputs from slave, inputs to master
                    .pready(pready),.pslverr(pslverr),.prdata(prdata),
                    //read data from slave
                    .read_data(read_data)
                );

                apb_i2c_slave #(.CLK_CNT(CLK_CNT)) inst_s 
                (
                    //board inputs
                    .pclk(pclk), .presetn(presetn),
                    //outputs from master, inputs to slave 
                    .psel(psel),.penable(penable),.pwrite(pwrite),.paddr(paddr),.pwdata(pwdata),
                    //outputs from slave, inputs to master
                    .pready(pready),.pslverr(pslverr),.prdata(prdata),
                    //connections to i2c master
                    .clk_cnt(clk_cnt), .ena(ena), .din_byte(din_byte), .cmd_in(cmd_in), .cmd_ack(cmd_ack), .rx_ack(rx_ack), .read_byte(read_byte), .read_valid(read_valid), .busy(busy) , .al(al)
                );

                i2c_master  inst_bridge

                (
                    .clk(pclk), .rst_n(presetn), .clk_cnt(clk_cnt), .ena(ena), .byte(din_byte), .cmd_in(cmd_in), .cmd_ack(cmd_ack), .rx_ack(rx_ack), .read_byte(read_byte), .read_valid(read_valid), .busy(busy) , .al(al), .sda(sda), .scl(scl) 
                );

                endmodule 



