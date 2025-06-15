module lab3_1(
	input [31:0] in,
	input [4:0] sel,
	output reg out
);

	always@(*)begin
		case(sel)
			5'b00000:out = in[0];
			5'b00001:out = in[1];
			5'b00010:out = in[2];
			5'b00011:out = in[3];
			5'b00100:out = in[4];
			5'b00101:out = in[5];
			5'b00110:out = in[6];
			5'b00111:out = in[7];
			5'b01000:out = in[8];
			5'b01001:out = in[9];
			5'b01010:out = in[10];
			5'b01011:out = in[11];
			5'b01100:out = in[12];
			5'b01101:out = in[13];
			5'b01110:out = in[14];
			5'b01111:out = in[15];
			5'b10000:out = in[16];
			5'b10001:out = in[17];
			5'b10010:out = in[18];
			5'b10011:out = in[19];
			5'b10100:out = in[20];
			5'b10101:out = in[21];
			5'b10110:out = in[22];
			5'b10111:out = in[23];
			5'b11000:out = in[24];
			5'b11001:out = in[25];
			5'b11010:out = in[26];
			5'b11011:out = in[27];
			5'b11100:out = in[28];
			5'b11101:out = in[29];
			5'b11110:out = in[30];
			5'b11111:out = in[31];
		endcase
	end
endmodule
