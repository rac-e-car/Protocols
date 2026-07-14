module i2c_master
(
    input clk,
    input rst_n,
    input ena,
    input [7:0] byte,
    input [2:0] cmd_in,
    input [15:0] clk_cnt,
    output [7:0] read_byte,
    output cmd_ack,
    output read_valid,
    output rx_ack,
    output scl,
    inout sda
);

wire int_tick, din, cmd_ack_internal, dataio;
wire [2:0] cmd_from_byte;
wire sda_out;         //driven by bit controller
wire sda_in;	     //read by bit controller (actual value on the wire)

assign sda = (sda_out == 1'b0) ? 1'b0 : 1'bz;      //open drain logic (drive low when needed, tri-state otherwise)
assign sda_in = sda;				   //read actual wire value back in

i2c_clk_gen tick      // clk_tick instantiation
( 
    .clk(clk), .int_tick(int_tick), .ena(ena), .rst_n(rst_n), .clk_cnt(clk_cnt) 
);

bit8_ctrl inst1       // bit_controller instantiation
(
    .int_tick(int_tick), .clk(clk), .rst_n(rst_n), .ena(ena), .din(din), .cmd(cmd_from_byte), .scl(scl), .sda_out(sda_out), .cmd_ack(cmd_ack_internal), .sda_in(sda_in), .dout(dataio)
);

byte_ctrl inst2       // byte_controller instantiation
(
    .clk(clk), .rst_n(rst_n), .ena(ena), .din_from_bit8(dataio), .cmd_ack_from_bit8(cmd_ack_internal), .din_byte(byte), .cmd_in(cmd_in), .din(din), .read_byte(read_byte), .cmd_ack(cmd_ack), .rx_ack(rx_ack), .read_valid(read_valid), .cmd_out(cmd_from_byte) 
);

endmodule
