module CONV ( clk, reset, Din, in_en, busy, out_valid, Dout);
input   clk;
input   reset;
input   in_en;
output reg busy;
output reg out_valid;
reg nxt_busy, nxt_out_valid;
input   [3:0]  Din;
output reg[7:0]  Dout;
reg [7:0]nxt_Dout;
reg [3:0] count, nxt_count;
reg [1:0] state, nxt_state;
reg [3:0] f [0:7];
reg [3:0] g [0:7];
integer i;
parameter IDLE = 2'd0, IN  = 2'd1, CAL = 2'd2, OUT = 2'd3;

//state machine
always@(*)begin
	if(state == IDLE)begin
		nxt_state = IN;
		nxt_out_valid = 0;
		nxt_busy = 0;
	end
	else if(state == IN && count == 8)begin
		nxt_state = CAL;
		nxt_out_valid = 1;
		nxt_busy = 0;
	end
	else if(state == CAL && count == 16)begin
		nxt_state = OUT;
		nxt_out_valid =1;
		nxt_busy = 1;
	end
	else if(state == OUT && count ==24)begin
		nxt_state = IDLE;
		nxt_out_valid = 0;
		nxt_busy = 1;
	end
	else begin
		nxt_state = state;
		nxt_out_valid = out_valid;
		nxt_busy = 1;
	end
end

//combination
always@(*)begin
	case(state)
	IDLE:begin
		nxt_Dout = 0;
		nxt_count = 0;
	end
	IN:begin
		nxt_Dout = 0;
		nxt_count = count + 1;
	end
	CAL:begin
		for(i=0;i<8;i=i+1)
			nxt_Dout = f[i]*g[i];
		nxt_count = count + 1;
	end
	OUT:begin
		for(i=0;i<8;i=i+1)
			nxt_Dout = f[i]*g[i];
		nxt_count = count + 1;
	end
	default:begin
		nxt_Dout = 0;
		nxt_count = 0;
	end
	endcase
end

//sequential
always@(posedge clk or posedge reset)
begin
	if(reset)
	begin
		state <= IDLE;
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
		state <= nxt_state;
		Dout <= nxt_Dout;
		count <= nxt_count;
		busy <= nxt_busy;
		out_valid <= nxt_out_valid;
		if(count < 8)begin
			f[7] <= Din;
			for ( i = 0 ; i < 7 ; i = i+1 ) begin
				f[i] <= f[i+1];
				g[i] <= 4'd0;
			end
		end
		else begin
			g[0] <= Din;
			for ( i = 7 ; i > 0 ; i = i-1 ) begin
				f[i] <= f[i];
				g[i] <= g[i-1];
			end
		end
	end
end
endmodule
