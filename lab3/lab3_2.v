module lab3_2(
	input [3:0] in,
	input en,
	input [1:0] sel,
	output reg out
);

	wire w0, w1, w2, w3;
	assign w0 = en ? in[0] : 1'bz;
	assign w1 = en ? in[1] : 1'bz;
	assign w2 = en ? in[2] : 1'bz;
	assign w3 = en ? in[3] : 1'bz;
	
	always@(*)begin
		case(sel)
			2'b00:out = w0;
			2'b01:out = w1;
			2'b10:out = w2;
			2'b11:out = w3;
		endcase
	end
endmodule
