module lab4_1(
	input [3:0] A,
	input [3:0] B,
	input C0,
	output [3:0] S,
	output C4
);
	wire p0,p1,p2,p3,g0,g1,g2,g3,c1,c2,c3;
	assign p0 = A[0] ^ B[0];
	assign g0 = A[0] & B[0];
	assign p1 = A[1] ^ B[1];
	assign g1 = A[1] & B[1];
	assign p2 = A[2] ^ B[2];
	assign g2 = A[2] & B[2];
	assign p3 = A[3] ^ B[3];
	assign g3 = A[3] & B[3];
	
	clag(
		.p0(p0),
		.p1(p1),
		.p2(p2),
		.p3(p3),
		.g0(g0),
		.g1(g1),
		.g2(g2),
		.g3(g3),
		.c0(C0),
		.c1(c1),
		.c2(c2),
		.c3(c3),
		.c4(C4)
	);
	
	assign S[0] = p0 ^ C0;
	assign S[1] = p1 ^ c1;
	assign S[2] = p2 ^ c2;
	assign S[3] = p3 ^ c3;
	
	
endmodule

module clag(
	input p0,p1,p2,p3,g0,g1,g2,g3,c0,
	output c1,c2,c3,c4
);
	assign c1 = g0 | (p0 & c0);
	assign c2 = g1 | (g0 & p1) | (c0 & p0 & p1);
	assign c3 = g2 | (g1 & p2) | (g0 & p1 & p2) | (c0 & p0 & p1 &p2);
	assign c4 = g3 | (g2 & p3) | (g1 & p2 & p3) | (g0 & p1 & p2 &p3) | (c0 & p0 & p1 & p2 & p3);
endmodule

