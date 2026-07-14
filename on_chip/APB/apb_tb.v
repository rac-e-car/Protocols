module apb_tb;

reg pclk, presetn, transfer, write_en;
reg [7:0] write_data;
reg [15:0] addr;
wire [7:0] read_data;

apb_top dut (.pclk(pclk),.presetn(presetn),.transfer(transfer),.write_en(write_en),.write_data(write_data),.addr(addr),.read_data(read_data));

always #5 pclk = ~pclk;

task apb_write;

    input [15:0] wr_addr;
    input [7:0] wr_data;

    begin
        transfer = 1;
        write_en =1;
        
        addr = wr_addr;
        write_data = wr_data;
        @(posedge pclk);
        @(posedge pclk);
        @(posedge pclk);

        transfer = 0;
    
    end

endtask

task apb_read;

    input [15:0] rd_addr;

    begin
            transfer = 1;
            write_en = 0;

            addr = rd_addr;
        @(posedge pclk);            
        @(posedge pclk);
        @(posedge pclk);    

            transfer = 0;

        end

    endtask


initial begin
pclk =0; presetn =0; transfer =0; write_en =0; write_data=0; addr=0; 
#20; presetn = 1;

 apb_write (16'h0f, 8'hA1);

#20; apb_read (16'h0f);

#50; $finish;

end

initial begin
    $dumpfile("apb_top.vcd");
    $dumpvars(0);
end

endmodule






 
