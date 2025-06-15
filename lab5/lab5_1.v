module lab5_1(
	input [3:0] in,
	input count, load, clear, clk,
	output reg [3:0] out
);
	
	always @(posedge clk or posedge clear)begin
		if(clear)begin
			out <= 4'd0;
		end
		else if(load)begin
			out <= in;
		end
		else if(count)begin
			out <= out + 4'd1;
		end
		else begin
			out <= out;
		end
	end
endmodule
