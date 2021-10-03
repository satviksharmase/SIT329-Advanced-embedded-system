module BMP280(

	input 		          		FPGA_CLK1_50,
	// input 		          		FPGA_CLK2_50,
	// input 		          		FPGA_CLK3_50,

	input 		     [1:0]		KEY,

	input 		     [3:0]		SW
);


wire					reset_n;			// reset signal

localparam STATE_IDLE = 0;
localparam STATE_START = 1;
localparam STATE_ADDRESS = 2;
localparam STATE_RW = 3;
localparam STATE_WACK = 4;
localparam STATE_DATA = 5;
localparam STATE_STOP = 6;
localparam STATE_WACK2 = 7;

reg					GO;				// trigger to start
reg					i2c_sda;			// register value for Slave data
reg					i2c_scl;			// register value for SlavecClock by master
reg		[9:0]		i2c_clk_count;	// delayed clock for i2c bus
reg		[7:0]		state;			// where we maintain our state
reg		[7:0]		address;			// address of Slave device
reg		[7:0]		count;			// counting bits in byte to support IO
reg		[7:0]		data;				// data will be kept here

assign	reset_n = KEY[0];			// link reset to KEY[0]

//Our delayed clock implementation
always @ (posedge FPGA_CLK1_50) i2c_clk_count <= i2c_clk_count + 1;

//Build our i2c clock
always @ (posedge i2c_clk_count[9] or negedge reset_n)
begin
	if (!reset_n)
		i2c_scl <= 1;
	else begin
		if((state == STATE_IDLE) || (state == STATE_START) || (state == STATE_STOP)) begin
			i2c_scl <= 1;
		end
		else begin
			i2c_scl <= ~i2c_scl;
		end
	end
end

// Control trigger and read reset signal if there
always @ (posedge i2c_clk_count[9] or negedge reset_n)
begin
	if (!reset_n) //checking if reset
		GO <= 0;
	else
		if(!KEY[1]) 
			GO <= 1;
end

//I2C Operation
always @ (posedge i2c_clk_count[9] )
begin	
	if(!GO) begin
		state <= STATE_IDLE;
		i2c_sda <= 1;
		address <= 8'hEE;
		count <= 8'd0;
		data <= 8'hD0;
	end
	else
		case(state)
	
			STATE_IDLE:	begin // idle
					i2c_sda <= 1;
					state <= STATE_START;
				end
			
			STATE_START: begin // start
					i2c_sda <= 0;
					state <= STATE_ADDRESS;
					count <= 7;
				end // case idle
			
			STATE_ADDRESS: begin // send address
					i2c_sda <= address[count];
					if (count == 0) state <= STATE_RW;
					else count <= count - 1;
				end // case address
		
			STATE_RW: begin
					i2c_sda <= 1;
					state <= STATE_WACK;
				end // case rw
		
			STATE_WACK: begin
					state <= STATE_DATA;
					count <= 7;
				end // case wack
			
			STATE_DATA:	begin
					i2c_sda <= data[count];
					if (count == 0) state <= STATE_WACK2;
					else count <= count - 1;
				end // case data

			STATE_WACK2: begin
					state <= STATE_DATA;
					count <= 7;
				end // case wack2
			
			STATE_STOP: begin
					i2c_sda <= 1;
					state <= STATE_IDLE;
				end // case stop
		endcase // case
end // always


endmodule