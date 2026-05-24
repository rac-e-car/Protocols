module apb_top #(parameter ADDR_WIDTH = 16,
                 parameter DATA_WIDTH = 8)
    
               
               (input clk, presetn, transfer, write_en,
                input [ADDR_WIDTH-1:0] addr,
                input [DATA_WIDTH-1:0] write_data,
                output read_data);

                wire psel, penable, pwrite;            
                wire pready, pslverr;
                wire [7:0] paddr, pwdata, prdata;

                apb_master inst_m (.psel(psel),.penable(penable),.pwrite(pwrite),.pready(pready),.pslverr(pslverr),.paddr(paddr),.pwdata(pwdata),.prdata(prdata),.read_data(read_data));

                apb_slave inst_s (.psel(psel),.penable(penable),.pwrite(pwrite),.pready(pready),.pslverr(pslverr),.paddr(paddr),.pwdata(pwdata),.prdata(prdata) );

                endmodule




















