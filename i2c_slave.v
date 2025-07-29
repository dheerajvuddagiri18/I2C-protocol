
module i2c_slave (
    input scl,                     // Serial Clock Line
    inout sda                     // Serial Data Line
);

parameter READ_ADDRESS = 2'b00;
parameter SEND_ACK1 = 2'b01;
parameter DATA_TRANSFER = 2'b10;
parameter SEND_ACK2 = 2'b11;

localparam slave_address = 7'b1010111; // Example slave address

reg[1:0] state = READ_ADDRESS;
reg [6:0] address;
reg rw;
reg [7:0] data_in;
reg [7:0] data_out = 8'b11011101; //stored data
reg sda_out = 0;
reg sda_enable = 0;
reg sda_enable_2 = 1;
reg [2:0] count = 7;
reg start = 0;
reg stop = 1;

always @(sda) begin
    if (sda == 0 && scl == 1) begin
      start <= 1;
      stop <= 0;
    end
    if(sda == 1 && scl ==1) begin
      start <= 0;
      stop <= 1; 
    end
  
end

always @(posedge scl) begin
  if(start) begin
    case(state) 
        READ_ADDRESS : begin
          if(count == 0) begin
            sda_enable_2 <= 1;
            rw <= sda;
            state <= SEND_ACK1;
          end
          else begin
            address[count - 1] <= sda;
            count <= count - 1;
            state <= READ_ADDRESS;
          end
        end
        SEND_ACK1: begin
          if(address == slave_address) begin
            state <= DATA_TRANSFER;
            count <= 7; 
        end
        end
        DATA_TRANSFER: begin
          if(!rw) begin
            data_in[count] <= sda;
            if(count == 0) begin
              state <= SEND_ACK2;
            end
            else begin
              count <= count - 1;
              state <=DATA_TRANSFER;
            end
          end
          else begin
            if(count == 0) begin
              state <= READ_ADDRESS;
            end
            else begin
              count <= count - 1;
              state <= DATA_TRANSFER;
            end
          end
        end
        SEND_ACK2: begin
          state <= READ_ADDRESS;
          sda_enable_2 <= 0;
          count <= 7;
        end
    endcase
  end
  else if(stop) begin
    state <= READ_ADDRESS;
    sda_enable_2 <= 1;
    count <= 7;                 // Reset count for next address read
  end 
end

always @(negedge scl) begin
  case(state) 
    READ_ADDRESS: begin
        sda_enable<= 0;       // Do not drive SDA during address read
    end
    SEND_ACK1 : begin
      if(slave_address == address) begin
        sda_out <= 0;
        sda_enable <= 1;        // Send ACK
      end
      else begin
        sda_enable <= 0; // NACK
      end
    end
    DATA_TRANSFER: begin
      if(!rw) begin
        sda_enable <= 0;         // Read operation, do not drive SDA
      end
      else begin
        sda_out <= data_out[count];
        sda_enable <= 1;             // Send data on SDA
      end
    end
    SEND_ACK2 : begin
      sda_out <= 0;    
      sda_enable <= 1; // Send ACK
    end
  endcase
end

assign sda = (sda_enable && sda_enable_2) ? sda_out : 1'bz ; // Tri-state SDA line


endmodule
