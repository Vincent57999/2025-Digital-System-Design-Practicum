module lab7_2(
	input clk,
	input in,
	input rst,
	output reg Z1,
	output reg Z2,
	output reg [2:0] out_state
);
	parameter [2:0] s0=3'b000,s1=3'b001,s2=3'b010,s3=3'b011;
	reg [2:0] next_state;

	always @(posedge clk) begin
		case(out_state)
			s0: begin
				Z1 = 1'b0;
				Z2 = 1'b0;
			end
			s1: begin
				Z1 = 1'b0;
				Z2 = 1'b0;
			end
			s2: begin
				Z1 = 1'b1;
				Z2 = 1'b0;
			end
			s3: begin
				if(in==1'b1) begin
					Z1 = 1'b1;
					Z2 = 1'b0;
				end
				else begin
					Z1 = 1'b0;
					Z2 = 1'b1;
				end
			end
		endcase
	end

	always @(posedge clk) begin
		if(rst==1'b0) begin
			out_state <= s0;
		end
		else out_state <= next_state;
	end
	
	always @(*) begin
		case(out_state)
			s0: begin
				if(in==1'b1) next_state <= s1;
				else next_state <= s0;
			end
			s1:
				if(in==1'b1) next_state <= s2;
				else next_state <= s0;
			s2:
				if(in==1'b1) next_state <= s3;
				else next_state <= s0;
			s3: begin
				if(in==1'b0) next_state <= s0;
				else next_state <= s3;
			end
		endcase
		if(rst==1'b0) next_state <= s0;
	end

endmodule
