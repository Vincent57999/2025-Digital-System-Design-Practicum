module lab2_1(
	input X1,X2,X3,X4,
	output f,g,h
);
	assign g = (X1&X2)|(X1&X2);
	assign h = (X3|X4)&(X3|X4);
	assign f = g&h;

endmodule
