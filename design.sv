`timescale 1ns / 1ps
module Cycle_Cooling_System
  (
    input[2:0] calorie,temperature,
    input pressure,air_pressure,
    output reg fan
  );
  
  parameter S1=1, S2=2, S3=3, S4=4;
  
  reg[2:0] current_state;
  
  parameter air_pressure_threshold = 0, calorie_threshold = 1, temperature_threshold = 1;
  
  reg[2:0] fan_angle;
  
  always@(*)
    begin
      
        case(current_state)
          S1:if(calorie > calorie_threshold && temperature> temperature_threshold )
                begin
                  current_state<=S2;
                end
          	 else
                begin
                  current_state<=S1;
                end
          
          S2:if(pressure == 1)
                begin
                  current_state<=S2;
                end
          	 else
                begin
                  current_state<=S3;
                end
          
          S3:if(air_pressure > air_pressure_threshold)
                begin
                  current_state<=S3;
                end
          	 else
                begin
                  current_state<=S4;
                end
          
          S4:if(air_pressure > air_pressure_threshold)
                begin
                  current_state<=S4;
                end
          	 else
                begin
                  current_state<=S2;
                end
          
          default: current_state<=S1;
        endcase
    end
  
  always@(current_state)
    begin
      
      case(current_state)
        
        S1:
          begin
            fan<=1'b0;
            fan_angle<=0;
          end
        
        S2:
          begin
            fan<=1'b1;
            fan_angle<=0;
          end
        
        S3:
          begin
            fan<=1'b1;
            if(fan_angle < 5)
              begin
                fan_angle <= fan_angle+ 1;
              end
            else
              begin
                fan_angle <= 0;
              end
          end
        
        S4:
          begin
            fan<=1'b1;
          end
      endcase
    end
endmodule
