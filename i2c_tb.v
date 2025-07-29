`timescale 1ns/1ns
module i2c_tb;
reg clk;
reg arst;
reg [6:0] addr;
reg [7:0] data_in;
reg rw;
reg enable;

wire scl;
wire sda;
wire busy;
wire [7:0] data_out;

i2c_master master(
    .clk(clk),
    .arst(arst),
    .addr(addr),
    .data_in(data_in),
    .rw(rw),
    .enable(enable),
    .scl(scl),
    .sda(sda),
    .data_out(data_out),
    .busy(busy)
);

i2c_slave slave(
    .scl(scl),
    .sda(sda)
);

always begin
  #5;
  clk = ~clk; // Clock generation
end

initial begin
  clk = 0;
  arst = 1;

  #2500;
  arst = 0;
  addr = 7'b1010111;
  data_in = 8'b10110011;
  rw = 0;
  enable = 1;
  #2500;
  enable = 0; // Disable master
  
  wait(!busy);
  #2500;
  addr = 7'b1010111;
  rw = 1;   // Read operation
  enable = 1; // Enable master for read operation
  #2500;
  enable = 0;

end

initial begin
  $display("slave address : %b",7'b1010111);
  $display("slave data : %b",8'b11011101);
end
endmodule
