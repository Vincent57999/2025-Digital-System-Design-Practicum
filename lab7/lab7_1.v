module lab7_1(
	input clk,
	input in,
	input rst,
	output reg out,
	output reg [1:0] out_state
);
	parameter [1:0] s0=2'b00,s1=2'b01,s2=2'b10,s3=2'b11;
	reg [1:0] next_state;
	
	always @(posedge clk)begin
		case(out_state)
			s0:begin
				if(in==1'b0)out <= 1'b0;
				else out <= 1'b0;
			end
			s1:begin
				if(in==1'b0)out <= 1'b1;
				else out <= 1'b0;
			end
			s2:begin
				if(in==1'b0) out <= 1'b1;
				else out <= 1'b0;
			end
			s3:begin
				if(in==1'b0) out <= 1'b1;
				else out <= 1'b0;
			end
		endcase
	end
	
	always @(posedge clk)begin
		if(rst==1'b0) 
			out_state <= s0;
		else 
			out_state <= next_state;
	end
	
	always @(*)begin
		case(out_state)
			s0:begin
				if(in==1'b0) next_state <= s0;
				else next_state <= s1;
			end
			s1:begin
				if(in==1'b0)next_state <= s0;
				else next_state <= s3;
			end
			s2:begin
				if(in==1'b0)next_state <= s0;
				else next_state <= s2;
			end
			s3:begin
				if(in==1'b0)next_state <= s0;
				else next_state <= s2;
			end
		endcase
		if(rst==1'b0)begin 
			next_state <= s0;
		end
	end
endmodule
