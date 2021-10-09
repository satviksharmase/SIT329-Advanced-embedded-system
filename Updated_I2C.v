module i2cio3(
		input wire clk,
		input wire reset,
		inout wire sda,
		output wire scl,
		output reg [7:0] data,
		output reg [7:0] state,
		output wire i2c_clk
		
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
	
	 
	 
	reg [7:0] addr;
	reg [6:0] adcall;
	reg [7:0] count;
	reg ack1;
	reg ack2;
	reg ack3;
	reg sda_reg;
	
	reg scl_enable;
	reg rw1;
	reg rw2;
	initial scl_enable<=0;
	
	//Initial Implementation with clock divider
	i2c_clk_divider instance_name (
    .clk(clk), 
    .reset(reset), 
    .i2c_clk(i2c_clk)
    );
	
	assign scl=(scl_enable==0) ? 1:~i2c_clk;
	assign sda=sda_reg;
	
	always @ (posedge i2c_clk)begin
		if(reset==1)begin
		scl_enable<=0;
		sda_reg<=1;
		state<=STATE_IDLE;
		adcall<=8'b00101001;
		addr<=7'b1110111;//'h0x98;
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
endmodule