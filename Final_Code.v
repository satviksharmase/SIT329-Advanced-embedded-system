module blink(
		input wire clk,
		input wire reset,
		inout wire sda,
		output wire scl,
		output reg [7:0] data,
		output reg [7:0] state,
//		output wire i2c_clk,
		output reg i2c_clk,
		output wire [7:0] LED
		
    );
	localparam STATE_IDLE				=0;	//	
	localparam STATE_START_WRITE		=1;	//	
	localparam STATE_I2C_ADD_CALL1	=2;	//	
	localparam STATE_RW1					=3;	//	
	localparam STATE_ACK1				=4;
	localparam STATE_REG_ADD1			=5;
	localparam STATE_ACK2				=6;	//
	localparam STATE_START_READ		=7;
	localparam STATE_I2C_ADD_CALL2	=8;	//	
	localparam STATE_RW2 				=9;	//	
	localparam STATE_ACK3				=10;	//	
	localparam STATE_DATA				=11;	//	
	localparam STATE_ACK4				=12;	//	
	localparam STATE_STOP				=13;	//
	localparam STATE_REG_ADD			=14;
	
	reg on;
	reg[27:0] clk_counter = 28'd0;
	reg [7:0] addr;
	reg [6:0] adcall;
	reg [7:0] count;
	reg ack1;
	reg ack2;
	reg ack3;
	reg sda_reg;
//	reg i2c_clk[9:0];
	reg scl_enable;
	reg rw1;
	reg rw2;
	parameter DIVISOR = 6'd50;
	initial scl_enable<=0;
	
//	i2c_clk_divider instance_name (
//    .clk(clk), 
//    .reset(reset), 
//    .i2c_clk(i2c_clk)
//    );
	
	assign scl=(scl_enable==0) ? 1:~i2c_clk;
	assign sda=sda_reg;
	
	always @ (posedge clk) begin
		clk_counter <= clk_counter + 1;
		if(clk_counter >= 50000000)
			clk_counter <= 28'd0;
			i2c_clk <= (clk_counter<DIVISOR/2)?1'b1:1'b0;
		end
	always @(posedge i2c_clk) begin
		if(reset==1)begin
		scl_enable<=0;
		sda_reg<=1;
		state<=STATE_IDLE;
		adcall<=8'b00101001;
		addr<=7'b1110111; //address of slave device
		rw1<=0;
		rw2<=1;
		data<=8'b10101010;
		end
		else begin
			case(state)
			
				STATE_IDLE:	
					begin 	//IDDLE
						sda_reg<=1;
						state<=STATE_START_WRITE;
						scl_enable<=0;
						on <= 1'b1;
					end 		
					
				STATE_START_WRITE:
					begin		//START
						sda_reg<=0;
						state<=STATE_I2C_ADD_CALL1;
						scl_enable <= 0;
						count<=6;
					end
				
				STATE_I2C_ADD_CALL1:
					begin
						sda_reg<=adcall[count];
						scl_enable<=1;
						if(count==0) state<=STATE_RW1;
						else count<=count-1;
					end
				STATE_RW1:
					begin
						sda_reg<=rw1;
						state<=STATE_ACK1;
						scl_enable<=1;
						count<=7;
						
					end
					
				STATE_ACK1:
					begin
						sda_reg<=1'bz;
						state<=STATE_REG_ADD1;
						scl_enable<=1;
						on <= 1'b1;
					end
					
				STATE_REG_ADD1:
					begin
						sda_reg<=addr[count];
						scl_enable<=1;
						if(count==0) state<=STATE_ACK2;
						else count<=count-1;
					end
							
				STATE_ACK2:
					begin
						sda_reg<=1'bz;
						state<=STATE_START_READ;
						scl_enable<=1;	
					end
					
				STATE_START_READ:
					begin
						sda_reg<=0;
						state<=STATE_I2C_ADD_CALL2;
						scl_enable<=0;
						count<=6;
					end
					
				STATE_I2C_ADD_CALL2:	
					begin		//MSB ADDRESS BIT
						sda_reg<=addr[count];
						scl_enable<=1;
						if(count==0) state<=STATE_RW2;
						else count<=count-1;
					end
					
				STATE_RW2:
					begin		//BIT 5
						sda_reg<=rw2;
						state<=STATE_ACK3;
						scl_enable<=1;
					end
				
				STATE_ACK3:
					begin
						sda_reg<=1'bz;
						state<=STATE_DATA;
						scl_enable<=1;
						count<=7;
					end
			
				STATE_DATA:
					begin
						sda_reg<=1'bz;
						scl_enable<=1;
						data[count]<=sda_reg;
						if(count==0) state<=STATE_ACK4;
						else count<=count-1;
					end
				
				STATE_ACK4:
					begin
						sda_reg<=1'bz;
						scl_enable<=1;
						state<=STATE_STOP;
					end
					
				STATE_STOP:
					begin
						sda_reg<=1;
						scl_enable<=0;
						state<=STATE_IDLE;
					end
			endcase
		end//end else
	
	end	// end always
	assign LED[0] = on;

endmodule