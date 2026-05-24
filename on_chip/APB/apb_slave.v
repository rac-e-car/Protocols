module apb_slave #(
                   parameter DATA_WIDTH = 8,
                   parameter ADDR_WIDTH = 16 )

                   (input pclk, presetn,
                    input psel, pwrite, penable,
                    input [DATA_WIDTH-1:0] pwdata,
                    input [ADDR_WIDTH-1:0] paddr,
                    output reg pready, pslverr,
                    output reg [DATA_WIDTH-1:0] prdata);

                reg[DATA_WIDTH-1:0] mem [0:15];

                always @(posedge clk or negedge presetn) begin
                    if(!presetn) begin
                        pready <= 0;
                        pslverr <= 0;
                        prdata <= 0;

                        for(integer i=0; i<16; i=1+1) begin
                            mem[i] <= 0;
                        end
                    end else begin
                            pready <= 1;
                            pslverr <= 0;

                            if(psel && penable) begin

                                if(pwrite)
                                    mem[paddr] <= pwdata;
                                else
                                    prdata <= mem[paddr];
                            
                            end
                        end
                    end
                    endmodule




                        
