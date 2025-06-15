module hw1(
	input a,b,c,
	output x);

	wire d,e;
	
	and and1(d,a,b);
	and and2(e,a,c);
	or or1(x,d,e);

endmodule
