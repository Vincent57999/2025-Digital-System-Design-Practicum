module lab6_2(
	input clk,
	output reg x,y,z
);
	reg [2:0] counter = 3'd0;
	initial {z,y,x} = 3'b100;
	
	always@(posedge clk)begin
		if(({z,y,x}==3'b111 || {z,y,x}==3'b001) && counter< 3)begin
			{z,y,x}<=3'b001;
			counter<=counter + 1;
		end
		else if (counter==3 || counter==4 || counter==5)begin
			{z,y,x}<=3'b100;
			counter<=counter + 1;
		end
		else begin
			{y,x}<={z,y,x}>>1;
			z<=~x;
			counter<=0;
		end
		
		if({z,y,x}==3'b000)begin
			{z,y,x}<=3'b100;
		end
	end
endmodule
