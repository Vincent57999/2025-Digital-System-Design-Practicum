module lab4_2(
	input J,K,clk,set,reset,
	output reg Q
);
	always@(negedge clk)begin
		if (reset == 1)begin
			Q <= 0;
		end else if (set == 1) begin
			Q <= 1;
		end else begin
			case({J,K})
				2'b00:Q <= Q;
				2'b01:Q <= 0;
				2'b10:Q <= 1;
				2'b11:Q <= ~Q;
			endcase
		end
	end
endmodule
