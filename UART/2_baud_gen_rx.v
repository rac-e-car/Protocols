module baud_gen_rx #(parameter baud_rate = 9600, system_clock = 50_000_000)
(
    input clk,
    input rx_rst,
    output rx_en
);

localparam integer cycle = system_clock/(baud_rate*16);

reg [$clog2(cycle)-1:0] count = 0;

always(@posedge clk or negedge rx_rst) begin
    if(!rx_rst) begin
        count <=0;
        rx_rst <=0;
    end

   else if (count <= cycle - 1) begin
       rx_en <= 1;
       count <= 0;
   end
   
   else begin
       rx_en <= 0;
       count <= count +1;
   end
   end
   endmodule
