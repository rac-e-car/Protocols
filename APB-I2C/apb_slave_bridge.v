module apb_i2c_slave #(
                   parameter DATA_WIDTH = 8,
                   parameter ADDR_WIDTH = 16,
                   parameter CLK_CNT    = 16'd199
                     )

                   (input pclk, presetn,
                    input pwrite, penable, psel,
                    input [DATA_WIDTH-1:0] pwdata,
                    input [ADDR_WIDTH-1:0] paddr,
                    output reg pready, pslverr,
                    output reg [DATA_WIDTH-1:0] prdata,
                
                    output [15:0] clk_cnt,
                    output ena,
                    output [7:0] din_byte,
                    output [2:0] cmd_in,
                    input  cmd_ack,
                    input  rx_ack,
                    input  [7:0] read_byte,
                    input  read_valid,
                    input  busy,
                    input  al
                );


                localparam [7:0]
                        ADDR_PRERlo = 8'h00,
                        ADDR_PRERhi = 8'h01,
                        ADDR_CTR    = 8'h02,
                        ADDR_TXR    = 8'h03,
                        ADDR_CR     = 8'h04;

                 reg [7:0] PRERhi, PRERlo;
                 reg [7:0] CTR_reg;
                 reg [7:0] TXR_reg;
                 reg [7:0] CR_reg;
                 
                 //writing outputs to i2c master:
                 assign clk_cnt  = {PRERhi, PRERlo};
                 assign ena      = CTR_reg[0];
                 assign din_byte = TXR_reg;
                 assign cmd_in   = CR_reg [2:0];

                always @(posedge pclk or negedge presetn) begin
                    if(!presetn) begin
                        pready <= 0;
                        pslverr <= 0;
                        prdata <= 0;

                        PRERhi <= CLK_CNT[15:8];
                        PRERlo <= CLK_CNT[7:0];
                        CTR_reg <= 0;
                        TXR_reg <= 0;
                        CR_reg  <= 0;

                    end else begin
                        
                        pslverr <= 0;         

                            if(psel && penable) begin

                                pready <= 1;

                                if(pwrite) begin
                                   case(paddr)
                                       ADDR_PRERlo: PRERlo  <= pwdata;
                                       ADDR_PRERhi: PRERhi  <= pwdata;
                                       ADDR_CTR   : CTR_reg <= pwdata;
                                       ADDR_TXR   : TXR_reg <= pwdata;
                                       ADDR_CR    : CR_reg  <= pwdata;
                                       default    : pslverr <= 1;
                                   endcase

                               end else begin
                                   case(paddr)
                                       ADDR_PRERlo: prdata  <= PRERlo;
                                       ADDR_PRERhi: prdata  <= PRERhi;
                                       ADDR_CTR   : prdata  <= CTR_reg;
                                       ADDR_TXR   : prdata  <= TXR_reg;
                                       ADDR_CR    : prdata  <= {rx_ack, busy, al, 3'b0, cmd_ack, read_valid};
                                       default    : pslverr <= 1;
                                   endcase
                               end
                            end

                                else begin
                                  pready <= 0;
                                end
                  end
                  end
                  endmodule

                        
