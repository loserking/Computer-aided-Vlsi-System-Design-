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

reg [19:0] next_IM_A;
reg [23:0] next_IM_D;
reg next_IM_WEN;//low is write, high is read
reg [8:0] next_CR_A;

reg [5:0] hour, next_hour, min, next_min, sec, next_sec;
reg [8:0] cycle, next_cycle;
//reg [4:0] char_cycle, next_char_cycle;

reg [19:0] FB_addr, FB_addr_cnt, FB_addr_nxt, 
		p1_addr, p1_size, p1_addr_cnt, p1_addr_nxt, 
		p2_addr, p2_size, p2_addr_cnt, p2_addr_nxt,
		p3_addr, p3_size, p3_addr_cnt, p3_addr_nxt,
		p4_addr, p4_size, p4_addr_cnt, p4_addr_nxt,
		photo_num;
//reg [8:0] char_addr_cnt, char_addr_nxt;	  


reg [7:0] R1, G1, B1, R2, G2, B2, R3, G3, B3, R4, G4, B4;

reg [3:0] pixel_num, next_pixel_num;

//FSM state == 00 -> init
//    state == 01 -> read & write picture
//	  state == 10 -> read timer
//    state == 11 -> write char
reg [1:0] state, next_state;

//pic_count == 00 -> p1
//pic_count == 01 -> p2
//pic_count == 10 -> p3
//pic_count == 11 -> p4
reg [1:0] pic_count, next_pic_count;

//parameter
parameter A_SEC_CYCLE = 1000000000;

