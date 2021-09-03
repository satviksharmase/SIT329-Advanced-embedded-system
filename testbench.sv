`timescale 1ns / 1ps
module Cycle_Cooling_System_TB;

 reg reset;
  reg[2:0] calorie,temperature;
 reg  pressure,air_pressure;
 wire fan;

 Cycle_Cooling_System dut(

 .calorie(calorie),
 .temperature(temperature),
 .pressure(pressure),
 .air_pressure(air_pressure),
 .fan(fan)
 );


 initial
 begin
 $dumpfile("dump.vcd");
 $dumpvars;

 calorie = 3'b010;
 temperature =3'b010;
 pressure = 1'b1;
 air_pressure = 1'b1; 
 #1000;
   $display (" calorie = %d, temerature = %d, pressure = %d, air_pressure = %d, fan = %d", calorie, temperature, pressure, air_pressure, fan);
 calorie = 3'b001;
 temperature =3'b010;
 pressure = 0;
 air_pressure = 0; 
 #1000;
   $display (" calorie = %d, temerature = %d, pressure = %d, air_pressure = %d, fan = %d", calorie, temperature, pressure, air_pressure, fan);
   
 $finish;
   
 end
endmodule
