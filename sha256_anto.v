`timescale 1ns/1ns 

module sha256_tb ();
    
    reg  clk, reset;
    wire ready;
    wire [255:0] hashvalue;
    
    //wire [31:0] W_tm2, W_tm7, W_tm15, W_tm16;
    
    always #5 clk=~clk;
    
    wire [511:0] message;
    assign message = 512'b01110000011100100110111101101010011001010110001101110100011001100111000001100111011000010010111001100011011011110110110110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001111000;
    
    //assign message = 512'd1;
    
    integer i;
    initial begin
        clk = 1;
        reset = 0;
        #100
        reset = 1;
        #100
        reset = 0;

        for (i=0; i<1000; i=i+1) begin
            @(posedge clk);
            $display("Count %d, Output %h, Ready %d", i, hashvalue, ready);
            //$display("count = %d, W2 = %h, W7 = %h, W15 = %h, W16 = %h", i, W_tm2, W_tm7, W_tm15, W_tm16);
            if (ready) begin
                $finish;
            end
        end
        
        //$display("Output %h", hashvalue);
    end 
    
    sha256_block sha256_block(
        .clk(clk),
        .M_in(message),
        .input_valid(reset),
        .H_out(hashvalue),
        .output_valid(ready)
        //.W_tm2(W_tm2), .W_tm7(W_tm2), .W_tm15(W_tm2), .W_tm16(W_tm2)
    );
            
endmodule




module sha256_block (
    input clk,
    input [511:0] M_in,
    input input_valid,
    output [255:0] H_out,
    output output_valid
    //output [31:0] W_tm2, W_tm7, W_tm15, W_tm16
);

    reg [6:0] round;
    
    wire [31:0] a_in = 32'h6A09E667;
    wire [31:0] b_in = 32'hBB67AE85;
    wire [31:0] c_in = 32'h3C6EF372;
    wire [31:0] d_in = 32'hA54FF53A;
    wire [31:0] e_in = 32'h510E527F;
    wire [31:0] f_in = 32'h9B05688C;
    wire [31:0] g_in = 32'h1F83D9AB;
    wire [31:0] h_in = 32'h5BE0CD19;

    reg [31:0] a_q, b_q, c_q, d_q, e_q, f_q, g_q, h_q;
    wire [31:0] a_d, b_d, c_d, d_d, e_d, f_d, g_d, h_d;
    wire [31:0] W_tm2, W_tm15, s1_Wtm2, s0_Wtm15, Wj, Kj;
    
    assign H_out = {
        a_in + a_q, b_in + b_q, c_in + c_q, d_in + d_q, e_in + e_q, f_in + f_q, g_in + g_q, h_in + h_q
    };

    assign output_valid = (round == 64);

    always @(posedge clk)
    begin
        if (input_valid) begin
            a_q <= a_in;
            b_q <= b_in;
            c_q <= c_in; 
            d_q <= d_in;
            e_q <= e_in; 
            f_q <= f_in; 
            g_q <= g_in; 
            h_q <= h_in;
            round <= 0;
        end else begin
            a_q <= a_d;
            b_q <= b_d;
            c_q <= c_d;
            d_q <= d_d;
            e_q <= e_d;
            f_q <= f_d;
            g_q <= g_d;
            h_q <= h_d;
            round <= round + 1;
        end
    end

    sha256_round sha256_round (
        .Kj(Kj), 
        .Wj(Wj),
        .a_in(a_q), 
        .b_in(b_q), 
        .c_in(c_q), 
        .d_in(d_q),
        .e_in(e_q), 
        .f_in(f_q), 
        .g_in(g_q), 
        .h_in(h_q),
        .a_out(a_d), 
        .b_out(b_d), 
        .c_out(c_d), 
        .d_out(d_d),
        .e_out(e_d), 
        .f_out(f_d), 
        .g_out(g_d), 
        .h_out(h_d)
    );


    assign s0_Wtm15 = ({W_tm15[6:0], W_tm15[31:7]} ^ {W_tm15[17:0], W_tm15[31:18]} ^ (W_tm15 >> 3));
    assign s1_Wtm2 = ({W_tm2[16:0], W_tm2[31:17]} ^ {W_tm2[18:0], W_tm2[31:19]} ^ (W_tm2 >> 10));


    reg [511:0] W_stack_q;
    wire [511:0] W_stack_d = {W_stack_q[479:0], Wt_next};

    assign Wj = W_stack_q[511:480];
    assign W_tm2 = W_stack_q[63:32];
    assign W_tm15 = W_stack_q[479:448];

    wire [31:0] W_tm7 = W_stack_q[223:192];
    wire [31:0] W_tm16 = W_stack_q[511:480];

    wire [31:0] Wt_next = s1_Wtm2 + W_tm7 + s0_Wtm15 + W_tm16;

    //integer j = 0;
    always @(posedge clk)
    begin
        //j = j+1;
        if (input_valid) begin
            W_stack_q <= M_in;
        end else begin
            W_stack_q <= W_stack_d;
        end
    end

    // will be getting it from Hariharan
    sha256_K_machine sha256_K_machine (
        .clk(clk), 
        .rst(input_valid), 
        .K(Kj)
    );
    
    //$display("count = %d, W2 = %h, W7 = %h, W15 = %h, W16 = %h", j, W_tm2, W_tm7, W_tm15, W_tm16);

endmodule




module sha256_K_machine (
    input clk,
    input rst,
    output [31:0] K
    );

    reg [2047:0] rom_q;
    wire [2047:0] rom_d = { rom_q[2015:0], rom_q[2047:2016] };
    assign K = rom_q[2047:2016];

    always @(posedge clk)
    begin
        if (rst) begin
            rom_q <= {
                32'h428a2f98, 32'h71374491, 32'hb5c0fbcf, 32'he9b5dba5,
                32'h3956c25b, 32'h59f111f1, 32'h923f82a4, 32'hab1c5ed5,
                32'hd807aa98, 32'h12835b01, 32'h243185be, 32'h550c7dc3,
                32'h72be5d74, 32'h80deb1fe, 32'h9bdc06a7, 32'hc19bf174,
                32'he49b69c1, 32'hefbe4786, 32'h0fc19dc6, 32'h240ca1cc,
                32'h2de92c6f, 32'h4a7484aa, 32'h5cb0a9dc, 32'h76f988da,
                32'h983e5152, 32'ha831c66d, 32'hb00327c8, 32'hbf597fc7,
                32'hc6e00bf3, 32'hd5a79147, 32'h06ca6351, 32'h14292967,
                32'h27b70a85, 32'h2e1b2138, 32'h4d2c6dfc, 32'h53380d13,
                32'h650a7354, 32'h766a0abb, 32'h81c2c92e, 32'h92722c85,
                32'ha2bfe8a1, 32'ha81a664b, 32'hc24b8b70, 32'hc76c51a3,
                32'hd192e819, 32'hd6990624, 32'hf40e3585, 32'h106aa070,
                32'h19a4c116, 32'h1e376c08, 32'h2748774c, 32'h34b0bcb5,
                32'h391c0cb3, 32'h4ed8aa4a, 32'h5b9cca4f, 32'h682e6ff3,
                32'h748f82ee, 32'h78a5636f, 32'h84c87814, 32'h8cc70208,
                32'h90befffa, 32'ha4506ceb, 32'hbef9a3f7, 32'hc67178f2
            };
        end else begin
            rom_q <= rom_d;
        end
    end

endmodule



module sha256_round (
    input [31:0] Kj, Wj,
    input [31:0] a_in, b_in, c_in, d_in, e_in, f_in, g_in, h_in,
    output [31:0] a_out, b_out, c_out, d_out, e_out, f_out, g_out, h_out
    );

    wire [31:0] Ch_efg, Maj_abc, S0_a, S1_e;

    assign Ch_efg = ((e_in & f_in) ^ (~(e_in) & g_in));
    assign Maj_abc = (a_in & b_in) ^ (a_in & c_in) ^ (b_in & c_in);

    assign S0_a = ({a_in[1:0], a_in[31:2]} ^ {a_in[12:0], a_in[31:13]} ^ {a_in[21:0], a_in[31:22]});
    assign S1_e = ({e_in[5:0], e_in[31:6]} ^ {e_in[10:0], e_in[31:11]} ^ {e_in[24:0], e_in[31:25]});

    wire [31:0] T1 = h_in + S1_e + Ch_efg + Kj + Wj;
    wire [31:0] T2 = S0_a + Maj_abc;

    assign a_out = T1 + T2;
    assign b_out = a_in;
    assign c_out = b_in;
    assign d_out = c_in;
    assign e_out = d_in + T1;
    assign f_out = e_in;
    assign g_out = f_in;
    assign h_out = g_in;

endmodule


/*module m_pader_parser(
    input clk,rst,byte_rdy,byte_stop,
    input [7:0] data_in,
	output reg overflow_err,flag_0_15,
    output reg [31:0] padd_out,
    output reg padding_done,
    output reg strt_a_h
    );
												//we only need to take 32-bit data in one cycle
	 reg [7:0] block_512 [63:0]; //8bit word * 64 add = 512
	 reg [6:0] add_512_block; // Memory Address Register !7 bit reg can address 127 loc max
	 reg [63:0] m_size;  // l 64-bit number encoded for representing the length of input message
	 reg temp_chk; //to run if(temp_chk) func only once in if(stop_byte)
	 
	 reg [6:0] add_out0;
	 reg [6:0] add_out1;
	 reg [6:0] add_out2;
	 reg [6:0] add_out3;
	 
	 
	 always@(posedge clk)
	 begin
	 if(rst==0)
	 begin
		add_out0=7'd0;
		add_out1=7'd1;
		add_out2=7'd2;
		add_out3=7'd3;
		add_512_block=7'd0;
		m_size=64'd0;
		padding_done=1'b0;
		padd_out=32'd0;
		overflow_err=1'b0;
		temp_chk=1'b0;
		flag_0_15=1'b0;
		strt_a_h=1'b0;
	 end
	 else
	 begin
	 if(byte_rdy) //data stop byte received and checked by UART and byte_rdy=1
	 begin
	 block_512[add_512_block]=data_in;
	 add_512_block=add_512_block+1;
	 end
	 else  	//byte_rdy would go down after byte is tranferd and UART is in IDLE
				//else start padding when stop byte is received 
	 begin
		if(byte_stop)
		begin
					//padding begins
			if(add_512_block<55)
			begin
				if(temp_chk==0)
				begin
				padding_done=1'b0; //in progress
				m_size[63:0]=(add_512_block)*8; //add is incremented but we also start add from '0' so its good
				block_512[add_512_block]=8'b1_000_0000; //as add_512_block is already on new location --->> add 1_000_0000 byte
				temp_chk=1'b1;
				end //no else
				
				if(add_512_block<55)
				begin
				
					case(add_512_block)
					7'd1: begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd2: begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd3: begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd4: begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd5: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd6: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd7: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd8: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd9: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd10: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd11: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd12: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd13: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd14: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd15: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd16: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd17: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd18: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd19: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd20: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd21: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd22: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd23: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd24: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd25: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd26: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd27: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd28: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd29: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd30: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd31: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd32: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd33: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd34: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd35: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd36: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd37: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd38: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd39: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd40: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd41: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd42: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd43: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd44: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd45: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd46: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd47: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd48: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd49: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd50: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd51: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd52: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd53: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd54: 
					begin
							add_512_block=add_512_block+1;
							block_512[add_512_block]=8'd0;
					end
					7'd55: 
					begin
							block_512[add_512_block]=8'd0; //last address for '0's of  K
					end
					
					default:
					begin
							overflow_err=1'b1; //if address was <55 still no case started
							padding_done=1'b0; //then there is an error 
					end
					
					endcase
				end
			end
			else
			begin
			strt_a_h=1'b1;//to start iterative_processing right after padding_done
			block_512[63]=m_size[7:0];
			block_512[62]=m_size[15:8];
			block_512[61]=m_size[23:16];
			block_512[60]=m_size[31:24];
			block_512[59]=m_size[39:32];	//allocating the 64-bit m_size in the block
			block_512[58]=m_size[47:40];
			block_512[57]=m_size[55:48];
			block_512[56]=m_size[63:56];  //block_512[56] location for LSB of 64-bit m_size
			
			padding_done=1'b1; //out this to start m_iteration
			
			end
		end
		else
		begin
		//avoiding stop byte check to keep less out flags
		end
	 end
	 
	 if(add_512_block==55 && byte_stop==0)	//to make sure data is less than or equal allowed space and
														// we have free space for padding
	 begin
	 overflow_err=1'b1;
	 padding_done=1'b0; //if overflow !! don't start Hashing
	 end
	 else
	 begin
	 overflow_err=1'b0;				//Overflow of input message
	 end
	 
	 if(padding_done==1)		//parsing
	 begin
		if(add_out0==0)		//set 0 in reset
		begin
			padd_out[7:0]=block_512[add_out3];
			padd_out[15:8]=block_512[add_out2];		//taken 32-bit data
			padd_out[23:16]=block_512[add_out1];
			padd_out[31:24]=block_512[add_out0];
			
			add_out0=add_out0+7'd4;
			add_out1=add_out1+7'd4;
			add_out2=add_out2+7'd4;		//to take 4 addresses in 1 cycle
			add_out3=add_out3+7'd4;
		
		end
		else
		begin
			if(add_out3<64)		//to stop after last location is addressed
			begin
			
			padd_out[7:0]=block_512[add_out3];
			padd_out[15:8]=block_512[add_out2];		//taken 32-bit data
			padd_out[23:16]=block_512[add_out1];
			padd_out[31:24]=block_512[add_out0];
			
			add_out0=add_out0+7'd4;
			add_out1=add_out1+7'd4;
			add_out2=add_out2+7'd4;		//to take 4 addresses in 1 cycle
			add_out3=add_out3+7'd4;
			
			end
			else
			begin
			flag_0_15=1'b1;
			end
		end
	 end
	 else
	 begin
	 //nothing
	 end
	 end
	 end
endmodule*/