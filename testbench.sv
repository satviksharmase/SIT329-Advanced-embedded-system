// Code your testbench here
// or browse Examples
`timescale 1ns / 1ps
module Cycle_Cooling_System_TB;

 reg rst, clk;
 reg[2:0] calorie,temperature,pressure,air_pressure;
  wire [2:0] fan_mode;

 Cycle_Cooling_System dut(

   .clk(clk),
   .rst(rst),
   .calorie(calorie),
   .temperature(temperature),
   .pressure(pressure),
   .air_pressure(air_pressure),
   .fan_mode(fan_mode)
 );
initial 
  begin
    clk = 1'b0;
    forever #(1000000000/2) clk =~ clk;
  end

 initial
 begin
 $dumpfile("dump.vcd");
 $dumpvars;

   rst = 0;
 calorie = 3'b010;
 temperature =3'b010;
 pressure = 1'b1;
 air_pressure = 1'b1; 
 #1000000000;
   $display (" calorie = %d, temerature = %d, pressure = %d, air_pressure = %d, fan_mode = %d", calorie, temperature, pressure, air_pressure, fan_mode);
   rst = 1;
 calorie = 3'b010;
 temperature =3'b010;
 pressure = 3'b010;
 air_pressure = 3'b010; 
 #1000000000;
   $display (" calorie = %d, temerature = %d, pressure = %d, air_pressure = %d, fan_mode = %d", calorie, temperature, pressure, air_pressure, fan_mode);
   rst = 0;
   calorie = 3'b010;
 temperature =3'b010;
 pressure = 3'b010;
 air_pressure = 3'b010;
   #(1000000000*200);
   
   $display (" calorie = %d, temerature = %d, pressure = %d, air_pressure = %d, fan_mode = %d", calorie, temperature, pressure, air_pressure, fan_mode);
   rst = 1;
 calorie = 3'b010;
 temperature =3'b010;
 pressure = 3'b000;
 air_pressure = 3'b010; 
 #1000000000;
   $display (" calorie = %d, temerature = %d, pressure = %d, air_pressure = %d, fan_mode = %d", calorie, temperature, pressure, air_pressure, fan_mode);
   rst = 0;
   calorie = 3'b010;
 temperature =3'b010;
 pressure = 3'b000;
 air_pressure = 3'b010;
   #(1000000000*200);
   
   $display (" calorie = %d, temerature = %d, pressure = %d, air_pressure = %d, fan_mode = %d", calorie, temperature, pressure, air_pressure, fan_mode);
 $finish;
   
   
   
 end
endmodule
