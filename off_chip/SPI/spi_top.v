module spi_top  (              

                 input clk, rst_n, start,
                 input [7:0] master_tx_data, slave_tx_data,
                 output [7:0] master_rx_data, slave_rx_data,
                 output master_done, slave_done
                 );

                 wire miso, mosi, sclk, cs; 

                 spi_master inst_m (.clk(clk), .rst_n(rst_n), .start(start), 
                                    .tx_data(master_tx_data),
                                    .miso(miso), .mosi(mosi), .sclk(sclk), 
                                    .cs(cs), .done(master_done),
                                    .rx_data(master_rx_data) );

                 spi_slave inst_s (.clk(clk), .rst_n(rst_n), 
                                   .tx_data(slave_tx_data),
                                   .miso(miso), .mosi(mosi), .sclk(sclk), 
                                   .cs(cs), .done(slave_done),
                                   .rx_data(slave_rx_data) );

                 endmodule


                  
