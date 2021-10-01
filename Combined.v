//COMBINED

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
    input RST,
    inout DHT_DATA,
	 output OUT,
    output [7:0] TEMP_INT,
	 input [1:0] calorie, pressure, air_pressure
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
	assign OUT = FAN;

	 reg [3:0] STATE;
	 
	 //Definição de estados



	 parameter S0=0, S1=1, S2=2, S3=3, S4=4, S5=5, S6=6, S7=7, S8=8, S9=9, STOP=10,S11=11,S12=12,S13=13,S14=14,START=15;
	 parameter air_pressure_threshold = 1, calorie_threshold = 1, temperature_threshold = 1, pressure_threshold = 1;
	 parameter sec1 =1, sec2 =2, sec3 =3, sec4 =4, sec5 =5, sec6 =6, sec7 =7;

 
	//Processo de FSM 
	always @(posedge CLK)
	begin: FSM

//	  if (EN == 1'b1)
//	  begin
		 if ( RST == 1'b1)
		 begin			  
			  DHT_OUT <= 1'b1;			  
			  WAIT <= 1'b0;
			  COUNTER <= 0;	
			  DIR <= 1'b1;			   //Configura pino saida
			  STATE <= START;
			  index <= 0;
		 end else begin
		 
			 case (STATE)
			 	START:
			 		if(calorie > calorie_threshold)
  		            begin
  		                if(COUNTER < sec2)
  		                  begin
  		                    STATE<= START;
  		                    COUNTER <= COUNTER +1;
  		                  end
                  		else
                    	begin
                	      STATE <= S0;
                	      COUNTER <= 0;
                	    end
                	end
     	    	 	else
        		    begin
            		  STATE <= START;
            		  COUNTER <=0;
            		end
          
          
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
						if (INTDATA[20] == 1 || INTDATA[21] == 1 || INTDATA[22] == 1 || INTDATA[23] == 1)
						begin
							FAN <= 1;
						end else begin
							FAN <= 0;
						end

						STATE <= S11;
					end

				
          
          S11:if(pressure < pressure_threshold)
                begin
                  if(COUNTER < sec5)
                    begin
                      STATE <= S3;
                      COUNTER <= COUNTER+1;
                      end
                  else
                    begin
                      COUNTER <=S12;
                      COUNTER <= 0;
                    end
                end
          else
            begin
              STATE <= S3;
              COUNTER <= 0;
            end
          
          S12:if(air_pressure > air_pressure_threshold)
                begin
                  if(COUNTER < sec2)
                    begin
                      STATE <= S12;
                      COUNTER <= COUNTER +1;
                      end
                  else
                    begin
                      STATE <= S12;
                      COUNTER <= 0;
                    end
                end
          	 else
                begin
                   STATE <= S13;
                   COUNTER <= 0;
                end
          
          S13:if(air_pressure > air_pressure_threshold)
            begin
              if(COUNTER < sec3)
                begin
                  STATE <= S13;
                  COUNTER <= COUNTER+1;
                end
              else
                begin
                  STATE <= S12;
                  COUNTER <= 0;
                end
            end
          else
            begin
              if(COUNTER < sec3)
                begin
                  STATE <= S13;
                  COUNTER <= COUNTER +1;
                end
              else
                begin
                  STATE <= S11;
                  COUNTER <= 0;
                end
            end
			 endcase
		end
//	end
  end


endmodule
