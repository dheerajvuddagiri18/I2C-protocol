
module i2c_master(
    input clk,                       // Clock signal
    input arst,                     // Asynchronous reset
    input [6:0] addr,                // 7-bit I2C address
    input [7:0] data_in,            // Data to be sent
    input enable,                   // Enable signal for the I2C master 
    input rw,                       // Read/Write control (1 for read, 0 for write)
    output reg [7:0] data_out,      // Data received
    output busy,                    // Busy signal indicating I2C operation in progress
    output scl,                     // Serial Clock Line (actual i2c clock)
    inout sda                       // Serial Data Line (actual i2c data line)
);

parameter IDLE = 3'b000;
parameter START = 3'b001;
parameter ADDRESS = 3'b010;
parameter READ_ACK1 = 3'b011;
parameter DATA_TRANSFER = 3'b100;
parameter WRITE_ACK = 3'b101;
parameter READ_ACK2 = 3'b110;
parameter STOP = 3'b111;

reg [2:0] state = IDLE;          // current state initiated to IDLE
reg [2:0] count = 0;          // general counter
reg [7:0] count_2 = 0;
reg i2c_clk = 0;
reg scl_en_clk = 0;
reg [7:0] count_3 = 0;
reg scl_enable = 0;
reg sda_enable = 0;
reg sda_out;
reg [7:0] saved_addr;
reg [7:0] saved_data;
//generating i2c_clk
always @(posedge clk) begin
  if(count_2 == 124) begin
    i2c_clk = ~i2c_clk;
    count_2 <= 0;
  end
  else begin
    count_2 <= count_2 + 1;
  end
end
// generating scl_en_clk
always @(posedge clk) begin
  if(count_3 == 62) begin
    scl_en_clk = ~scl_en_clk;
    count_3 <= 0;
  end
  else begin
    count_3 <= count_3  + 1;
  end
end

always @(negedge scl_en_clk,posedge arst) begin
if(arst) scl_enable <= 0;
else begin
if(state == IDLE || state == START || state == STOP) scl_enable <= 1'b0;
else scl_enable <= 1'b1;
end
end


always @(posedge i2c_clk,posedge arst) begin
  if(arst) begin
    state <= IDLE;
  end
  else begin
    case(state)
      IDLE : begin
        if(enable) begin
          state <= START;
          saved_addr <= {addr,rw};
          saved_data <= data_in;
        end
        else 
        begin
          state <= IDLE;
        end
      end
      START : begin
        state <= ADDRESS;
        count <= 7;
      end
      ADDRESS : begin
        if(count == 0) begin
          state <= READ_ACK1;
        end
        else begin
          count <= count - 1;
          state <= ADDRESS;
        end
      end
      READ_ACK1 : begin
        if(sda == 0) begin
          count <= 7;
          state <= DATA_TRANSFER;
        end
        else begin
          state <= STOP; // NACK received, go to STOP
        end
      end
      DATA_TRANSFER : begin
        if(saved_addr[0]) begin
          data_out [count] <= sda; // Read data from SDA
          if(count == 0) begin
            state <= WRITE_ACK;
          end
          else begin
            count <= count - 1;
            state <= DATA_TRANSFER;
          end
        end
        else begin
          if(count == 0) begin
            state <= READ_ACK2;
          end
          else begin
            count <= count - 1;
            state <= DATA_TRANSFER;
          end
        end
      end
      WRITE_ACK : begin
        state <= STOP;
      end
      READ_ACK2 : begin
        if(sda == 0 && enable == 1) begin
          state <= IDLE; // NACK received, go back to IDLE
        end
        else begin
          state <= STOP; // ACK received, go to STOP
        end
      end
      STOP : begin
        state <= STOP;
      end
    endcase
    end  
  end

  always @(negedge i2c_clk , posedge arst) begin
    if(arst) begin
      sda_out <= 1;
      sda_enable <= 1;
    end
    else begin
      case(state) 
        START : begin
          sda_out <= 0;
          sda_enable <= 1; // Start condition
        end
        ADDRESS : begin
          sda_out <= saved_addr[count];
          sda_enable <= 1; // Send address
        end
        READ_ACK1 : begin
          sda_enable <= 0; // Release SDA for ACK
        end
        DATA_TRANSFER : begin
          if(saved_addr[0]) begin
            sda_enable <= 0;
          end
          else begin
            sda_out <= saved_data[count];
            sda_enable <= 1;
          end
        end
        WRITE_ACK : begin
          sda_enable <= 1; // Send ACK for write
          sda_out <= 0; // Send ACK
        end
        READ_ACK2 : begin
          sda_enable <= 0; // Release SDA for ACK
        end
        STOP : begin
          sda_out <= 1; // Stop condition
          sda_enable <= 1; // Release SDA
        end
      endcase
    end
  end

  assign scl = scl_enable ? i2c_clk : 1'b1;
  assign sda = sda_enable ? sda_out : 'bz;   
  assign busy = (state == IDLE) ? 1'b0 : 1'b1; // Busy signal when not in IDLE state
endmodule
