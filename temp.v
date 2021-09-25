//module temp (
//    input clk,//system clock
//    input res,//System reset                                    
//    inout dht22,//dht22 temperature and humidity sensor single bus
//	 output reg [31:0] data_out//High temperature
// );                                                                             
////parameter define 
//parameter  POWER_ON_NUM = 1000_000;//Power-on delay waiting time, unit us
////Each state of the state machine                     
//parameter st_power_on_wait = 3'd0;//wait for the Power-up 000
//parameter st_low_500us = 3'd1;     //host sends a low level 500us 001
//parameter st_high_40us = 3'd2;//master releases the bus 40us 010
//parameter st_rec_low_83us = 3'd3;     //low level in response to receiving 83us 011
//parameter st_rec_high_87us = 3'd4;//wait 87us high (ready to receive data) 100
//parameter st_rec_data = 3'd5;     //101 receives 40-bit data
//parameter st_delay = 3'd6;//wait delay, delay after the completion of re-operation DHT22 110
//
////reg define
//reg [2:0] cur_state;//Current state 3-bit register
//reg [2:0] next_state;//Next state
//                                    
//reg [4:0] clk_cnt;//Frequency counter
//reg clk_1m;//1Mhz clock
//reg [20:0] us_cnt;//1 microsecond counter
//reg us_cnt_clr;//1 microsecond counter clear signal
//                                    
//reg [39:0] data_temp;//Buffer the received data
//reg step;//Data collection status
//reg [5:0] data_cnt;//Counter for receiving data
//
//reg dht22_buffer;//DHT22 output signal
//reg dht22_d0;//DHT22 input signal register 0
//reg dht22_d1;//DHT22 input signal register 1
//
////wire define                       
//wire dht22_pos;//DHT22 rising edge
//wire dht22_neg;//DHT22 falling edge
//
////************************************************ *****
////** main code
////************************************************ *****
//
//assign dht22 = dht22_buffer;
//assign dht22_pos = ~dht22_d1 & dht22_d0;//Collect the rising edge
//assign dht22_neg = dht22_d1 & ~dht22_d0;//Collect the falling edge
//
////Get 1Mhz frequency division clock
//always @ (posedge clk or negedge res) begin//posedge rising edge trigger or negedge falling edge trigger
//    if (!res) begin
//        clk_cnt <= 5'd0;
//        clk_1m  <= 1'b0;
//    end 
//    else if (clk_cnt < 5'd24) 
//        clk_cnt <= clk_cnt + 1'b1;       
//    else begin
//        clk_cnt <= 5'd0;
//        clk_1m  <= ~ clk_1m;
//    end 
//end
//
////Register the DHT22 input signal twice for edge detection
//always @ (posedge clk_1m or negedge res) begin
//    if (!res) begin
//        dht22_d0 <= 1'b1;
//        dht22_d1 <= 1'b1;
//    end 
//    else begin
//        dht22_d0 <= dht22;
//        dht22_d1 <= dht22_d0;
//    end 
//end 
//
////1 microsecond counter
//always @ (posedge clk_1m or negedge res) begin
//    if (!res)
//        us_cnt <= 21'd0;
//    else if (us_cnt_clr)
//        us_cnt <= 21'd0;
//    else 
//        us_cnt <= us_cnt + 1 ;
//end 
//
////State jump
//always @ (posedge clk_1m or negedge res) begin
//    if (!res)
//        cur_state <= st_power_on_wait;
//    else 
//        cur_state <= next_state;
//end 
//
////The state machine reads DHT11 data
//always @ (posedge clk_1m or negedge res) begin
//    if(!res) begin
//        next_state <= st_power_on_wait;
//        data_temp <= 40'd0;
//        step         <= 1'b0; 
//        us_cnt_clr   <= 1'b0;
//        data_cnt     <= 6'd0;
//        dht22_buffer <= 1'bz;   
//    end 
//    else begin
//        case (cur_state)
//               //Delay for 1 second after power-on and wait for DHT22 to stabilize
//            st_power_on_wait : begin                
//                if(us_cnt < POWER_ON_NUM) begin
//                    dht22_buffer <= 1'bz;//release the bus idle state
//                    us_cnt_clr <= 1'b0;
//                end
//                else begin            
//                    next_state   <= st_low_500us;
//                    us_cnt_clr   <= 1'b1;
//                end
//            end
//               //FPGA sends start signal (low level of 500us)    
//            st_low_500us: begin
//                if(us_cnt <500) begin
//                    dht22_buffer <= 1'b0;//start signal is low
//                    us_cnt_clr    <= 1'b0;
//                end
//                else begin
//                    dht22_buffer <= 1'bz;//release the bus after the start signal
//                    next_state    <= st_high_40us;
//                    us_cnt_clr   <= 1'b1;
//                end    
//            end 
//               //Waiting for the response signal of DHT22 (waiting 20~40us)
//            st_high_40us:begin                      
//                if (us_cnt <40) begin
//                    us_cnt_clr <= 1'b0;
//                    if(dht22_neg) begin//detected response signal DHT22
//                        next_state <= st_rec_low_83us;
//                        us_cnt_clr <= 1 'b1;
//                    end
//                end
//                else//No response over 40us
//                    next_state <= st_delay;
//            end 
//               //Wait for the 83us low level response signal of DHT22 to end
//            st_rec_low_83us: begin                  
//                if(dht22_pos)                   
//                    next_state <= st_rec_high_87us;  
//            end 
//               //DHT22 pulls up 87us to notify FPGA that it is ready to receive data
//            st_rec_high_87us: begin
//                if(dht22_neg) begin//The preparation time is over    
//                    next_state <= st_rec_data; 
//                    us_cnt_clr <= 1'b1;
//                end
//                else begin//High level ready to receive data
//                    data_cnt   <= 6'd0;
//                    data_temp <= 40'd0;
//                    step  <= 1'b0;
//                end
//            end 
//               //Continuously receive 40 bits of data 
//            st_rec_data: begin                                
//                case(step)
//                    0: begin//Receive data low level
//                        if(dht22_pos) begin 
//                            step <= 1'b1;
//                            us_cnt_clr <= 1'b1;
//                        end            
//                        else//Wait for the end of data low level
//                            us_cnt_clr <= 1'b0;
//                    end
//                    1: begin//receive data high level
//                        if (dht22_neg) begin 
//                            data_cnt <= data_cnt + 1;
//                                         //Judging that the received data is 0/1
//                            if(us_cnt <60)
//                                data_temp <= {data_temp[38:0],1'b0};
//                            else                
//                                data_temp <= {data_temp[38:0],1'b1};
//                            step <= 1'b0;
//                            us_cnt_clr <= 1'b1;
//                        end 
//                        else//Wait for the end of the data high level
//                            us_cnt_clr <= 1 'b0;
//                    end
//                endcase
//                
//                if(data_cnt == 40) begin//data transmission is over, verify check digit
//                    next_state <= st_delay;
//                    if(data_temp[7:0] == data_temp[39:32] + data_temp[31:24] + data_temp[23:16] + data_temp[15:8])
//                        data_out <= data_temp[39:8];  
//                end
//            end 
//               //Delay 2s after completing a data collection
//            st_delay:begin
//                if (us_cnt < 2000_000)
//                    us_cnt_clr <= 1'b0;
//                else begin//Resend the start signal after the delay is over
//                    next_state <= st_low_500us;      
//                    us_cnt_clr <= 1'b1;
//                end
//            end
//            default : ;
//        endcase
//    end 
//end
//
//endmodule   

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:09:32 07/03/2017 
// Design Name: 
// Module Name:    DHT11 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module temp(
	 input CLK,  //100 MHz
