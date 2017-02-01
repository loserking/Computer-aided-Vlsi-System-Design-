module CONV ( clk, reset, Din, in_en, busy, out_valid, Dout);
input   clk;
input   reset;
input   in_en;
output reg busy;
output reg out_valid;
reg next_busy, next_out_valid;
input   [3:0]  Din;
output reg[7:0]  Dout;
reg [7:0]next_Dout;
reg [3:0] count, next_count;
reg [3:0] f [0:7];
reg [3:0] g [0:7];
integer i;

//combination
always@(*)
begin//input
	if(in_en==1)begin
	case(count)
		4'b0000:
		begin
			f[0] = Din[3:0];
			next_count = count + 1;
			next_busy = 1'b0;
			next_out_valid = 0;
		end
		4'b0001:
		begin
			f[1] = Din[3:0];
			next_count = count + 1;
			next_busy = 1'b0;
			next_out_valid = 0;
		end
		4'b0010:
		begin
			f[2] = Din[3:0];
			next_count = count + 1;
			next_busy = 1'b0;
			next_out_valid = 0;
		end
		4'b0011:
		begin
			f[3] = Din[3:0];
			next_count = count + 1;
			next_busy = 1'b0;
			next_out_valid = 0;
		end
		4'b0100:
		begin
			f[4] = Din[3:0];
			next_count = count + 1;
			next_busy = 1'b0;
			next_out_valid = 0;
		end
		4'b0101:
		begin
			f[5] = Din[3:0];
			next_count = count + 1;
			next_busy = 1'b0;
			next_out_valid = 0;
		end
		4'b0110:
		begin
			f[6] = Din[3:0];
			next_count = count + 1;
			next_busy = 1'b0;
			next_out_valid = 0;
		end
		4'b0111:
		begin
			f[7] = Din[3:0];
			next_count = count + 1;
			next_busy = 1'b0;
			next_out_valid = 0;
		end
		4'b1000:
		begin
			g[0] = Din[3:0];
			next_count = count + 1;
			next_busy = 1'b1;
			next_out_valid = 1;
		end
		4'b1001:
		begin
			g[1] = Din[3:0];
			next_count = count + 1;
			next_busy = 1'b0;
			next_out_valid = 0;
		end
		4'b1010:
		begin
			g[2] = Din[3:0];
			next_count = count + 1;
			next_busy = 1'b0;
			next_out_valid = 0;
		end
		4'b1011:
		begin
			g[3] = Din[3:0];
			next_count = count + 1;
			next_busy = 1'b0;
			next_out_valid = 0;
		end
		4'b1100:
		begin
			g[4] = Din[3:0];
			next_count = count + 1;
			next_busy = 1'b0;
			next_out_valid = 0;
		end
		4'b1101:
		begin
			g[5] = Din[3:0];
			next_count = count + 1;
			next_busy = 1'b0;
			next_out_valid = 0;
		end
		4'b1110:
		begin
			g[6] = Din[3:0];
			next_count = count + 1;
			next_busy = 1'b0;
			next_out_valid = 0;
		end
		4'b1111:
		begin
			g[7] = Din[3:0];
			next_count = count + 1;
			next_busy = 1'b1;
			next_out_valid = 0;
		end
		endcase
	end
	else if(busy==1)begin
	case(count)
		4'b1001:
		begin
			next_Dout = f[0]*g[0];
			next_count = count + 1;
			next_busy = 1'b1;
			next_out_valid = 1;
		end
		4'b1010:
		begin
			next_Dout = f[0]*g[1]+f[1]*g[0];
			next_count = count + 1;
			next_busy = 1'b1;
			next_out_valid = 1;
		end
		4'b1011:
		begin
			next_Dout = f[0]*g[2]+f[1]*g[1]+f[2]*g[0];
			next_count = count + 1;
			next_busy = 1'b1;
			next_out_valid = 1;
		end
		4'b1100:
		begin
			next_Dout = f[0]*g[3]+f[1]*g[2]+f[2]*g[1]+f[3]*g[0];
			next_count = count + 1;
			next_busy = 1'b1;
			next_out_valid = 1;
		end
		4'b1101:
		begin
			next_Dout = f[0]*g[4]+f[1]*g[3]+f[2]*g[2]+f[3]*g[1]+f[4]*g[0];
			next_count = count + 1;
			next_busy = 1'b1;
			next_out_valid = 1;
		end
		4'b1110:
		begin
			next_Dout = f[0]*g[5]+f[1]*g[4]+f[2]*g[3]+f[3]*g[2]+f[4]*g[1]+f[5]*g[0];
			next_count = count + 1;
			next_busy = 1'b1;
			next_out_valid = 1;
		end
		4'b1111:
		begin
			next_Dout = f[0]*g[6]+f[1]*g[5]+f[2]*g[4]+f[3]*g[3]+f[4]*g[2]+f[5]*g[1]+f[6]*g[0];
			next_count = count + 1;
			next_busy = 1'b1;
			next_out_valid = 1;
		end
		4'b0000:
		begin
			next_Dout = f[0]*g[7]+f[1]*g[6]+f[2]*g[5]+f[3]*g[4]+f[4]*g[3]+f[5]*g[2]+f[6]*g[1]+f[7]*g[0];
			next_count = count + 1;
			next_busy = 1'b1;
			next_out_valid = 1;
		end
		4'b0001:
		begin
			next_Dout = f[1]*g[7]+f[2]*g[6]+f[3]*g[5]+f[4]*g[4]+f[5]*g[3]+f[6]*g[2]+f[7]*g[1];
			next_count = count + 1;
			next_busy = 1'b1;
		end
		4'b0010:
		begin
			next_Dout = f[2]*g[7]+f[3]*g[6]+f[4]*g[5]+f[5]*g[4]+f[6]*g[3]+f[7]*g[2];
			next_count = count + 1;
			next_busy = 1'b1;
			next_out_valid = 1;
		end
		4'b0011:
		begin
			next_Dout = f[3]*g[7]+f[4]*g[6]+f[5]*g[5]+f[6]*g[4]+f[7]*g[3];
			next_count = count + 1;
			next_busy = 1'b1;
			next_out_valid = 1;
		end
		4'b0100:
		begin
			next_Dout = f[4]*g[7]+f[5]*g[6]+f[6]*g[5]+f[7]*g[4];
			next_count = count + 1;
			next_busy = 1'b1;
			next_out_valid = 1;
		end
		4'b0101:
		begin
			next_Dout = f[5]*g[7]+f[6]*g[6]+f[7]*g[5];
			next_count = count + 1;
			next_busy = 1'b1;
			next_out_valid = 1;
		end
		4'b0110:
		begin
			next_Dout = f[6]*g[7]+f[7]*g[6];
			next_count = count + 1;
			next_busy = 1'b1;
			next_out_valid = 1;
		end
		4'b0111:
		begin
			next_Dout = f[7]*g[7];
			next_count = 0;
			next_busy = 1'b0;
			next_out_valid = 1;
		end
		endcase
	end
	else begin
		next_Dout = 0;
		next_count = count;
		next_busy = 1'b0;
		next_out_valid = 0;
	end
end

//sequential
always@(posedge clk or posedge reset)
begin
	if(reset)
	begin
		Dout <= 8'd0;	
		count <= 4'd0;
		busy <= 1'b0;
		out_valid <= 1'b0;
		for ( i = 0 ; i < 8 ; i = i+1 ) begin
			f[i] <= 4'd0;
			g[i] <= 4'd0;
		end
	end
	else begin
		Dout <= next_Dout;
		count <= next_count;
		busy <= next_busy;
		out_valid <= next_out_valid;
	end
end
endmodule
