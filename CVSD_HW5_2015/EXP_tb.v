`timescale 1ns/10ps
`define CYCLE 10
`define GOLDEN_0   "./gold_0.dat"    
`define GOLDEN_1   "./gold_1.dat"
`define GOLDEN_2   "./gold_2.dat"
`define GOLDEN_3   "./gold_3.dat"

module test_EXP;

parameter N_DATAOUT  = 10; 
parameter N_DATAIN   = 4;

integer i, n, in_cnt, out_cnt, error_cnt, correct_cnt;

reg   		  clk;
reg   		  reset;
reg   [1:0]   datain;
reg			  input_valid;
wire  [9:0]   dataout;
wire  		  out_valid;
wire  		  busy;
wire  		  finish;

//reg   [9:0]   gol_mem_0   [0:N_DATAOUT-1];
//reg   [9:0]   gol_mem_1   [0:N_DATAOUT-1];
//reg   [9:0]   gol_mem_2   [0:N_DATAOUT-1];
//reg   [9:0]   gol_mem_3   [0:N_DATAOUT-1];
reg   [9:0]   ANS_mem     [0:N_DATAOUT-1];
reg			  over;


   EXP EXP ( .clk(clk), .reset(reset), .datain(datain), .input_valid(input_valid),
			.dataout(dataout), .output_valid(out_valid), .busy(busy),  .finish(finish) ); 			
/*   
initial	begin
$readmemh (`GOLDEN_0, gol_mem_0);
$readmemh (`GOLDEN_1, gol_mem_1);
$readmemh (`GOLDEN_2, gol_mem_2);
$readmemh (`GOLDEN_3, gol_mem_3);
end
*/
initial begin
#0;
	clk         = 1'b0;
    reset       = 1'b0;
    datain      = 2'd0;   
    input_valid = 1'b0;
	i = 0;
	n = 0;
	in_cnt = 0;
	out_cnt = 0;
	error_cnt = 0;
	correct_cnt = 0;
	for (i = 0 ; i < N_DATAOUT ; i = i + 1)
		ANS_mem[i] = 10'd0;
	over = 0;
	#(`CYCLE*1.2) reset = 1'b1;
	#(`CYCLE*0.3) reset = 1'b0;
	
	#(`CYCLE*0.7);
	while ( in_cnt < N_DATAIN) begin
		if (!busy) begin
			case(in_cnt)
			0: $readmemb (`GOLDEN_0, ANS_mem);
			1: $readmemb (`GOLDEN_1, ANS_mem);
			2: $readmemb (`GOLDEN_2, ANS_mem);
			3: $readmemb (`GOLDEN_3, ANS_mem);
			endcase
			
			datain = in_cnt;
			input_valid = 1'b1;
			#(`CYCLE*0.9);
			input_valid = 1'b0;
			
			in_cnt = in_cnt + 1;
			$display("----------------------------------------------------------");
			$display("                                                          ");
			$display("                         x = %d                           ", datain);
			$display("                                                          ");
			$display("----------------------------------------------------------\n");
			
		end
		
		if (finish) begin
			out_cnt = 0;
		end
		@(negedge clk); 
	end
end

initial begin
$dumpfile("EXP.vcd");
$dumpvars;
end

always begin #(`CYCLE/2) clk = ~clk; end

always@(posedge clk) begin
	if (out_valid && out_cnt < N_DATAOUT) begin
		if (dataout == ANS_mem[out_cnt]) begin
			$display("Pass ! k = %d ; Dataout = %b ; ANS = %b", out_cnt, dataout, ANS_mem[out_cnt]);
			correct_cnt = correct_cnt + 1;
		end
		else begin
			$display("ERROR at k =%d, Dataout = %b != expect ANS %b", out_cnt, dataout, ANS_mem[out_cnt]);
			error_cnt = error_cnt + 1;
		end
		out_cnt = out_cnt + 1;
		n = n + 1;
	end
	if (n == 40) over = 1'b1;
end

initial begin
	@(posedge over)
	if (over && n != 0) begin
		if (error_cnt == 0 && correct_cnt != 0) begin
			$display("----------------------------------------------------------");
			$display("                                                          ");
			$display("  Congratulations! Your design hase passed all the test!  ");
			$display("                                                          ");
			$display("----------------------------------------------------------");
			
		end
		else begin
			$display("There are %d errors!\n", error_cnt);
		end
		#(`CYCLE); $finish;
	end
end

endmodule