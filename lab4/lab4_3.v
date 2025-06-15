module lab4_3(
	input [3:0]D_in,
	input clk,load,rst,
	output reg [3:0] D_out
);
	always@(posedge clk)begin
		if ((load & rst) == 1) begin
			D_out <= D_in;
		end else if((load | rst) == 0) begin
			D_out <= 4'd0;
		end else begin
			D_out <= D_out;
		end
	end
endmodule
