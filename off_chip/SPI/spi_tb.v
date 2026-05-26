module spi_tb;

reg clk, rst_n, start;
reg [7:0] master_tx_data, slave_tx_data;

wire [7:0] master_rx_data, slave_rx_data;
wire master_done, slave_done;

spi_top dut (.clk(clk), .rst_n(rst_n), .start(start),
             .master_tx_data(master_tx_data), .slave_tx_data(slave_tx_data),
             .master_rx_data(master_rx_data), .slave_rx_data(slave_rx_data),
             .master_done(master_done), .slave_done(slave_done) );

    always #5 clk = ~clk;

    task check_data;
        input [7:0] actual, expected;

        begin

            if (actual == expected) begin
                $display ("MATCH--> Actual = %h | Expected = %h | testcase PASSED", actual, expected);
            end
            else begin
                $display ("MISMATCH--> Actual = %h | Expected = %h | testcase FAILED", actual, expected);
                $stop;
            end
        end

    endtask

    initial begin
        clk=0; rst_n=0; start=0; master_tx_data=0; slave_tx_data=0;
        #20;
        rst_n=1;
        
        //==========================
        //PASS case
        //==========================
        
        $display("TESTCASE 1 -- PASS CASE");
        
        #10; 
        master_tx_data = 8'hA3;
	    slave_tx_data = 8'h8E;
	     
	#20; start = 1;
	#10; start = 0;
	
	wait (master_done);                                // wait for completion

        check_data (master_rx_data, 8'h8E);
        check_data (slave_rx_data, 8'hA3);
        
        $display("TEST CASE1 COMPLETED");
        
        //=========================
        //FAIL case
        //=========================
        
        $display("TESTCASE 2 -- FAIL CASE");

       #20; wait (!master_done);                               //wait for done to go low again
        
        #20; 
        master_tx_data = 8'h4B;
	    slave_tx_data = 8'h1D;
	     
	#20; start = 1;
	#10; start = 0;
	
        wait (master_done);
	
        check_data (master_rx_data, 8'h5c);
        check_data (slave_rx_data, 8'hA7);
        
        $display("TEST CASE2 COMPLETED");

        #20; $finish;

        end
        endmodule