//    input EN,
    input RST,
    inout DHT_DATA,
	 output OUT,
//	 output [7:0] HUM_INT,
//	 output [7:0] HUM_FLOAT,
    output [7:0] TEMP_INT
//	 output [7:0] TEMP_FLOAT,
//	 output [7:0] CRC,
//	 output WAITC
    );


	reg DHT_OUT, DIR, WAIT;  //Registrador de saida	
	reg [20:0] COUNTER; //Contador de ciclos para gerar delays
	reg [4:0] index;
	reg [39:0] INTDATA; //registrador de dados interno
	reg FAN;
	
	//wire DHT_IN;
	
	assign DHT_DATA = DIR ? DHT_OUT : 1'bZ; // Se DIR 1 -- copia DHT_OUT para saida, caso nao, deixa o pino indefinido para atuar como entrada
	//assign DHT_IN = DHT_DATA;
	
	assign TEMP_INT[0] = INTDATA[16];  
	assign TEMP_INT[1] = INTDATA[17];
	assign TEMP_INT[2] = INTDATA[18];
	assign TEMP_INT[3] = INTDATA[19];
	assign TEMP_INT[4] = INTDATA[20];
	assign TEMP_INT[5] = INTDATA[21];
	assign TEMP_INT[6] = INTDATA[22];
	assign TEMP_INT[7] = INTDATA[23];
	assign OUT = INTDATA[20];

	 reg [3:0] STATE;
	 
	 //Definição de estados
	 parameter S0=0, S1=1, S2=2, S3=3, S4=4, S5=5, S6=6, S7=7, S8=8, S9=9, STOP=10;

 
	//Processo de FSM 
	always @(posedge CLK)
	begin: FSM
	$display("Hey");
