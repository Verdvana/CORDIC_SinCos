`timescale 1ns/1ns

module CordicSinCos_TB;

reg clk;
reg rst_n;


reg  [31:0] phase;


wire signed [31:0] sin;
wire signed [31:0] cos;

wire valid_sincos;

CORDIC #(
		.DATA_WIDTH(32),
		.EXPAND_BIT(16),
		.CYCLES(5) 
)u_CORDIC(
		.clk(clk), 
		.rst_n(rst_n), 
		
		.phase(phase), 	//输入坐标（有符号）
		
		.valid_sincos(valid_sincos),
		
		.sin(sin),
		.cos(cos)
); 

initial begin

	clk = 0;
	forever #(10) 
	clk = ~clk;
	
end

task task_rst;
begin
	rst_n <= 0;
	repeat(2)@(negedge clk);
	rst_n <= 1;
end
endtask

task task_sysinit;
begin
	phase <= 32'd7864320;
end
endtask

initial
begin
	task_sysinit;
	task_rst;
	#10;
	
	
	
	
	
	

	
	
	
	
	
	
	
end

endmodule
