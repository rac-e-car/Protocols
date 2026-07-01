module bit8_ctrl
(
    input clk, rst, ena, d_in,
    input [15:0] clk_cnt,
    output scl, sda, cmd_ack, dout, busy, al
);


localparam [2:0]
    IDLE = 3'B000;
    START = 3'B00;
    DATA = 3'b001;
    WRITE = 3'010;

    reg [2:0] cmd;


    always @(posedge clk) begin
        if(rst) begin
            scl <= 0;
            sda <= 1;
            cmd_ask <= 0;





