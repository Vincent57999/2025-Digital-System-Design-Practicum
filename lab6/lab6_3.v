module lab6_3(
	input clear, clk, s_in, shift_ctrl,
	output [3:0] p_out1, p_out2
);
	wire FA_C,FA_S,DFF_Q;
	assign DFF_clk = shift_ctrl&clk;
	shift s0(FA_S , shift_ctrl , clk , p_out1);
	shift s1(s_in , shift_ctrl , clk , p_out2);
	FA f0(p_out1[0] , p_out2[0] , DFF_Q , FA_S , FA_C);
	D_FF d0(clear , DFF_clk , FA_C , DFF_Q);
	
endmodule

//(clk ????;clear ????)

module D_FF(
	input clear,
	input clk,D,
	output reg Q
);
	always@(posedge clk)begin
		if(~clear) Q<=0;
		else Q<=D;
	end
endmodule

module FA(
	input A, B, C0,
	output S, C
);
	assign {C,S} = A + B + C0;
endmodule

module shift(
input s_in,
input shift_ctrl, clk,
output reg [3:0] p_out
);
	always@(posedge clk)begin
		if(shift_ctrl)begin
			if(s_in) p_out[3:0]<={s_in , p_out[3:1]};
			else p_out[3:0]<={1'b0 , p_out[3:1]};
		end
	end
endmodule