//	  if (EN == 1'b1)
//	  begin
		 if ( RST == 1'b1)
		 begin			  
			  DHT_OUT <= 1'b1;			  
			  WAIT <= 1'b0;
			  COUNTER <= 0;	
			  DIR <= 1'b1;			   //Configura pino saida
			  STATE <= S0;
			  index <= 0;
		 end else begin
		 
			 case (STATE)
				 S0:
					 begin
					   DIR <= 1'b1;	
					   DHT_OUT <= 1'b1;
						WAIT <= 1'b1;
						if (COUNTER < 900000)							//100.000.000/2 = 50.000.000 -> 1/50.000.000 = 0,00002ms --> 18ms/0,00002 = 900000 ciclos)
						begin
							COUNTER <= COUNTER + 1;
						end else begin
							COUNTER <= 20'b0;
							STATE <= S1;
						end
					 end
				 
				 S1:
					 begin
					   DHT_OUT <= 1'b0;	
						WAIT <= 1'b1;
						if (COUNTER < 900000)							//100.000.000/2 = 50.000.000 -> 1/50.000.000 = 0,00002ms --> 18ms/0,00002 = 900000 ciclos)
						begin
							COUNTER <= COUNTER + 1;
						end else begin
							COUNTER <= 0;
							STATE <= S2;
						end
					 end
				S2:
					begin
						DHT_OUT <= 1'b1;			
						STATE <= S3;
						if (COUNTER < 2000)							//100.000.000/2 = 50.000.000 -> 1/50.000.000 = 0,00002ms --> 18ms/0,00002 = 900000 ciclos)
						begin						  
							COUNTER <= COUNTER +1'b1;
						end else begin
							COUNTER <= 20'b0;
							STATE <= S3;
						end
					end
				S3:
					begin	
						DIR <= 1'b0;
						DHT_OUT <= 1'b0;
						if (COUNTER < 4000)							//100.000.000/2 = 50.000.000 -> 1/50.000.000 = 0,00002ms --> 18ms/0,00002 = 900000 ciclos)
						begin						  
							COUNTER <= COUNTER +1;
						end else begin
							COUNTER <= 0;
							STATE <= S4;
						end
					end
				
				S4:

					begin
						if (COUNTER < 4000)
						begin
							COUNTER <= COUNTER + 1;							
						end else begin
							COUNTER = 0;
							STATE <= S8;
						end
					end
					
				S5:
					begin
						if (DHT_DATA == 0)
						begin					
							COUNTER = 0;
							STATE <= S6;
							index <= 0; //reseta indexador
						end else begin
							STATE = S5;
						end
					end
			//Inicio da analise de dados
				S6:
					begin
						if ( DHT_DATA == 0)
						begin
							STATE <= S7;
						end 
					end
				
				S7:
					begin
					  if ( DHT_DATA == 1)
					  begin
							STATE <= S8;
						end							
					end
					
				S8:
				   begin
						if (  DHT_DATA == 0 ) /// 50MHz = 0,02 uS -> 50uS = 2500 ciclos
						begin
									
									if ( COUNTER > 1400) 
									begin
									   INTDATA[index] <= 1;
									   COUNTER <= 0; 
									end else begin
										INTDATA[index] <= 0;
									   COUNTER <= 0;
									end
									STATE <= S9;
									
						end else begin
									COUNTER <= COUNTER + 1;
						end
					 end
				 S9:
					begin
						if (index < 40 )
						begin
							index <= index+1;
							STATE <= S6;
						end else begin
							WAIT <= 0;							
							index <= 0;
							COUNTER <= 0;
							
							STATE <= STOP;
						end						
					end	
				 
				 STOP:
					begin
						STATE <= STOP;
						if (INTDATA[20] == 1 || INTDATA[21] == 1 || INTDATA[22] == 1 || INTDATA[23] == 1)
						begin
							FAN <= 1;
						end else begin
							FAN <= 0;
						end
					end
			 endcase
		end
//	end
  end


endmodule
