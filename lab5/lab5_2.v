module lab5_2(
	input clk, rst,
	output reg [3:0] out = 4'd10,
	output reg fout
	
);
	always@(posedge clk)begin
		if(rst == 0)begin
			out <= 4'd10;
			fout <= 1'b0;
		end
		else if (out == 4'd1)begin
			out <= 4'd10;
			fout <= ~fout;
		end
		else begin
			out <= out - 4'd1;
		end
	end

endmodule
