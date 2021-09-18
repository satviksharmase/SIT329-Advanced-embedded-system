`timescale 1ns / 1ps
module Cycle_Cooling_System
  (
    input[2:0] calorie,temperature, pressure, air_pressure,
    input clk,rst,
    output reg [2:0] fan_mode
  );
  
  parameter S1=1, S2=2, S3=3, S4=4, S5=4;
  parameter air_pressure_threshold = 1, calorie_threshold = 1, temperature_threshold = 1, pressure_threshold = 1;
  parameter sec1 =1, sec2 =2, sec3 =3, sec4 =4, sec5 =5, sec6 =6, sec7 =7;
  
  reg[2:0] current_state; 
  reg[3:0] count;
  
  initial 
    begin
      count <= 32'h00000000;
    end
  
  always@(posedge clk or posedge rst)
    begin
      if(rst == 1)
        begin
          current_state <= S1;
          count <= 0;
        end
      else
        case(current_state)
          S1:if(calorie > calorie_threshold)
                begin
                  if(count < sec2)
                    begin
                      current_state <= S1;
                      count <= count +1;
                    end
                  else
                    begin
                      current_state <= S2;
                      count <= 0;
                      end
                end
          else
            begin
              current_state <= S1;
              count <=0;
            end
          
          S2:if(temperature > temperature_threshold)
                begin
                  if(count < sec3)
                    begin
                      current_state <= S2;
                      count <= count +1;
                    end
                  else
                    begin
                      current_state <= S3;
                      count <= 0;
                    end
                end
          else
            begin
              current_state <= S2;
              count <= 0;
            end
          
          S3:if(pressure < pressure_threshold)
                begin
                  if(count < sec5)
                    begin
                      current_state <= S3;
                      count <= count +1;
                      end
                  else
                    begin
                      current_state<=S4;
                      count <= 0;
                    end
                end
          else
            begin
              current_state <= S3;
              count <= 0;
            end
          
          S4:if(air_pressure > air_pressure_threshold)
                begin
                  if(count < sec2)
                    begin
                      current_state <= S4;
                      count <= count +1;
                      end
                  else
                    begin
                      current_state <= S4;
                      count <= 0;
                    end
                end
          	 else
                begin
                  current_state <= S5;
                   count <= 0;
                end
          
          S5:if(air_pressure > air_pressure_threshold)
            begin
              if(count < sec3)
                begin
                  current_state <= S5;
                  count <= count+1;
                end
              else
                begin
                  current_state <= S4;
                  count <= 0;
                end
            end
          else
            begin
              if(count < sec3)
                begin
                  current_state <= S5;
                  count <= count +1;
                end
              else
                begin
                  current_state <= S3;
                  count <= 0;
                end
            end
          
          default: current_state <= S1;
        endcase
    end
  
  always@(current_state)
    begin
      case(current_state)
        
        S1:
          begin
            fan_mode <= 3'b000;
          end
        
        S2:
          begin
            fan_mode <= 3'b000;
          end
        
        S3:
          begin
            fan_mode <= 3'b001;
          end
        
        S4:
          begin
            fan_mode <= 3'b010;
          end
        
        S5:
          begin
            fan_mode <= 3'b011;
          end
      endcase
    end
endmodule
