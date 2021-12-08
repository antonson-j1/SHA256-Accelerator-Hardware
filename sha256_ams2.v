`timescale 1ns/1ns 

module sha256_tb ();
    
    reg  clk, reset;
    wire ready;
    wire [255:0] hashvalue;
    
    always #5 clk=~clk;
    
    wire [0:511] message;
    assign message = 512'b01110000011100100110111101101010011001010110001101110100011001100111000001100111011000010010111001100011011011110110110110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001111000;
    
    wire [255:0] h;
    wire [31:0] k[0:63];
    
    integer i;
    initial begin
        clk = 1;
        reset = 1;
        #100;
        reset = 0;
        i = 0;
        while (ready == 0) begin
            @(posedge clk) i++;
            $display("Output %h Count %d", hashvalue, i);
        end
        //if(ready) $finish;
    
    end 
    
    //$display("Output %h", hashvalue);
        
    overall sha_core(
        .message(message),
        .clk(clk),
        .reset(reset),
        .ready(ready),
        .hashvalue(hashvalue)
    );
            
endmodule
    





module s0(
    input  wire [31:0] X,
    output wire [31:0] Y);
    assign Y = ( {X[6:0],X[31:7]} ^ {X[17:0],X[31:18]} ^ X>>3 );
endmodule
    
module s1(
    input  wire [31:0] X,
    output wire [31:0] Y);
    assign Y = ( {X[16:0],X[31:17]} ^ {X[18:0],X[31:19]} ^ X>>10 );
endmodule

module w_new_calc(
    input wire  [31:0] w_16,
    input wire  [31:0] w_15,
    input wire  [31:0] w_7,
    input wire  [31:0] w_2,
    output wire [31:0] w_new);
    
    wire [31:0] temp1, temp2;

    s0 s0(
        .X(w_15) ,
        .Y(temp1));
    
    s1 s1(
        .X(w_2)  ,
        .Y(temp2));

    assign w_new = temp1 + temp2 + w_16 + w_7;
endmodule






module overall(
    input wire [0:511] message,
    input wire clk,
    input wire reset,
    output reg ready,
    output wire [255:0] hashvalue);
    
    wire [31:0] k[0:63];
    assign k[00] = 32'h428a2f98;
    assign k[01] = 32'h71374491;
    assign k[02] = 32'hb5c0fbcf;
    assign k[03] = 32'he9b5dba5;
    assign k[04] = 32'h3956c25b;
    assign k[05] = 32'h59f111f1;
    assign k[06] = 32'h923f82a4;
    assign k[07] = 32'hab1c5ed5;
    assign k[08] = 32'hd807aa98;
    assign k[09] = 32'h12835b01;
    assign k[10] = 32'h243185be;
    assign k[11] = 32'h550c7dc3;
    assign k[12] = 32'h72be5d74;
    assign k[13] = 32'h80deb1fe;
    assign k[14] = 32'h9bdc06a7;
    assign k[15] = 32'hc19bf174;
    assign k[16] = 32'he49b69c1;
    assign k[17] = 32'hefbe4786;
    assign k[18] = 32'h0fc19dc6;
    assign k[19] = 32'h240ca1cc;
    assign k[20] = 32'h2de92c6f;
    assign k[21] = 32'h4a7484aa;
    assign k[22] = 32'h5cb0a9dc;
    assign k[23] = 32'h76f988da;
    assign k[24] = 32'h983e5152;
    assign k[25] = 32'ha831c66d;
    assign k[26] = 32'hb00327c8;
    assign k[27] = 32'hbf597fc7;
    assign k[28] = 32'hc6e00bf3;
    assign k[29] = 32'hd5a79147;
    assign k[30] = 32'h06ca6351;
    assign k[31] = 32'h14292967;
    assign k[32] = 32'h27b70a85;
    assign k[33] = 32'h2e1b2138;
    assign k[34] = 32'h4d2c6dfc;
    assign k[35] = 32'h53380d13;
    assign k[36] = 32'h650a7354;
    assign k[37] = 32'h766a0abb;
    assign k[38] = 32'h81c2c92e;
    assign k[39] = 32'h92722c85;
    assign k[40] = 32'ha2bfe8a1;
    assign k[41] = 32'ha81a664b;
    assign k[42] = 32'hc24b8b70;
    assign k[43] = 32'hc76c51a3;
    assign k[44] = 32'hd192e819;
    assign k[45] = 32'hd6990624;
    assign k[46] = 32'hf40e3585;
    assign k[47] = 32'h106aa070;
    assign k[48] = 32'h19a4c116;
    assign k[49] = 32'h1e376c08;
    assign k[50] = 32'h2748774c;
    assign k[51] = 32'h34b0bcb5;
    assign k[52] = 32'h391c0cb3;
    assign k[53] = 32'h4ed8aa4a;
    assign k[54] = 32'h5b9cca4f;
    assign k[55] = 32'h682e6ff3;
    assign k[56] = 32'h748f82ee;
    assign k[57] = 32'h78a5636f;
    assign k[58] = 32'h84c87814;
    assign k[59] = 32'h8cc70208;
    assign k[60] = 32'h90befffa;
    assign k[61] = 32'ha4506ceb;
    assign k[62] = 32'hbef9a3f7;
    assign k[63] = 32'hc67178f2;

    wire [31:0] h0, h1, h2, h3, h4, h5, h6, h7;
    assign h0 = 32'h6a09e667;
    assign h1 = 32'hbb67ae85;
    assign h2 = 32'h3c6ef372;
    assign h3 = 32'ha54ff53a;
    assign h4 = 32'h510e527f;
    assign h5 = 32'h9b05688c;
    assign h6 = 32'h1f83d9ab;
    assign h7 = 32'h5be0cd19;    
    
    reg [31:0] w[0:63];
    
    wire [31:0] temp1, temp2;
    reg [6:0] count_1, count16_1, count15_1, count7_1, count2_1;
    reg [6:0] count_2, count16_2, count15_2, count7_2, count2_2;
    reg done;
    
    w_new_calc w_new_calc1(
        .w_16 (w[count16_1]),
        .w_15 (w[count15_1]),
        .w_7  (w[count7_1] ),
        .w_2  (w[count2_1] ),
        .w_new(temp1));    

    w_new_calc w_new_calc2(
        .w_16 (w[count16_2]),
        .w_15 (w[count15_2]),
        .w_7  (w[count7_2] ),
        .w_2  (w[count2_2] ),
        .w_new(temp2));    

        
    reg [31:0] w_new1, w_new2;
    always @(*) begin
        if(done == 1'b1) begin w_new2 = w[63]; w_new1 = w[62]; end
        else             begin w_new2 = temp2; w_new1 = temp1; end
    end
    
    integer i;    
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            count16_1   <= 7'd0;
            count15_1   <= 7'd1;
            count7_1    <= 7'd9;
            count2_1    <= 7'd14;
            count_1     <= 7'd16;
            
            count16_2   <= 7'd1;
            count15_2   <= 7'd2;
            count7_2    <= 7'd10;
            count2_2    <= 7'd15;
            count_2    <= 7'd17;
            
            for(i = 0; i < 16; i++) begin
                w[i] <= message[32*i +: 32];
                //$display("i %d w[i] %h message %b", i, w[i], message[32*i +: 31]);
            end
            for(i = 16; i < 64; i++)
                w[i] <= 32'b0;
        end
        
        else begin
            count2_1    <= count2_1    + 2;
            count7_1    <= count7_1    + 2;
            count15_1   <= count15_1   + 2;
            count16_1   <= count16_1   + 2;
            
            count2_2    <= count2_2    + 2;
            count7_2    <= count7_2    + 2;
            count15_2   <= count15_2   + 2;
            count16_2   <= count16_2   + 2;
            
            w[count_1]  <= w_new1;
            w[count_2]  <= w_new2;
            
            if(count_2 == 7'd63) begin 
                count_1 <= count_1; 
                count_2 <= count_2;     
                done <= 1'b1; 
            end
            else begin 
                count_1 <= count_1 + 2; 
                count_2 <= count_2 + 2;
                done <= 1'b0; 
            end
        end
        /*if(count == 7'd63) begin
            $display("count16 %d count15 %d count7 %d count2 %d temp = %h", w[count16], w[count15], w[count7], w[count2], temp); 
            for(i = 0; i < 64; i++)
                $display("i: %d w[i]: %h", i, w[i]);
        end*/
    end
    
    reg [6:0] count_hash;
    reg reset_hash;
    always @(posedge clk) reset_hash <= reset;
    
    always @(posedge clk or posedge reset_hash) begin
        //$display("Output %h", hashvalue);
        if(reset_hash) begin
            count_hash   <= 7'd0;
            ready   <= 1'b0;
        end
        else begin
            if(count_hash == 7'd63) begin count_hash <= count_hash; ready <= 1'b1; end
            else                    begin count_hash <= count_hash + 1; ready <= 1'b0; end
        end
    end
    
    wire select;
    assign select = ~ready;
    
    reg [31:0] w_value, k_value;
    
    always @(posedge clk or posedge reset_hash) begin
        /*if(ready == 1'b0)
            $display("reset %d count_hash %d w_value %h k_value %h count %d", reset_hash, count_hash, w_value, k_value, ready, count);*/
        if(reset_hash) begin
            w_value <= w[0];
            k_value <= k[0];
        end
        else begin
            if(count_hash <= 7'd62) begin
                w_value <= w[count_hash + 1];
                k_value <= k[count_hash + 1];
            end
            else begin
                w_value <= 32'b0;
                k_value <= 32'b0;
            end
        end
    end
    
    hash_output hash(
        .reset(reset_hash),
        .w_i(w_value),
        .k_i(k_value),
        .select(select),
        .clk(clk),
        .h0(h0),
        .h1(h1),
        .h2(h2),
        .h3(h3),
        .h4(h4),
        .h5(h5),
        .h6(h6),
        .h7(h7),
        .hashvalue(hashvalue));
    
endmodule





module hash_output(
    input reset,
    input [31:0] w_i,
    input [31:0] k_i,
    input clk,
    
    input select,
    
    input [31:0] h0,
    input [31:0] h1,
    input [31:0] h2,
    input [31:0] h3,
    input [31:0] h4,
    input [31:0] h5,
    input [31:0] h6,
    input [31:0] h7,
    
    output [255:0] hashvalue);
    
    reg [31:0] a, b, c, d, e, f, g, h;
    wire [31:0]  a_new, b_new, c_new, d_new, e_new, f_new, g_new, h_new; 
    
    compression_algorithm CA0(
        .k_i(k_i),
        .w_i(w_i),
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .e(e),
        .f(f),
        .g(g),
        .h(h),
        .a_new(a_new),
        .b_new(b_new),
        .c_new(c_new),
        .d_new(d_new),
        .e_new(e_new),
        .f_new(f_new),
        .g_new(g_new),
        .h_new(h_new));
    
        
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            a     <= h0;
            b     <= h1;
            c     <= h2;
            d     <= h3;
            e     <= h4;
            f     <= h5;
            g     <= h6;
            h     <= h7;
        end
        else begin
            if(select) begin
                a     <= a_new;
                b     <= b_new;
                c     <= c_new;
                d     <= d_new;
                e     <= e_new;
                f     <= f_new;
                g     <= g_new;
                h     <= h_new;
            end
            else begin
                a     <= a;
                b     <= b;
                c     <= c;
                d     <= d;
                e     <= e;
                f     <= f;
                g     <= g;
                h     <= h;
            end                
        end
    end
    
    wire [31:0] h0_out, h1_out, h2_out, h3_out, h4_out, h5_out, h6_out, h7_out;
    assign h0_out = h0 + a;
    assign h1_out = h1 + b;
    assign h2_out = h2 + c;
    assign h3_out = h3 + d;
    assign h4_out = h4 + e;
    assign h5_out = h5 + f;
    assign h6_out = h6 + g;
    assign h7_out = h7 + h;
    
    assign hashvalue = {h0_out, h1_out, h2_out, h3_out, h4_out, h5_out, h6_out, h7_out};

endmodule
    


module S0(
    input  wire [31:0] X,
    output wire [31:0] Y);
    assign Y = ( {X[1:0],X[31:2]} ^ {X[12:0],X[31:13]} ^ {X[21:0],X[31:22]} );
endmodule
    
module S1(
    input  wire [31:0] X,
    output wire [31:0] Y);
    assign Y = ( {X[5:0],X[31:6]} ^ {X[10:0],X[31:11]} ^ {X[24:0],X[31:25]} );
endmodule

module compression_algorithm(
    input wire [31:0] k_i,
    input wire [31:0] w_i,
    
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [31:0] c,
    input wire [31:0] d,
    input wire [31:0] e,
    input wire [31:0] f,
    input wire [31:0] g,
    input wire [31:0] h,
    
    output wire [31:0] a_new,
    output wire [31:0] b_new,
    output wire [31:0] c_new,
    output wire [31:0] d_new,
    output wire [31:0] e_new,
    output wire [31:0] f_new,
    output wire [31:0] g_new,
    output wire [31:0] h_new);
    
    
    wire [31:0] ch, temp1, temp2, maj, t1, t2, t3, t4;

    S1 S1(
        .X(e)  ,
        .Y(t1));
    
    S0 S0(
        .X(a) ,
        .Y(t2));
    
    assign ch    = (e & f) ^ ((~e) & g);
    assign temp1 = h + t1 + ch + k_i+  w_i;
    assign maj   = (a & b) ^ (a & c) ^ (b & c);
    assign temp2 = t2 + maj;
        
    assign h_new = g;
    assign g_new = f;
    assign f_new = e;
    assign e_new = d + temp1;
    assign d_new = c;
    assign c_new = b;
    assign b_new = a;
    assign a_new = temp1 + temp2;

endmodule