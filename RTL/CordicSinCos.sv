//------------------------------------------------------------------------------
//
//Module Name:					CordicSinCos.v
//Department:					Xidian University
//Function Description:	   角度求正弦余弦
//
//------------------------------------------------------------------------------
//
//Version 	Design		Coding		Simulata	  Review		Rel data
//V1.0		Verdvana		Verdvana		Verdvana		  			2019-11-25
//
//-----------------------------------------------------------------------------------
//
//Version	Modified History
//V1.0		输入角度为0-359°，可以提前放大2^EXPAND_BIT倍；
//				正弦余弦分别输出，同样也为放大2^EXPAND_BIT倍厚的结果，精度0.0001。
//
//-----------------------------------------------------------------------------------

`timescale 1ns/1ns

module CordicSinCos#(
		parameter 	DATA_WIDTH = 32,					//输入数据宽度
						EXPAND_BIT = 16,					//输入放大左移位数
						CYCLES	  = 5  					//迭代次数：最多迭代2**CYCLES次
)(
		input										clk,		//时钟
		input										rst_n,	//异步复位
		
		input  			[DATA_WIDTH-1:0]	phase, 	//输入角度（0-359°）
		
		output									valid,	//输出有效
		
		output signed 	[DATA_WIDTH-1:0]	sin,		//正弦
		output signed 	[DATA_WIDTH-1:0]	cos		//余弦
);

	parameter DATA_NUM = 2**CYCLES;
	parameter GAIN_COEFF = 0.607253*(2**EXPAND_BIT);		//所有余弦相加得出的增益系数
	
	
	//=====================================================
	//迭代计数器:最多迭代2**CYCLES次
	
	reg [CYCLES-1:0] 		cnt_cycles;
	
	always_ff@(posedge clk or negedge rst_n) begin
		
		if(!rst_n) 
			cnt_cycles <= '0;
		
		else
			cnt_cycles <= cnt_cycles + 1;
	
	end



	//=====================================================
	//迭代循环
	
	reg signed  [DATA_WIDTH-1:0]	x_cycles, y_cycles;	//迭代中间变量寄存器
	reg signed  [DATA_WIDTH-1:0]	z;							//旋转角度寄存器
	reg									valid_r;					//输出有效寄存器
	reg         [1:0]					quadrant;				//象限
	
	wire        [DATA_WIDTH-1:0] 	z_w;						//ROM中角度数据
	

	
	always_ff@(posedge clk or negedge rst_n) begin
	
		if(!rst_n) begin
		
			x_cycles <= '0;
			y_cycles <= '0;
			z			<= 0;
			valid_r  <= 0;
			
		end
		
		else begin
		
			if(cnt_cycles=='0) begin			//第0个循环，输入数据初始化
				
				if (phase < (90*(2**EXPAND_BIT))) begin		//判断1象限
					
					x_cycles <= GAIN_COEFF;
					y_cycles <= 0;
					z			<= phase;
					quadrant <= 2'b00;
								
				end
					
				else if ((phase >= (90*(2**EXPAND_BIT)))&&(phase < (180*(2**EXPAND_BIT)))) begin		//判断2象限
					
					x_cycles <= GAIN_COEFF;
					y_cycles <= 0;
					z			<= phase - (90*(2**EXPAND_BIT));  		//转到第1象限
					quadrant <= 2'b01;
					
				end
					
				else if ((phase >= (180*(2**EXPAND_BIT)))&&(phase < (270*(2**EXPAND_BIT)))) begin		//判断3象限
					
					x_cycles <= GAIN_COEFF;
					y_cycles <= 0;
					z			<= phase - (180*(2**EXPAND_BIT));		//转到第1象限
					quadrant <= 2'b10;
					
				end
					
				else if ((phase >= (270*(2**EXPAND_BIT)))&&(phase < (360*(2**EXPAND_BIT)))) begin		//判断4象限
					
					x_cycles <= GAIN_COEFF;
					y_cycles <= 0;
					z			<= phase - (270*(2**EXPAND_BIT));		//转到第1象限
					quadrant <= 2'b11;
					
				end
				
				else begin
				
					x_cycles <= 'z;
					y_cycles <= 'z;
					z			<= 'z;
					quadrant <= 2'bz;
				
				end
		
				valid_r  <= 0;
			
			end
			
			else begin
			
				if(z == '0) begin										//如果z坐标为0即为迭代完毕，数据保持不变	
					
					x_cycles <= x_cycles;
					y_cycles <= y_cycles;
					z			<= z ;
					valid_r  <= 1;
				
				end
			
				else if(z[DATA_WIDTH-1] == 0) begin				//如果z大于0，继续正向旋转（顺时针）
					
					x_cycles <= x_cycles - (y_cycles>>>(cnt_cycles-1));
					y_cycles <= y_cycles + (x_cycles>>>(cnt_cycles-1));
					z			<= z - z_w;
					
				end
				
				else begin												//如果z小于0，反向旋转（逆时针）
					
					x_cycles <= x_cycles + (y_cycles>>>(cnt_cycles-1));
					y_cycles <= y_cycles - (x_cycles>>>(cnt_cycles-1));
					z			<= z + z_w;
					
				end			
				
			end
		
		end
		
	end
	
	
	//======================================================
	//正弦余弦输出
	
	reg signed  [DATA_WIDTH-1:0]	x, y;	//迭代中间变量寄存器	
	
	always@(*) begin
	
		case ({valid_r,quadrant})
			
			3'b100: begin
				x <= x_cycles;
				y <= y_cycles;
			end
			
			3'b101:begin
				x <= -y_cycles;
				y <= x_cycles;
			end
			
			3'b110:begin
				x <= -x_cycles;
				y <= -y_cycles;
			end
			
			3'b111:begin
				x <= y_cycles;
				y <= -x_cycles;
			end
			
			default: begin
				x <= 'z;
				y <= 'z;
			end
		
		endcase				
	
	end
	
	assign 	valid = valid_r;
	
	assign  	sin = y_cycles;
	assign  	cos = x_cycles;
	
	
	//======================================================
	//Intel 1-Port ROM 
	//存储atan(θ)=2^(-i)中的θ
	
	ROM_Atan	ROM_Atan_inst (
	.address ( cnt_cycles ),	//地址
	.clock ( clk ),				//时钟
	.q ( z_w )						//数据
	);	

endmodule
