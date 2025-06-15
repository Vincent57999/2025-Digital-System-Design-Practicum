module game(
	input clk,
	input reset,
	input hit,
	input [3:0] movement,// up,down,left,right
	output [15:0] row,
	output [15:0] col,
	//output [7:0] tens_seg7,
	//output [7:0] units_seg7,
	//output [7:0] hearts_seg7
	output [7:0] LCD_DATA,
	output LCD_RW, LCD_EN, LCD_RS, LCD_RST
);
	wire [255:0] matrix;
	wire [5:0] score;
	wire [3:0] tens, units;
	wire [1:0] hearts;
	wire fout, over;
	wire st, ht;

	freq_divider fd0(
		//input
		.clk(clk),
		.score(score),
		//output
		.fout(fout)
	);
	main_contral mc0(
		//input
		.movement(movement),
		.clk(clk), 
		.fout(fout),
		.reset(reset),
		.hit(hit),
		//output
		.matrix(matrix),
		.score(score),
		.hearts(hearts),
		.over(over),
		.score_triger(st),
		.hearts_triger(ht)
	);
	led_scanout lc0(
		//input
		.clk(clk),
		.matrix(matrix),
		//output
		.row(row),
		.col(col)
	);
	binary_2_bcd b_2_b0(
		//input
		.in(score),
		//output
		.tens(tens),
		.units(units)
	);
	/*
	Seg7 s7_TEN(
		//input
		.bcd_nums(tens),
		//output
		.display_num(tens_seg7)
	);
	Seg7 s7_UNIT(
		//input
		.bcd_nums(units),
		//output
		.display_num(units_seg7)
	);
	Seg7 s7_HEARTS(
		//input
		.bcd_nums({2'b00,hearts}),
		//output
		.display_num(hearts_seg7)
	);
*/
	lcdm_displayer ld0(
		.clk(clk),
		.reset(reset),
		.over(over),
		.tens(tens), 
		.units(units),
		.hearts(hearts),
		.score_triger(st),
		.hearts_triger(ht),
		.LCD_DATA(LCD_DATA),
		.LCD_RW(LCD_RW),
		.LCD_EN(LCD_EN),
		.LCD_RS(LCD_RS),
		.LCD_RST(LCD_RST)
	);		
endmodule