//combination
//read & write pic.
always@(*)begin
	if(state == 2'b01)begin
		/*if(p1_size == 128)begin
			if(IM_WEN)begin//read 128
				if(pixel_num[1:0] == 2'b00)begin
					R1 = IM_Q[23:16];
					G1 = IM_Q[15:8];
					B1 = IM_Q[7:0];
					next_pixel_num = pixel_num + 1;
					next_IM_A = p1_addr_cnt;
					next_IM_WEN = 1;
					p1_addr_nxt = p1_addr_cnt + 1;
					FB_addr_nxt = FB_addr_cnt;
					next_state = 2'b01;
				end
				else if(pixel_num[1:0] == 2'b01)begin
					R2 = IM_Q[23:16];
					G2 = IM_Q[15:8];
					B2 = IM_Q[7:0];
					next_pixel_num = pixel_num + 1;
					next_IM_A = p1_addr;
					next_IM_WEN = 1;
					p1_addr_nxt = p1_addr + 127;
					FB_addr_nxt = FB_addr_cnt;
					next_state = 2'b01;
				end
				else if(pixel_num[1:0] == 2'b10)begin
					R3 = IM_Q[23:16];
					G3 = IM_Q[15:8];
					B3 = IM_Q[7:0];
					next_pixel_num = pixel_num + 1;
					next_IM_A = p1_addr_cnt;
					next_IM_WEN = 1;
					p1_addr_nxt = p1_addr_nxt + 1;
					FB_addr_nxt = FB_addr_cnt;
					next_state = 2'b01;
				end
				else begin
					R4 = IM_Q[23:16];
					G4 = IM_Q[15:8];
					B4 = IM_Q[7:0];
					next_pixel_num = 0;
					next_IM_A = FB_addr_cnt;
					next_IM_WEN = 0;
					p1_addr_nxt = p1_addr_cnt - 127;
					FB_addr_nxt = FB_addr_cnt;
					next_state = 2'b01;
				end
			end
			
			else begin//write 128
				if(pixel_num == 4'b0000)begin//a
					next_IM_D = { R1, G1, B1 };
					next_pixel_num = pixel_num + 1;
					next_IM_WEN = 0;
					next_IM_A = FB_addr_cnt + 2;
					p1_addr_nxt = p1_addr_cnt;
					FB_addr_nxt = FB_addr_cnt + 2;
					next_state = 2'b01;
				end
				else if(pixel_num == 4'b0001)begin//b
					next_IM_D = {((R1+R2)>>1),((G1+G2)>>1),((B1+B2)>>1)};
					next_pixel_num = pixel_num + 1;
					next_IM_WEN = 0;
					next_IM_A = FB_addr_cnt + 2;
					p1_addr_nxt = p1_addr_cnt;
					FB_addr_nxt = FB_addr_cnt + 2;
					next_state = 2'b01;
				end
				else if(pixel_num == 4'b0010)begin//c
					next_IM_D = {R2, G2, B2};
					next_pixel_num = pixel_num + 1;
					next_IM_WEN = 0;
					next_IM_A = FB_addr_cnt + 2;
					p1_addr_nxt = p1_addr_cnt;
					FB_addr_nxt = FB_addr_cnt + 2;
					next_state = 2'b01;
				end
				else if(pixel_num == 4'b0011)begin//d
					next_IM_D = {R2, G2, B2};
					next_pixel_num = pixel_num + 1;
					next_IM_WEN = 0;
					next_IM_A = FB_addr_cnt + 2;
					p1_addr_nxt = p1_addr_cnt;
					FB_addr_nxt = FB_addr_cnt + 125;
					next_state = 2'b01;
				end
				else if(pixel_num == 4'b0100)begin//e
					next_IM_D = {((R1+R3)>>1),((G1+G3)>>1),((B1+B3)>>1)};
					next_pixel_num = pixel_num + 1;
					next_IM_WEN = 0;
					next_IM_A = FB_addr_cnt;
					p1_addr_nxt = p1_addr_cnt;
					FB_addr_nxt = FB_addr_cnt + 1;
					next_state = 2'b01;
				end
				else if(pixel_num == 4'b0101)begin//f
					next_IM_D = {((R1+R2+R3+R4)>>2),((G1+G2+G3+G4)>>2),((B1+B2+B3+B4)>>2)};
					next_pixel_num = pixel_num + 1;
					next_IM_WEN = 0;
					next_IM_A = FB_addr_cnt;
					p1_addr_nxt = p1_addr_cnt;
					FB_addr_nxt = FB_addr_cnt + 1;
					next_state = 2'b01;
				end
				else if(pixel_num == 4'b0110)begin//g
					next_IM_D = {((R2+R4)>>1),((G2+G4)>>1),((B2+B4)>>1)};
					next_pixel_num = pixel_num + 1;
					next_IM_WEN = 0;
					next_IM_A = FB_addr_cnt;
					p1_addr_nxt = p1_addr_cnt;
					FB_addr_nxt = FB_addr_cnt + 1;
					next_state = 2'b01;
				end
				else if(pixel_num == 4'b0111)begin//h
					next_IM_D = {((R2+R4)>>1),((G2+G4)>>1),((B2+B4)>>1)};
					next_pixel_num = pixel_num + 1;
					next_IM_WEN = 0;
					next_IM_A = FB_addr_cnt;
					p1_addr_nxt = p1_addr_cnt;
					FB_addr_nxt = FB_addr_cnt + 125;
					next_state = 2'b01;
				end
				else if(pixel_num == 4'b1000)begin//i
					next_IM_D = {R3,G3,B3};
					next_pixel_num = pixel_num + 1;
					next_IM_WEN = 0;
					next_IM_A = FB_addr_cnt;
					p1_addr_nxt = p1_addr_cnt;
					FB_addr_nxt = FB_addr_cnt + 1;
					next_state = 2'b01;
				end
				else if(pixel_num == 4'b1001)begin//j
					next_IM_D = {((R3+R4)>>1),((G3+G4)>>1),((B3+B4)>>1)};
					next_pixel_num = pixel_num + 1;
					next_IM_WEN = 0;
					next_IM_A = FB_addr_cnt;
					p1_addr_nxt = p1_addr_cnt;
					FB_addr_nxt = FB_addr_cnt + 1;
					next_state = 2'b01;
				end
				else if(pixel_num == 4'b1010)begin//k
					next_IM_D = {R4,G4,B4};
					next_pixel_num = pixel_num + 1;
					next_IM_WEN = 0;
					next_IM_A = FB_addr_cnt;
					p1_addr_nxt = p1_addr_cnt;
					FB_addr_nxt = FB_addr_cnt + 1;
					next_state = 2'b01;
				end
				else if(pixel_num == 4'b1011)begin//l
					next_IM_D = {R4,G4,B4};
					next_pixel_num = pixel_num + 1;
					next_IM_WEN = 0;
					next_IM_A = FB_addr_cnt;
					p1_addr_nxt = p1_addr_cnt;
					FB_addr_nxt = FB_addr_cnt + 125;
					next_state = 2'b01;
				end
				else if(pixel_num == 4'b1100)begin//m
					next_IM_D = {R3,G3,B3};
					next_pixel_num = pixel_num + 1;
					next_IM_WEN = 0;
					next_IM_A = FB_addr_cnt;
					p1_addr_nxt = p1_addr_cnt;
					FB_addr_nxt = FB_addr_cnt + 1;
					next_state = 2'b01;
				end
				else if(pixel_num == 4'b1101)begin//n
					next_IM_D = {((R3+R4)>>1),((G3+G4)>>1),((B3+B4)>>1)};
					next_pixel_num = pixel_num + 1;
					next_IM_WEN = 0;
					next_IM_A = FB_addr_cnt;
					p1_addr_nxt = p1_addr_cnt;
					FB_addr_nxt = FB_addr_cnt + 1;
					next_state = 2'b01;
				end
				else if(pixel_num == 4'b1110)begin//o
					next_IM_D = {R4,G4,B4};
					next_pixel_num = pixel_num + 1;
					next_IM_WEN = 0;
					next_IM_A = FB_addr_cnt;
					p1_addr_nxt = p1_addr_cnt;
					FB_addr_nxt = FB_addr_cnt + 1;
					next_state = 2'b01;
				end
				else begin//p
					next_IM_D = {R4,G4,B4};
					next_pixel_num = pixel_num + 1;
					next_IM_WEN = 1;
					next_IM_A = p1_addr_cnt;
					p1_addr_nxt = p1_addr_cnt;
					FB_addr_nxt = FB_addr_cnt - 383;
					if(FB_addr_cnt == 65431)
						next_state = 2'b10;
					else
						next_state = 2'b01;
				end
			end
		end
		
		else */if(p1_size == 256)begin
			if(IM_WEN)begin//read 256
				if(pixel_num[1:0] == 2'b00)begin
					R1 = IM_Q[23:16];
					G1 = IM_Q[15:8];
					B1 = IM_Q[7:0];
					next_pixel_num = pixel_num + 1;
					next_IM_A = p1_addr_cnt + 2;
					next_IM_WEN = 1;
					p1_addr_nxt = p1_addr_cnt + 2;
					FB_addr_nxt = FB_addr_cnt;
					next_state = 2'b01;
				end
				else if(pixel_num[1:0] == 2'b01)begin
					R2 = IM_Q[23:16];
					G2 = IM_Q[15:8];
					B2 = IM_Q[7:0];
					next_pixel_num = pixel_num + 1;
					next_IM_A = p1_addr_cnt + 2;
					next_IM_WEN = 1;
					p1_addr_nxt = p1_addr_cnt + 2;
					FB_addr_nxt = FB_addr_cnt;
					next_state = 2'b01;
				end
				else if(pixel_num[1:0] == 2'b10)begin
					R3 = IM_Q[23:16];
					G3 = IM_Q[15:8];
					B3 = IM_Q[7:0];
					next_pixel_num = pixel_num + 1;
					next_IM_A = p1_addr_cnt + 2;
					next_IM_WEN = 1;
					p1_addr_nxt = p1_addr_cnt + 2;
					FB_addr_nxt = FB_addr_cnt;
					next_state = 2'b01;
				end
				else begin
					R4 = IM_Q[23:16];
					G4 = IM_Q[15:8];
					B4 = IM_Q[7:0];
					next_pixel_num = pixel_num + 1;
					next_IM_A = FB_addr_cnt;
					next_IM_WEN = 0;//write
					p1_addr_nxt = p1_addr_cnt + 2;
					FB_addr_nxt = FB_addr_cnt;
					next_state = 2'b01;
				end
			end
			
			else begin//write 256
				if(pixel_num[1:0] == 2'b00)begin
					next_IM_D[23:16] = R1;
					next_IM_D[15:8] = G1;
					next_IM_D[7:0] = B1;
					next_pixel_num = pixel_num + 1;
					next_IM_A = FB_addr_cnt + 2;
					next_IM_WEN = 0;
					p1_addr_nxt = p1_addr_cnt;
					FB_addr_nxt = FB_addr_cnt + 2;
					next_state = 2'b01;
				end
				else if(pixel_num[1:0] == 2'b01)begin
					next_IM_D[23:16] = R2;
					next_IM_D[15:8] = G2;
					next_IM_D[7:0] = B2;
					next_pixel_num = pixel_num + 1;
					next_IM_A = FB_addr_cnt + 2;
					next_IM_WEN = 0;
					p1_addr_nxt = p1_addr_cnt;
					FB_addr_nxt = FB_addr_cnt + 2;
					next_state = 2'b01;
				end
				else if(pixel_num[1:0] == 2'b10)begin
					next_IM_D[23:16] = R3;
					next_IM_D[15:8] = G3;
					next_IM_D[7:0] = B3;
					next_pixel_num = pixel_num + 1;
					next_IM_A = FB_addr_cnt + 2;
					next_IM_WEN = 0;
					p1_addr_nxt = p1_addr_cnt;
					FB_addr_nxt = FB_addr_cnt + 2;
					next_state = 2'b01;
				end
				else begin
					next_IM_D[23:16] = R4;
					next_IM_D[15:8] = G4;
					next_IM_D[7:0] = B4;
					next_pixel_num = pixel_num + 1;
					//next_IM_A = FB_addr_cnt + 2;
					next_IM_WEN = 1;
					p1_addr_nxt = p1_addr_cnt;
					//FB_addr_nxt = FB_addr_cnt + 2;					
					if(FB_addr_cnt == FB_addr + 65431)begin
						next_state = 2'b10;
						FB_addr_nxt = FB_addr + 59544;
						next_IM_A = FB_addr + 59544;
					end
					else begin
						next_state = 2'b01;
					FB_addr_nxt = (FB_addr_cnt == FB_addr + 59542)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 59543)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 59878)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 59879)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 60054)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 60055)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 60310)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 60311)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 60566)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 60567)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 60822)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 60823)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 61078)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 61079)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 61334)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 61335)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 61590)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 61591)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 61846)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 61847)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 62102)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 62103)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 62358)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 62359)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 62614)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 62615)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 62870)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 62871)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 63126)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 63127)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 63382)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 63383)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 63638)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 63639)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 63894)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 63895)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 64150)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 64151)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 64406)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 64407)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 64662)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 64663)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 64918)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 64919)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 65174)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 65175)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 65430)?(FB_addr_cnt + 105):
					FB_addr_cnt + 2;
					next_IM_A = 
					(FB_addr_cnt == FB_addr + 59542)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 59543)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 59878)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 59879)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 60054)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 60055)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 60310)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 60311)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 60566)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 60567)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 60822)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 60823)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 61078)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 61079)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 61334)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 61335)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 61590)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 61591)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 61846)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 61847)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 62102)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 62103)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 62358)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 62359)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 62614)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 62615)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 62870)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 62871)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 63126)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 63127)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 63382)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 63383)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 63638)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 63639)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 63894)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 63895)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 64150)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 64151)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 64406)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 64407)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 64662)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 64663)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 64918)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 64919)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 65174)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 65175)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 65430)?(FB_addr_cnt + 105):
					FB_addr_cnt + 2;
					end
				end
			end
		end
		
		else begin
			if(IM_WEN)begin//read 512
				if(pixel_num[1:0] == 2'b00)begin
					R1 = IM_Q[23:16];
					G1 = IM_Q[15:8];
					B1 = IM_Q[7:0];
					next_pixel_num = pixel_num + 1;
					next_IM_A = p1_addr_cnt + 1;
					next_IM_WEN = 1;
					p1_addr_nxt = p1_addr_cnt + 1;
					FB_addr_nxt = FB_addr_cnt;
					next_state = 2'b01;
				end
				else if(pixel_num[1:0] == 2'b01)begin
					R2 = IM_Q[23:16];
					G2 = IM_Q[15:8];
					B2 = IM_Q[7:0];
					next_pixel_num = pixel_num + 1;
					next_IM_A = p1_addr_cnt + 511;
					next_IM_WEN = 1;
					p1_addr_nxt = p1_addr_cnt + 511;
					FB_addr_nxt = FB_addr_cnt;
					next_state = 2'b01;
				end
				else if(pixel_num[1:0] == 2'b10)begin
					R3 = IM_Q[23:16];
					G3 = IM_Q[15:8];
					B3 = IM_Q[7:0];
					next_pixel_num = pixel_num + 1;
					next_IM_A = p1_addr_cnt + 1;
					next_IM_WEN = 1;
					p1_addr_nxt = p1_addr_cnt + 1;
					FB_addr_nxt = FB_addr_cnt;
					next_state = 2'b01;
				end
				else begin
					R4 = IM_Q[23:16];
					G4 = IM_Q[15:8];
					B4 = IM_Q[7:0];
					next_pixel_num = pixel_num + 1;
					next_IM_A = FB_addr;
					next_IM_WEN = 0;
					p1_addr_nxt = p1_addr_cnt -509;
					FB_addr_nxt = FB_addr_cnt;
					next_state = 2'b01;
				end
			end
			
			else begin//write 512
					next_IM_D = {(R1+R2+R3+R4)>>2,(G1+G2+G3+G4)>>2,(B1+B2+B3+B4)>>2};
					next_pixel_num = pixel_num + 1;
					//next_IM_A = FB_addr_cnt + 1;
					next_IM_WEN = 1;
					p1_addr_nxt = p1_addr_cnt + 1;
					//FB_addr_nxt = FB_addr + 1;
					if(FB_addr_cnt == FB_addr+65431)begin
						next_state = 2'b10;
						FB_addr_nxt = FB_addr + 59544;
						next_IM_A = FB_addr + 59544;
					end
					else begin
						next_state = 2'b01;
					FB_addr_nxt = (FB_addr_cnt == FB_addr + 59542)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 59543)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 59878)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 59879)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 60054)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 60055)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 60310)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 60311)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 60566)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 60567)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 60822)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 60823)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 61078)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 61079)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 61334)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 61335)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 61590)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 61591)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 61846)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 61847)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 62102)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 62103)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 62358)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 62359)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 62614)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 62615)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 62870)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 62871)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 63126)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 63127)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 63382)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 63383)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 63638)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 63639)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 63894)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 63895)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 64150)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 64151)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 64406)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 64407)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 64662)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 64663)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 64918)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 64919)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 65174)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 65175)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 65430)?(FB_addr_cnt + 105):
					FB_addr_cnt + 2;
					next_IM_A = 
					(FB_addr_cnt == FB_addr + 59542)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 59543)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 59878)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 59879)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 60054)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 60055)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 60310)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 60311)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 60566)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 60567)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 60822)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 60823)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 61078)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 61079)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 61334)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 61335)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 61590)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 61591)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 61846)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 61847)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 62102)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 62103)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 62358)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 62359)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 62614)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 62615)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 62870)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 62871)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 63126)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 63127)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 63382)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 63383)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 63638)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 63639)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 63894)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 63895)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 64150)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 64151)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 64406)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 64407)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 64662)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 64663)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 64918)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 64919)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 65174)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 65175)?(FB_addr_cnt + 105):
					(FB_addr_cnt == FB_addr + 65430)?(FB_addr_cnt + 105):
					FB_addr_cnt + 2;
					end
			end
		end
	end
	else if (state == 2'b10 )
	begin//display timer
		if(FB_addr_cnt == 59544)begin //char_cycle next_char_cycle hour/10 hour%10
			if(hour/10 == 0)begin
				next_CR_A = 0;
				next_state = 2'b11;
			end
			else if (hour/10 == 1)begin
				next_CR_A = 24;
				next_state = 2'b11;
			end
			else begin
				next_CR_A = 48;
				next_state = 2'b11;
			end
		end
		else if(FB_addr_cnt == 59557)begin
			if(hour%10 == 0)begin
				next_CR_A = 0;
				next_state = 2'b11;
			end
			else if(hour%10 == 1)begin
				next_CR_A = 24;
				next_state = 2'b11;
			end
			else if(hour%10 == 2)begin
				next_CR_A = 48;
				next_state = 2'b11;
			end
			else if(hour%10 == 3)begin
				next_CR_A = 72;
				next_state = 2'b11;
			end
			else begin
				next_CR_A = 96;
				next_state = 2'b11;
			end
		end
		else if(FB_addr_cnt == 59570)begin//:
			next_CR_A = 240;
			next_state = 2'b11;
		end
		else if(FB_addr_cnt == 59583)begin
			if(min/10 == 0)begin
				next_CR_A = 0;
				next_state = 2'b11;
			end
			else if(min/10 == 1)begin
				next_CR_A = 24;
				next_state = 2'b11;
			end
			else if(min/10 == 2)begin
				next_CR_A = 48;
				next_state = 2'b11;
			end
			else if(min/10 == 3)begin
				next_CR_A = 72;
				next_state = 2'b11;
			end
			else if(min/10 == 4)begin
				next_CR_A = 96;
				next_state = 2'b11;
			end
			else begin
				next_CR_A = 120;
				next_state = 2'b11;
			end
		end
		else if(FB_addr_cnt == 59596)begin
			if(min%10 == 0)begin
				next_CR_A = 0;
				next_state = 2'b11;
			end
			else if(min%10 == 1)begin
				next_CR_A = 24;
				next_state = 2'b11;
			end
			else if(min%10 == 2)begin
				next_CR_A = 48;
				next_state = 2'b11;
			end
			else if(min%10 == 3)begin
				next_CR_A = 72;
				next_state = 2'b11;
			end
			else if(min%10 == 4)begin
				next_CR_A = 96;
				next_state = 2'b11;
			end
			else if(min%10 == 5)begin
				next_CR_A = 120;
				next_state = 2'b11;
			end
			else if(min%10 == 6)begin
				next_CR_A = 144;
				next_state = 2'b11;
			end
			else if(min%10 == 7)begin
				next_CR_A = 168;
				next_state = 2'b11;
			end
			else if(min%10 == 8)begin
				next_CR_A = 192;
				next_state = 2'b11;
			end
			else begin
				next_CR_A = 216;
				next_state = 2'b11;
			end
		end
		else if(FB_addr_cnt == 59609)begin//:
			next_CR_A = 240;
			next_state = 2'b11;
		end
		else if(FB_addr_cnt == 59622)begin
			if(sec/10 == 0)begin
				next_CR_A = 0;
				next_state = 2'b11;
			end
			else if(sec/10 == 1)begin
				next_CR_A = 24;
				next_state = 2'b11;
			end
			else if(sec/10 == 2)begin
				next_CR_A = 48;
				next_state = 2'b11;
			end
			else if(sec/10 == 3)begin
				next_CR_A = 72;
				next_state = 2'b11;
			end
			else if(sec/10 == 4)begin
				next_CR_A = 96;
				next_state = 2'b11;
			end
			else begin
				next_CR_A = 120;
				next_state = 2'b11;
			end
		end
		else if(FB_addr_cnt == 59635)begin
			if(sec%10 == 0)begin
				next_CR_A = 0;
				next_state = 2'b11;
			end
			else if(sec%10 == 1)begin
				next_CR_A = 24;
				next_state = 2'b11;
			end
			else if(sec%10 == 2)begin
				next_CR_A = 48;
				next_state = 2'b11;
			end
			else if(sec%10 == 3)begin
				next_CR_A = 72;
				next_state = 2'b11;
			end
			else if(sec%10 == 4)begin
				next_CR_A = 96;
				next_state = 2'b11;
			end
			else if(sec%10 == 5)begin
				next_CR_A =120;
				next_state = 2'b11;
			end
			else if(sec%10 == 6)begin
				next_CR_A = 144;
				next_state = 2'b11;
			end
			else if(sec%10 == 7)begin
				next_CR_A = 168;
				next_state = 2'b11;
			end
			else if(sec%10 == 8)begin
				next_CR_A = 192;
				next_state = 2'b11;
			end
			else begin
				next_CR_A = 216;
				next_state = 2'b11;
			end
		end
	end
	else if(state == 2'b11)begin
		if(CR_Q[12])begin//write char
			next_IM_D = 24'hFFFFFF;
			next_IM_A = FB_addr_cnt;
			FB_addr_nxt = FB_addr_cnt + 1;
			next_state = 2'b11;
		end
		else begin
			next_IM_D = 24'h111111;
			next_IM_A = FB_addr_cnt;
			FB_addr_nxt = FB_addr_cnt + 1;
			next_state = 2'b11;
		end
		
		if(CR_Q[11])begin
			next_IM_D = 24'hFFFFFF;
			next_IM_A = FB_addr_cnt;
			FB_addr_nxt = FB_addr_cnt + 1;
			next_state = 2'b11;
		end
		else begin
			next_IM_D = 24'h111111;
			next_IM_A = FB_addr_cnt;
			FB_addr_nxt = FB_addr_cnt + 1;
			next_state = 2'b11;
		end
		
		if(CR_Q[10])begin
			next_IM_D = 24'hFFFFFF;
			next_IM_A = FB_addr_cnt;
			FB_addr_nxt = FB_addr_cnt + 1;
			next_state = 2'b11;
		end
		else begin
			next_IM_D = 24'h111111;
			next_IM_A = FB_addr_cnt;
			FB_addr_nxt = FB_addr_cnt + 1;
			next_state = 2'b11;
		end
		
		if(CR_Q[9])begin
			next_IM_D = 24'hFFFFFF;
			next_IM_A = FB_addr_cnt;
			FB_addr_nxt = FB_addr_cnt + 1;
			next_state = 2'b11;
		end
		else begin
			next_IM_D = 24'h111111;
			next_IM_A = FB_addr_cnt;
			FB_addr_nxt = FB_addr_cnt + 1;
			next_state = 2'b11;
		end
		
		if(CR_Q[8])begin
			next_IM_D = 24'hFFFFFF;
			next_IM_A = FB_addr_cnt;
			FB_addr_nxt = FB_addr_cnt + 1;
			next_state = 2'b11;
		end
		else begin
			next_IM_D = 24'h111111;
			next_IM_A = FB_addr_cnt;
			FB_addr_nxt = FB_addr_cnt + 1;
			next_state = 2'b11;
		end
		
		if(CR_Q[7])begin
			next_IM_D = 24'hFFFFFF;
			next_IM_A = FB_addr_cnt;
			FB_addr_nxt = FB_addr_cnt + 1;
			next_state = 2'b11;
		end
		else begin
			next_IM_D = 24'h111111;
			next_IM_A = FB_addr_cnt;
			FB_addr_nxt = FB_addr_cnt + 1;
			next_state = 2'b11;
		end
		
		if(CR_Q[6])begin
			next_IM_D = 24'hFFFFFF;
			next_IM_A = FB_addr_cnt;
			FB_addr_nxt = FB_addr_cnt + 1;
			next_state = 2'b11;
		end
		else begin
			next_IM_D = 24'h111111;
			next_IM_A = FB_addr_cnt;
			FB_addr_nxt = FB_addr_cnt + 1;
			next_state = 2'b11;
		end
		
		if(CR_Q[5])begin
			next_IM_D = 24'hFFFFFF;
			next_IM_A = FB_addr_cnt;
			FB_addr_nxt = FB_addr_cnt + 1;
			next_state = 2'b11;
		end
		else begin
			next_IM_D = 24'h111111;
			next_IM_A = FB_addr_cnt;
			FB_addr_nxt = FB_addr_cnt + 1;
			next_state = 2'b11;
		end
		
		if(CR_Q[4])begin
			next_IM_D = 24'hFFFFFF;
			next_IM_A = FB_addr_cnt;
			FB_addr_nxt = FB_addr_cnt + 1;
			next_state = 2'b11;
		end
		else begin
			next_IM_D = 24'h111111;
			next_IM_A = FB_addr_cnt;
			FB_addr_nxt = FB_addr_cnt + 1;
			next_state = 2'b11;
		end
		
		if(CR_Q[3])begin
			next_IM_D = 24'hFFFFFF;
			next_IM_A = FB_addr_cnt;
			FB_addr_nxt = FB_addr_cnt + 1;
			next_state = 2'b11;
		end
		else begin
			next_IM_D = 24'h111111;
			next_IM_A = FB_addr_cnt;
			FB_addr_nxt = FB_addr_cnt + 1;
			next_state = 2'b11;
		end
		
		if(CR_Q[2])begin
			next_IM_D = 24'hFFFFFF;
			next_IM_A = FB_addr_cnt;
			FB_addr_nxt = FB_addr_cnt + 1;
			next_state = 2'b11;
		end
		else begin
			next_IM_D = 24'h111111;
			next_IM_A = FB_addr_cnt;
			FB_addr_nxt = FB_addr_cnt + 1;
			next_state = 2'b11;
		end
		
		if(CR_Q[1])begin
			next_IM_D = 24'hFFFFFF;
			next_IM_A = FB_addr_cnt;
			FB_addr_nxt = FB_addr_cnt + 1;
			next_state = 2'b11;
		end
		else begin
			next_IM_D = 24'h111111;
			next_IM_A = FB_addr_cnt;
			FB_addr_nxt = FB_addr_cnt + 1;
			next_state = 2'b11;
		end
		
		if(CR_Q[0])begin
			next_IM_D = 24'hFFFFFF;
			next_IM_A = FB_addr_cnt;
			FB_addr_nxt = FB_addr_cnt + 1;
			next_state = 2'b11;
		end
		else begin
			next_IM_D = 24'h111111;
			next_IM_A = FB_addr_cnt;
			FB_addr_nxt = FB_addr_cnt + 1;
			next_state = 2'b11;
		end
	end
	
	else begin//initial
	if(cycle == 0)begin//do nothing
		p1_addr_nxt = p1_addr_cnt;
		p2_addr_nxt = p2_addr_cnt;
		p3_addr_nxt = p3_addr_cnt;
		p4_addr_nxt = p4_addr_cnt;
		FB_addr_nxt = FB_addr_cnt;
		next_IM_A = IM_A + 1;
		next_IM_D = 0;
		next_IM_WEN = 1;//read
		next_state = 2'b00;
	end
	else if(cycle == 1)begin
		p1_addr_nxt = p1_addr_cnt;
		p2_addr_nxt = p2_addr_cnt;
		p3_addr_nxt = p3_addr_cnt;
		p4_addr_nxt = p4_addr_cnt;
		FB_addr_nxt = FB_addr_cnt;
		next_IM_A = IM_A + 1;
		next_IM_D = 0;
		next_IM_WEN = 1;//read
		next_state = 2'b00;
	end
	else if(cycle == 2)begin//store FB_addr
		p1_addr_nxt = p1_addr_cnt;
		p2_addr_nxt = p2_addr_cnt;
		p3_addr_nxt = p3_addr_cnt;
		p4_addr_nxt = p4_addr_cnt;
		FB_addr_nxt = IM_Q;
		FB_addr = IM_Q;
		next_IM_A = IM_A + 1;
		next_IM_D = 0;
		next_IM_WEN = 1;//read
		next_state = 2'b00;
	end
	else if(cycle == 3)begin//store photo_num
		p1_addr_nxt = p1_addr_cnt;
		p2_addr_nxt = p2_addr_cnt;
		p3_addr_nxt = p3_addr_cnt;
		p4_addr_nxt = p4_addr_cnt;
		FB_addr_nxt = FB_addr_cnt;
		photo_num = IM_Q;
		next_IM_A = IM_A + 1;
		next_IM_D = 0;
		next_IM_WEN = 1;//read
		next_state = 0;
	end
	
	else if(cycle == 4 )begin//store p1_addr
		p1_addr = IM_Q;
		p2_addr_nxt = p2_addr_cnt;
		p3_addr_nxt = p3_addr_cnt;
		p4_addr_nxt = p4_addr_cnt;
		FB_addr_nxt = FB_addr_cnt;
		next_IM_A = IM_A + 1;
		next_IM_D = 0;
		next_IM_WEN = 1;//read
		next_state = 0;
	end
	else if(cycle == 5)begin//store p1_size
		p1_size = IM_Q;
		
		p2_addr_nxt = p2_addr_cnt;
		p3_addr_nxt = p3_addr_cnt;
		p4_addr_nxt = p4_addr_cnt;

		next_IM_D = 0;
		next_IM_WEN = 1;//read
		if(photo_num == 1)begin
			next_IM_A = (p1_size == 256)?(p1_addr+1):(p1_size == 512)?(p1_addr+2):(p1_addr);
			p1_addr_nxt = (p1_size == 256)?(p1_addr+1):(p1_size == 512)?(p1_addr+2):(p1_addr);
			next_state = 2'b01;
			FB_addr_nxt = FB_addr_cnt + 1;
		end
		else begin
			next_IM_A = IM_A + 1;
			p1_addr_nxt = p1_addr+1;
			next_state = 0;
			FB_addr_nxt = FB_addr_cnt;
		end
	end
	
	else if(cycle == 6)begin//store p2_addr
		p1_addr_nxt = p1_addr_cnt;
		p3_addr_nxt = p3_addr_cnt;
		p4_addr_nxt = p4_addr_cnt;
		FB_addr_nxt = FB_addr_cnt;
		p2_addr = IM_Q;
		next_IM_A = IM_A + 1;
		next_IM_D = 0;
		next_IM_WEN = 1;//read
		next_state = 0;
	end
	else if(cycle == 7)begin//store p2_size
		p2_size = IM_Q;
		//p1_addr_nxt = p1_addr_cnt;
		p2_addr_nxt = p2_addr;
		p3_addr_nxt = p3_addr_cnt;
		p4_addr_nxt = p4_addr_cnt;
		FB_addr_nxt = FB_addr_cnt;
		next_IM_D = 0;
		next_IM_WEN = 1;//read
		if(photo_num == 2)begin
			next_IM_A = (p1_size == 256)?(p1_addr+1):(p1_size == 512)?(p1_addr+2):(p1_addr);
			p1_addr_nxt = (p1_size == 256)?(p1_addr+1):(p1_size == 512)?(p1_addr+2):(p1_addr);
			next_state = 2'b01;
			FB_addr_nxt = FB_addr_cnt + 1;
		end
		else begin
			next_IM_A = IM_A + 1;
			p1_addr_nxt = p1_addr;
			next_state = 0;
			FB_addr_nxt = FB_addr_cnt;
		end
	end
	
	else if(cycle == 8)begin//store p3_addr
		p3_addr = IM_Q;
		p1_addr_nxt = p1_addr_cnt;
		p2_addr_nxt = p2_addr_cnt;
		p4_addr_nxt = p4_addr_cnt;
		FB_addr_nxt = FB_addr_cnt;
		next_IM_A = IM_A + 1;
		next_IM_D = 0;
		next_IM_WEN = 1;//read
		next_state = 2'b00;
	end
	else if(cycle == 9)begin//store p3_size
		p3_size = IM_Q;
		//p1_addr_nxt = p1_addr_cnt;
		p2_addr_nxt = p2_addr_cnt;
		p3_addr_nxt = p3_addr;
		p4_addr_nxt = p4_addr_cnt;
		FB_addr_nxt = FB_addr_cnt;
		next_IM_D = 0;
		next_IM_WEN = 1;//read
		if(photo_num == 3)begin
			next_IM_A = (p1_size == 256)?(p1_addr+1):(p1_size == 512)?(p1_addr+2):(p1_addr);
			p1_addr_nxt = (p1_size == 256)?(p1_addr+1):(p1_size == 512)?(p1_addr+2):(p1_addr);
			next_state = 2'b01;
			FB_addr_nxt = FB_addr_cnt + 1;
		end
		else begin
			next_IM_A = IM_A + 1;
			p1_addr_nxt = p1_addr;
			next_state = 2'b00;
			FB_addr_nxt = FB_addr_cnt;
		end
	end
	
	else if(cycle == 10)begin//store p4_addr
		p4_addr = IM_Q;
		p1_addr_nxt = p1_addr_cnt;
		p2_addr_nxt = p2_addr_cnt;
		p3_addr_nxt = p3_addr_cnt;
		p4_addr_nxt = p4_addr;
		FB_addr_nxt = FB_addr_cnt;
		next_IM_A = IM_A + 1;
		next_IM_D = 0;
		next_IM_WEN = 1;//read
		next_state = 2'b00;
	end
	else if(cycle == 11)begin//store p4_size
		p4_size = IM_Q;
		p1_addr_nxt = (p1_size == 256)?(p1_addr+1):(p1_size == 512)?(p1_addr+2):(p1_addr);
		p2_addr_nxt = p2_addr_cnt;
		p3_addr_nxt = p3_addr_cnt;
		p4_addr_nxt = p4_addr_cnt;
		FB_addr_nxt = FB_addr_cnt + 1;
		next_IM_D = 0;
		next_IM_WEN = 1;//read
		next_IM_A = (p1_size == 256)?(p1_addr+1):(p1_size == 512)?(p1_addr+2):(p1_addr);
		next_state = 2'b01;
	end
	end
end

//timer
always@(*)begin
	next_cycle = cycle + 1;
	if((next_cycle % A_SEC_CYCLE) == 0)begin
		next_sec = sec + 1;
		if(next_sec == 59)begin
			next_sec = 0;
			next_min = min + 1;
			if(next_min == 59)begin
				next_min = 0;
				next_hour = hour + 1;
				if(next_hour == 24)
					next_hour = 0;
			end
		end
	end
end

//sequential
//timer
always@(posedge clk)begin
	if(cycle == 1)begin
		hour <= IM_Q[23:0];
		min <= IM_Q[15:8];
		sec <= IM_Q[7:0];
	end
	else begin
		hour <= next_hour;
		min <= next_min;
		sec <= next_sec;
	end
end

//control factor
//sequential
always@(posedge clk or posedge reset)begin
	if(reset)begin
		IM_A <= 20'd0;
		IM_D <= 24'd0;
		IM_WEN <= 1'd1;//low is write
		CR_A <= 9'd0;
		cycle <= 0;
		p1_addr_cnt <= 0;
		p2_addr_cnt <= 0;
		p3_addr_cnt <= 0;
		p4_addr_cnt <= 0;
		FB_addr_cnt <= 0;
		pixel_num <= 0;
		state <= 0;
		pic_count <= 0;
	end
	else begin
		IM_A <= next_IM_A;
		IM_D <= next_IM_D;
		IM_WEN <= next_IM_WEN;
		CR_A <= next_CR_A;
		cycle <= next_cycle;
		p1_addr_cnt <= p1_addr_nxt;
		p2_addr_cnt <= p2_addr_nxt;
		p3_addr_cnt <= p3_addr_nxt;
		p4_addr_cnt <= p4_addr_nxt;
		FB_addr_cnt <= FB_addr_nxt;
		pixel_num <= next_pixel_num;
		state <= next_state;
	end
end
endmodule

