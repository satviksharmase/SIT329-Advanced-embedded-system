	module buzzer (
	input wire clk, 
	output wire buzzer
	);
    
	reg [31:0] cnt;
	reg clk_enabler = 0;
    
initial begin
cnt <= 32'h00000000;
end

always @(posedge clk) 
  begin
    cnt <= cnt + 1;
  end

assign buzzer = cnt[14];
endmodule
