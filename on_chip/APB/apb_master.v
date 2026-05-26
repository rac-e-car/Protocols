module apb_master #(
                    parameter DATA_WIDTH = 8,
                    parameter ADDR_WIDTH = 16)
                                                  
                    (input pclk, presetn,           
                     input transfer, write_en,              // User side control
                     input [ADDR_WIDTH-1:0] addr,
                     input [DATA_WIDTH-1:0] write_data,
                     input pready, pslverr,                 // APB slave side
                     input [DATA_WIDTH-1:0] prdata,

                     output reg [ADDR_WIDTH-1:0] paddr,     // APB outputs    
                     output reg [DATA_WIDTH-1:0] pwdata,
                     output reg psel, penable, pwrite,
                     output reg [DATA_WIDTH-1:0] read_data  //captured read data
                 );


//--------------------------------------------------
// STATE DECLARATION
//--------------------------------------------------

localparam [1:0]
IDLE = 2'b00,
SETUP = 2'b01,
ACCESS = 2'b10;

reg [1:0] current_state, next_state;

//--------------------------------------------------
// STATE REGISTER LOGIC
//--------------------------------------------------


always @(posedge clk or negedge presetn) begin
    if(!presetn) begin
        current_state <= IDLE;
        paddr <= 0;
        pwdata <= 0;
        read_data <= 0;
        psel <= 0;
        penable <= 0;
    end else begin
        current_state <= next_state;
        if(psel && penable && pready && !pwrite)
                read_data <= prdata;
        end
    end

//--------------------------------------------------
// NEXT STATE LOGIC
//--------------------------------------------------

always @(*) begin
    next_state = current_state;
    
    case(current_state)
        IDLE: begin
            if(transfer)
                next_state = SETUP;
            else
                next_state = IDLE;
        end

        SETUP: begin
            next_state = ACCESS;
        end

        ACCESS: begin
            if(PREADY) begin
                if(transfer)
                    next_state = SETUP;
                else
                    next_state = IDLE;
            end else begin
               next_state = ACCESS;
           end
       end

       default: begin
          next_state = IDLE;
      end
  endcase
  end
//--------------------------------------------------
//  OUTPUT LOGIC
//--------------------------------------------------
always @(posedge clk or negedge presetn) begin
    if (!presetn) begin
        paddr <= 0;
        pwdata <= 0;
        penable <= 0;
        psel <= 0;
        pwrite <= 0;
    end
    else begin

        case(next_state)
            IDLE: begin
                paddr <= 0;
                pwdata <= 0;
                penable <= 0;
                psel <= 0;
                pwrite <= 0;
            end

            SETUP: begin
                psel <= 1;
                penable <= 0;

                pwrite <= write_en;
                paddr <= addr;

                if(write_en)
                    pwdata <= write_data;
                else 
                    pwdata <= 0;
            end

            ACCESS: begin
                psel <= 1;
                penable <= 1;

                    end

            default:
            begin
                PSEL    <= 0;
                PENABLE <= 0;
                PWRITE  <= 0;
                PADDR   <= 0;
                PWDATA  <= 0;
            end
        endcase
    end
end  

endmodule
