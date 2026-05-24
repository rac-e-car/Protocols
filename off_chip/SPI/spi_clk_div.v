module clk_div #(parameter DIV = 50)
                (
                input clk, rst,
                output reg spi_tick);
            
            reg [$clog2(DIV)-1 : 0] count;


            always @(posedge clk) begin
                if(rst) begin
                    spi_tick <= 0;
                    count <= 0;
                end

                else if(count == DIV-1) begin
                    count <= 0;
                    spi_tick <= ~ spi_tick;
                end
                
                else begin
                    count <= count+1;
                end
            end
            endmodule

