module apb_tb;

reg clk, presetn, transfer, write_en;
reg [7:0] write_data;
reg [15:0] addr;
wire [7:0] read_data;

apb_top dut (.clk(clk),.presetn(presetn),.transfer(transfer),.write_en(write_en),.write_data(write_data),.addr(addr),.read_data(read_data));

always #5 clk = ~clk;

task apb_write;

    input [15:0] wr_addr;
    input [8:0] wr_data;

    begin

   @(posedge clk);

        transfer = 1;
        write_en =1;
        
        addr = addr_data;
        write_data = wr_data;
   
   @(posedge clk);

        transfer = 0;
    
    end

endtask

task apb_read;

    input [15:0] rd_addr;

    begin

        @(posedge clk);

            transfer = 1;
            write_en = 0;

            addr = rd_addr;
            
        @(posedge clk);

            transfer = 0;

        end

    endtask


initial begin
clk =0; presetn =0; transfer =0; write_en =0; write_data=0; addr=0; 
#20; presetn = 1;


apb_write (16'h00ff, 8'ha1);


#20; apb_read (16'h00ff);

#50; finish;

end
endmodule






 
