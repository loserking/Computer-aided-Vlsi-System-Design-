module DPA ( clk, reset, IM_A, IM_Q, IM_D, IM_WEN, CR_A, CR_Q);
input clk;
input reset;

//img_rom
output reg[19:0] IM_A;
input [23:0] IM_Q;
output reg [23:0] IM_D;
output reg IM_WEN;

//char_rom
output reg[8:0] CR_A;
input [12:0] CR_Q;

endmodule

