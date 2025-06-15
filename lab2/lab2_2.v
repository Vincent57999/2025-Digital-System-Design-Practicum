module lab2_2(
	input [1:0] A,B,
	output [3:0] C
);
	wire w1,w2,w3,w_carry;
	assign w1 = A[1]&B[1];
	assign w2 = A[1]&B[0];
	assign w3 = A[0]&B[1];
	assign C[0] = A[0]&B[0];
	
	ha ha1(.a(w2),.b(w3),.s(C[1]),.c(w_carry));
	ha ha2(.a(w_carry),.b(w1),.s(C[2]),.c(C[3]));
	
endmodule

module ha(
	input a,b,
	output s,c
);
	assign s = a^b;
	assign c = a&b;
endmodule
