module i2c_clk_gen
(
    input clk, rst_n, ena,
    input [15:0] clk_cnt,
    output reg int_tick
);
reg [15:0] counter;


    always @(posedge clk) begin
        if(!rst_n) begin
            int_tick <= 0;
            counter <= 0;
        end

        else if (ena) begin

            if (counter == clk_cnt) begin
                int_tick <= 1;
                counter <= 0;
            end
            else begin
                int_tick <= 0;
                counter <= counter+1;
            end
        end
        
        else begin
            int_tick <= 0;
            counter <= 0;
        end
 
    end
    endmodule     





