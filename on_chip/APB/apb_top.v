module apb_top #(parameter ADDR_WIDTH = 16,
                 parameter DATA_WIDTH = 8)
    
               
               (input pclk, presetn, transfer, write_en,
                input [ADDR_WIDTH-1:0] addr,
                input [DATA_WIDTH-1:0] write_data,
                output [DATA_WIDTH-1:0] read_data);

                wire psel, penable, pwrite;
                wire [15:0] paddr;            
                wire pready, pslverr;
                wire [7:0] pwdata, prdata;
                
                apb_master inst_m 
                (
                    //board inputs and user side controlls
                    .pclk(pclk), .presetn(presetn), .transfer(transfer), .write_en(write_en), .addr(addr), .write_data(write_data),
                    //outputs from master, inputs to slave
                    .psel(psel),.penable(penable),.pwrite(pwrite),.paddr(paddr),.pwdata(pwdata),
                    //outputs from slave, inputs to master
                    .pready(pready),.pslverr(pslverr),.prdata(prdata),
                    //read data from slave
                    .read_data(read_data)
                );

                apb_slave inst_s 
                (
                    //board inputs
                    .pclk(pclk), .presetn(presetn),
                    //outputs from master, inputs to slave 
                    .psel(psel),.penable(penable),.pwrite(pwrite),.paddr(paddr),.pwdata(pwdata),
                    //outputs from slave, inputs to master
                    .pready(pready),.pslverr(pslverr),.prdata(prdata) 
                );

                endmodule




