module main_contral( //need to low area
	input [3:0] movement,
	input clk, fout,
	input reset,
	input hit,
	output reg [255:0] matrix,
	output reg [5:0] score,
	output reg [1:0] hearts,
	output reg over,
	output reg score_triger, hearts_triger
);
	reg start = 1;

	reg [3:0]old_movement;

	reg [3:0] head_row = 3, head_col = 3;		//head initail
	reg [3:0] center_row = 3, center_col = 2;	//center initail
	reg [3:0] tail_row = 3, tail_col = 1;		//tail initail
	reg [3:0] enemy_row = 5, enemy_col = 8;		//enemy initail
	reg enemy_shine = 0;

	reg [3:0] min_row [9:0]; // snake's real tail
	reg [3:0] min_col [9:0]; // it means that every row and col's max is 30, because you or even me will never get the score over 30

	parameter UP = 1, DOWN = 2, LEFT = 4, RIGHT = 8;//move direction

	integer k = 123;// random number
	integer i = 0;// for number
	integer j = 0;// for number
	integer m = 0;// for number

	always@(posedge clk) begin
		if (start) begin
			matrix[15:0]    =16'b0010001000101110;
			matrix[31:16]   =16'b0010001001101001;
			matrix[47:32]   =16'b0101001010100001;
			matrix[63:48]   =16'b0101001010100110;
			matrix[79:64]   =16'b0111001010101000;
			matrix[95:80]   =16'b1000101100101001;
			matrix[111:96]  =16'b1000101000100111;
			matrix[127:112] =16'b0000000000000000;
			matrix[143:128] =16'b0000000000000000;
			matrix[159:144] =16'b0110011111010001;
			matrix[175:160] =16'b0110000001001001;
			matrix[191:176] =16'b0110000001000101;
			matrix[207:192] =16'b0110011111000011;
			matrix[223:208] =16'b0000000001000101;
			matrix[239:224] =16'b0110000001001001;
			matrix[255:240] =16'b0110011111010001;
		end
		else if(over) begin// over
			matrix[15:0]    =16'b0000000000000000;
			matrix[31:16]   =16'b0000000110011111;
			matrix[47:32]   =16'b0000001001000100;
			matrix[63:48]   =16'b0000000010000100;
			matrix[79:64]   =16'b0000000100000100;
			matrix[95:80]   =16'b0000001001000100;
			matrix[111:96]  =16'b0000000110011111;
			matrix[127:112] =16'b0000000000000000;
			matrix[143:128] =16'b0000000000000000;
			matrix[159:144] =16'b0000000000000000;
			matrix[175:160] =16'b0111011101010010;
			matrix[191:176] =16'b0101000101010101;
			matrix[207:192] =16'b0011011101010101;
			matrix[223:208] =16'b0101000100100101;
			matrix[239:224] =16'b0101011100100010;
			matrix[255:240] =16'b0000000000000000;
			//matrix =0;
		end
		else if (reset)begin
			score = 0;
			old_movement = 0;
		end
		else begin
			if(movement == 4'd0)
				old_movement = old_movement;
			else begin
            	if(old_movement == UP && movement == DOWN) begin// when the opposite on, it can't change direction
                	old_movement = UP;
            	end
            	else if (old_movement == DOWN && movement == UP) begin
                	old_movement = DOWN;
            	end
            	else if (old_movement == LEFT && movement == RIGHT) begin
                	old_movement = LEFT;
            	end
            	else if (old_movement == RIGHT && movement == LEFT) begin
                	old_movement = RIGHT;
            	end
            	else begin
            	    old_movement = movement;
        	    end
        	end
			// clear the matrix
			matrix = 256'd0; 

			// draw all need
        	matrix[head_row * 16 + head_col] = 1;
        	matrix[center_row * 16 + center_col] = 1;
        	matrix[tail_row * 16 + tail_col] = 1;
			//matrix[apple_row * 16 + apple_col] = 1;
			matrix[enemy_row * 16 + enemy_col] = enemy_shine ? 1 : 0;//shine
			// print the min part(real tail)
			if(score > 0) begin
				for(i = 0; i < 10; i = i + 1) begin// let 30 be max length
					if(i < score)
						matrix[min_row[i] * 16 + min_col[i]] = 1;
				end	
			end	
			
			score_triger = 0;
			
			// when hiting the enemy	
			if((head_row <= enemy_row + 2) && (head_row >= enemy_row - 2) && (head_col <= enemy_col + 2) && (head_col >= enemy_col - 2) && hit) begin
				// generate new_enemy
				enemy_row = ((123 * k) % 12) + 2;
				enemy_col = ((123 * (k + 1)) % 12) + 2;
				k = k + 1;
				score = score + 1;
				score_triger = 1;
			end
		end
	end

	always@(posedge fout) begin
		if(reset == 1) begin
				hearts <= 3;
				start <= 0;
				over <= 0;
				head_row <= 3;
				head_col <= 3;
                center_row <= 3;
                center_col <= 2;
                tail_row <= 3;
                tail_col <= 1;
		end
		else begin
			enemy_shine <= ~enemy_shine;
			case(old_movement)
			UP: begin // upward
				if(head_row > 0) begin
					head_row <= head_row - 4'd1;
					center_row <= head_row;
					center_col <= head_col;
					tail_row <= center_row;
					tail_col <= center_col;
                end
				else begin 
						hearts <= 2'd0;
					end
			end
			DOWN: begin // downward
				if(head_row < 15)begin
                    head_row <= head_row + 4'd1; // down
					center_row <= head_row;
					center_col <= head_col;
					tail_row <= center_row;
					tail_col <= center_col;
                end
				else begin 
					hearts <= 2'd0;
				end
			end    
			LEFT: begin // left
				if(head_col > 0)begin
					head_col <= head_col - 4'd1;
					center_row <= head_row;
					center_col <= head_col;
					tail_row <= center_row;
					tail_col <= center_col;
                end
				else begin 
					hearts <= 2'd0;
				end
			end		
			RIGHT: begin // right
				if(head_col <  15) begin
					head_col <= head_col + 4'd1; 
					center_row <= head_row;
					center_col <= head_col;
					tail_row <= center_row;
					tail_col <= center_col;
                end
				else begin 
					hearts <= 2'd0;
				end
			end			
			endcase
			
			//to let tail flow hend
			min_row[0] <= tail_row;
			min_col[0] <= tail_col;
			for (j = 1; j < 10; j = j + 1) begin
				if(j < score) begin
					min_row[j] <= min_row[j-1];
					min_col[j] <= min_col[j-1];
				end
			end
			
			// detect head hit the body
			for (m = 1; m < 10; m = m + 1) begin
				if((head_row == min_row[m]) && ( head_col == min_col[m]) && (m < score))begin
					hearts <= 2'd0;
				end
			end

			//touch the enemy
			if((head_row == enemy_row) && (head_col == enemy_col)) begin
				hearts <= hearts - 2'd1;
				hearts_triger <= 1;
			end
			else hearts_triger <= 0;
			
			//run out the heart
			if ((~hearts[0]) && (~hearts[1])) begin
				over <= 1;
			end
		end
	end
endmodule


module led_scanout(
	input clk,
	input [255:0]matrix,// 256bit
	output reg [15:0]row,
	output reg [15:0]col
);

	always@(posedge clk) begin	// led_scanner
    	
        if (row == 16'b00000000_00000001 | row == 16'b00000000_00000000)begin
        	row <= 16'b10000000_00000000;
    	end
		else row <= row >> 1;

        case(row)
    		16'b00000000_00000010:begin 
        		col <= matrix[15:0];//row 1
    		end
    		16'b00000000_00000100:begin 
        		col <= matrix[31:16];//row 2
    		end
			16'b00000000_00001000:begin 
        		col <= matrix[47:32];//row 3
    		end
			16'b00000000_00010000:begin 
        		col <= matrix[63:48];//row 4
    		end
			16'b00000000_00100000:begin 
        		col <= matrix[79:64];//row 5
    		end
			16'b00000000_01000000:begin 
        		col <= matrix[95:80];//row 6
    		end
			16'b00000000_10000000:begin 
        		col <= matrix[111:96];//row 7
    		end
			16'b00000001_00000000:begin 
        		col <= matrix[127:112];//row 8
    		end
			16'b00000010_00000000:begin 
        		col <= matrix[143:128];//row 9
    		end
			16'b00000100_00000000:begin 
        		col <= matrix[159:144];//row 10
    		end
			16'b00001000_00000000:begin 
        		col <= matrix[175:160];//row 11
    		end
			16'b00010000_00000000:begin 
        		col <= matrix[191:176];//row 12
    		end
			16'b00100000_00000000:begin 
        		col <= matrix[207:192];//row 13
    		end
			16'b01000000_00000000:begin 
        		col <= matrix[223:208];//row 14
    		end
			16'b10000000_00000000:begin 
        		col <= matrix[239:224];//row 15
    		end
			16'b00000000_00000001:begin 
        		col <= matrix[255:240];//row 16
    		end
    	endcase
	end
endmodule


module freq_divider(
	input clk,
	input [5:0]score,
	output reg fout
);
	reg [7:0]out;
	
	always@(posedge clk)begin
		if(out == 8'd1)begin
			fout <= !fout;
			out <= 8'b10000000-(score*5);
		end
		else out <= out - 8'd1;
	end
endmodule


module binary_2_bcd(
	input [5:0]in,
	output [3:0]tens,units
);
	assign tens = in / 10;
	assign units = in % 10;
endmodule

/*
module Seg7(
	input [3:0]  bcd_nums,	// print one side, every time
	output reg [7:0] display_num
);
	parameter BLANK = 8'b1111_1111;
	parameter ZERO  = 8'b1100_0000;
	parameter ONE   = 8'b1111_1001;
	parameter TWO   = 8'b1010_0100;
	parameter THREE = 8'b1011_0000;
	parameter FOUR  = 8'b1001_1001;
	parameter FIVE  = 8'b1001_0010;
	parameter SIX   = 8'b1000_0010;
	parameter SEVEN = 8'b1111_1000;
	parameter EIGHT = 8'b1000_0000;
	parameter NINE  = 8'b1001_0000;
	
	always@(*)begin
		case(bcd_nums)
			0: display_num = ZERO;
			1: display_num = ONE;
			2: display_num = TWO;
			3: display_num = THREE;
			4: display_num = FOUR;
			5: display_num = FIVE;
			6: display_num = SIX;
			7: display_num = SEVEN;
			8: display_num = EIGHT;
			9: display_num = NINE;
			default:  display_num = BLANK;
		endcase
	end
endmodule*/

module lcdm_displayer(
	input clk,
	input reset,
	input over,
	input [3:0] tens, units,
	input [1:0] hearts,
	input score_triger,
	input hearts_triger,
	output reg [7:0] LCD_DATA,
	output reg LCD_RW,
	output reg LCD_EN,
	output reg LCD_RS,
	output reg LCD_RST
);
	reg	[3:0] state;
	reg	[7:0] DATA_INDEX;
	reg	[7:0] DATA;

	always	@(posedge clk)begin
		case(state)
			4'd0:begin //init
				LCD_DATA <= 8'd0;
				LCD_RW	<= 1'b1;
				LCD_EN	<= 1'b1;
				LCD_RS	<= 1'b0;
				state	<= 4'd1;
				DATA_INDEX	<= 7'd0;
				LCD_RST		<= 1'b1;
			end
			4'd1:begin
				if(DATA_INDEX == 7'd32) //start
					state	<= 4'd5;
				else if(DATA_INDEX == 7'd64) //gameing
					state	<= 4'd6;
				else if(DATA_INDEX == 7'd96) //end
					state	<= 4'd7;
				else begin
					state	<= 4'd2;
				end
				LCD_RST		<= 1'b0;
			end
			// set RS,EN,RW,DATA
			4'd2:begin
				LCD_EN	<= 1'b1;
				LCD_RS	<= 1'b1;
				LCD_RW	<= 1'b0;
				LCD_RST	<= 1'b0;
				LCD_DATA <= DATA[7:0];
				state		<= 4'd3;
			end
			// delay //??
			4'd3:begin
				state <= 4'd4;
			end
			4'd4:begin
				LCD_EN	<= 1'b0;	
				DATA_INDEX	<= DATA_INDEX+8'd1;
				state		<= 4'd1;
			end
			4'd5:begin	// wating for reset button //index = 32
				if(reset)begin
					state		<= 4'd2;
					LCD_RST		<= 1'b1;
				end
				else state	<= 4'd5;
			end 
			4'd6:begin  //untill game over //index = 64
				if(~over)begin
					if (score_triger | hearts_triger)begin
						state		<= 4'd2;
						LCD_RST		<= 1'b1;
						DATA_INDEX  <= 8'd32;
					end
					else state		<= 4'd6;
				end
				else begin
					state		<= 4'd2;
					LCD_RST		<= 1'b1;
				end
			end
			4'd7:begin  //show the score //index = 96
				if(reset)begin
					state		<= 4'd2;
					LCD_RST		<= 1'b1;
					DATA_INDEX  <= 8'd32;
				end 
				else state <= 4'd7;
			end
			default:begin
				state	<= 4'd0;
			end
		endcase
	end

	always@(*)begin //lcdm table
		case(DATA_INDEX)
			//display 1st page
			7'd0: DATA = 8'h37; // first row ?????????~~
			7'd1: DATA = 8'h45; 
			7'd2: DATA = 8'h4c;
			7'd3: DATA = 8'h43;
			7'd4: DATA = 8'h4F;
			7'd5: DATA = 8'h4d;
			7'd6: DATA = 8'h45;
			7'd7: DATA = 8'h5F;
			7'd8: DATA = 8'h54;
			7'd9: DATA = 8'h4F;
			7'd10: DATA = 8'h5F;
			7'd11: DATA = 8'h5F;
			7'd12: DATA = 8'h5F;
			7'd13: DATA = 8'h5F;
			7'd14: DATA = 8'h5F;
			7'd15: DATA = 8'h5F;
			7'd16: DATA = 8'h33; // second row?????????~~
			7'd17: DATA = 8'h2e;
			7'd18: DATA = 8'h21;
			7'd19: DATA = 8'h2b;
			7'd20: DATA = 8'h25;
			7'd21: DATA = 8'h5F;
			7'd22: DATA = 8'h27;
			7'd23: DATA = 8'h21;
			7'd24: DATA = 8'h2d;
			7'd25: DATA = 8'h25;
			7'd26: DATA = 8'h01;
			7'd27: DATA = 8'h01;
			7'd28: DATA = 8'h01;
			7'd29: DATA = 8'h5F;
			7'd30: DATA = 8'h5F;
			7'd31: DATA = 8'h5F; // finish	
			//display 2nd page
			7'd32: DATA = 8'h39; // first row ?????????~~
			7'd33: DATA = 8'h4F; 
			7'd34: DATA = 8'h55;
			7'd35: DATA = 8'h5F;
			7'd36: DATA = 8'h53;
			7'd37: DATA = 8'h43;
			7'd38: DATA = 8'h4f;
			7'd39: DATA = 8'h52;
			7'd40: DATA = 8'h45;
			7'd41: DATA = 8'h5f;
			7'd42: DATA = 8'h49;
			7'd43: DATA = 8'h53;
			7'd44: DATA = 8'h5f;
			7'd45: begin
				if (over)DATA = 8'h10;
				else begin
					case(tens)
						4'd0: DATA = 8'h10;
						4'd1: DATA = 8'h11;
						4'd2: DATA = 8'h12;
						4'd3: DATA = 8'h13;
						4'd4: DATA = 8'h14;
						4'd5: DATA = 8'h15;
						4'd6: DATA = 8'h16;
						4'd7: DATA = 8'h17;
						4'd8: DATA = 8'h18;
						4'd9: DATA = 8'h19;
					endcase
				end
			end
			7'd46: begin
				if (over)DATA = 8'h10;
				else begin
					case(units)
						4'd0: DATA = 8'h10;
						4'd1: DATA = 8'h11;
						4'd2: DATA = 8'h12;
						4'd3: DATA = 8'h13;
						4'd4: DATA = 8'h14;
						4'd5: DATA = 8'h15;
						4'd6: DATA = 8'h16;
						4'd7: DATA = 8'h17;
						4'd8: DATA = 8'h18;
						4'd9: DATA = 8'h19;
					endcase
				end
			end
			7'd47: DATA = 8'h5F;
			7'd48: DATA = 8'h28; // second row?????????~~
			7'd49: DATA = 8'h45;
			7'd50: DATA = 8'h41;
			7'd51: DATA = 8'h52;
			7'd52: DATA = 8'h54;
			7'd53: DATA = 8'h5F;
			7'd54: DATA = 8'h49;
			7'd55: DATA = 8'h53;
			7'd56: DATA = 8'h5f;
			7'd57: begin
				if (over)DATA = 8'h13;
				else begin
					case(hearts)
						2'd0: DATA = 8'h10;
						2'd1: DATA = 8'h11;
						2'd2: DATA = 8'h12;
						2'd3: DATA = 8'h13;
					endcase
				end
			end
			7'd58: DATA = 8'h5F;
			7'd59: DATA = 8'h5F;
			7'd60: DATA = 8'h5F;
			7'd60: DATA = 8'h5F;
			7'd62: DATA = 8'h5F;
			7'd63: DATA = 8'h5F; // finish	
			//display 3nd page
			7'd64: DATA = 8'h29; // first row ?????????~~
			7'd65: DATA = 8'h33; 
			7'd66: DATA = 8'h5f;
			7'd67: DATA = 8'h2f;
			7'd68: DATA = 8'h36;
			7'd69: DATA = 8'h25;
			7'd70: DATA = 8'h32;
			7'd71: DATA = 8'h5F;
			7'd72: DATA = 8'h5F;
			7'd73: DATA = 8'h5F;
			7'd74: DATA = 8'h5F;
			7'd75: DATA = 8'h5F;
			7'd76: DATA = 8'h5F;
			7'd77: DATA = 8'h5F;
			7'd78: DATA = 8'h5F;
			7'd79: DATA = 8'h5F;
			7'd80: DATA = 8'h39; // second row?????????~~
			7'd81: DATA = 8'h4F; 
			7'd82: DATA = 8'h55;
			7'd83: DATA = 8'h5F;
			7'd84: DATA = 8'h53;
			7'd85: DATA = 8'h43;
			7'd86: DATA = 8'h4f;
			7'd87: DATA = 8'h52;
			7'd88: DATA = 8'h45;
			7'd89: DATA = 8'h5f;
			7'd90: DATA = 8'h49;
			7'd91: DATA = 8'h53;
			7'd92: DATA = 8'h5f;
			7'd93: begin
				case(tens)
					4'd0: DATA = 8'h10;
					4'd1: DATA = 8'h11;
					4'd2: DATA = 8'h12;
					4'd3: DATA = 8'h13;
					4'd4: DATA = 8'h14;
					4'd5: DATA = 8'h15;
					4'd6: DATA = 8'h16;
					4'd7: DATA = 8'h17;
					4'd8: DATA = 8'h18;
					4'd9: DATA = 8'h19;
				endcase
			end
			7'd94: begin
				case(units)
					4'd0: DATA = 8'h10;
					4'd1: DATA = 8'h11;
					4'd2: DATA = 8'h12;
					4'd3: DATA = 8'h13;
					4'd4: DATA = 8'h14;
					4'd5: DATA = 8'h15;
					4'd6: DATA = 8'h16;
					4'd7: DATA = 8'h17;
					4'd8: DATA = 8'h18;
					4'd9: DATA = 8'h19;
				endcase
			end
			7'd95: DATA = 8'h5F; // finish	
			default:DATA = 8'h00;
		endcase
	end
endmodule
