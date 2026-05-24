module baud_rate_gen #(parameter baud_rate = 9600,  system_clock = 50_000_000)

(   input clk, 
    tx_rst, 
    output tx_en
);

localparam integer cycle = system_clock/baud_rate;

reg [$clog2(cycle)-1:0] count = 0;

always @(posedge clk or negedge tx_rst) begin
    if(!tx_rst) begin
        count <=0;
        tx_en <=0;
    end

    else if(count == cycle-1) begin
        tx_en <=1;
        count <=0;
    end
    
    else begin
        tx_en <= 0;
        count <= count+1;
    end
end
endmodule


