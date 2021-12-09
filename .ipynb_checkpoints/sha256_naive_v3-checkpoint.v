module overall(
    input wire [511:0] data_in,
    input wire clk,
    input wire reset,
    input wire [31:0] k[0:63],
    input wire [255:0] h, 
    output wire ready,
    output wire [255:0] hashvalue);
    
    
    wire message [511:0];
    reg [55:0] add_block; 
    reg [63:0] m_size;  // l 64-bit number encoded for representing the length of input message
    reg overflow;

    m_size= $size(data_in);
    add_block=$bits(data_in);
    overflow=1'b0;
    message[add_block:0]=data_in;
    
    always@(posedge clk)
    begin
        if(add_block<448)
            begin
                message[448-add_block:0]=0;
                message[511:448]=m_size;
            end
        else
            begin
                overflow=1'b1;
            end
    end
   
    
    reg [31:0] w[0:63];
    reg [31:0] w_value, k_value;
    
    wire [31:0] h0, h1, h2, h3, h4, h5, h6, h7;
    
    assign h0 = h[255:224];
    assign h1 = h[223:192];
    assign h2 = h[191:160];
    assign h3 = h[159:128];
    assign h4 = h[127:96];
    assign h5 = h[95:64];
    assign h6 = h[63:32];
    assign h7 = h[31:0];
    
    
    
    w_i_update w_i_extension(
        .message(message),
        .reset(reset),
        .clk(clk),
        .w(w));
    
    hash_output hash(
        .reset(reset_hash),
        .w(w),
        .k(k),
        .clk(clk),
        .h0(h0),
        .h1(h1),
        .h2(h2),
        .h3(h3),
        .h4(h4),
        .h5(h5),
        .h6(h6),
        .h7(h7),
        .ready(ready),
        .hashvalue(hashvalue));
    
    always @(posedge clk) reset_hash <= reset;
    
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

    assign temp = temp1 + temp2 + w_16 + w_7;
endmodule


module w_i_update(
    input wire [511:0] message,
    input wire reset,
    input clk,
    output reg [31:0] w[0:63]
);
    
    wire [31:0] temp;
    wire [31:0] w_new;
    reg [6:0] count, count16, count15, count7, count2, count_inc;
    
    w_new_calc w_new(
        .w_16 (w[count16]),
        .w_15 (w[count15]),
        .w_7  (w[count7] ),
        .w_2  (w[count2] ),
        .w_new(temp));    
    
    assign w_new = (count_inc >= 7'd64) ? w[count] : temp;
    
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            count16   <= 7'd0;
            count15   <= 7'd1;
            count7    <= 7'd9;
            count2    <= 7'd14;
            count     <= 7'd16;
            count_inc <= 7'd17;
            for(i = 0; i < 16; i++)
                w[i] <= message[32*i + 31: 32*i];
            for(i = 16; i < 64; i++)
                w[i] <= 32'b0;
        end
        else begin
            count2    <= count2    + 1;
            count7    <= count7    + 1;
            count15   <= count15   + 1;
            count16   <= count16   + 1;
            count_inc <= count_inc + 1;
            w[count]  <= w_new;
            if(count_inc >= 7'd64) count <= count;
            else                   count <= count + 1;
        end
    end
    
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
    assign temp2 = temp1 + maj;
        
    assign h_new = g;
    assign g_new = f;
    assign f_new = e;
    assign e_new = d + temp1;
    assign d_new = c;
    assign c_new = b;
    assign b_new = a;
    assign a_new = temp1 + temp2;

endmodule

module hash_output(
    input reset,
    input [31:0] w,
    input [31:0] k,
    input clk,
    
    input [31:0] h0,
    input [31:0] h1,
    input [31:0] h2,
    input [31:0] h3,
    input [31:0] h4,
    input [31:0] h5,
    input [31:0] h6,
    input [31:0] h7,
    
    output reg ready,
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
    
    reg [31:0] w_i, k_i;
    
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            w_i <= w[0];
            k_i <= k[0];
        end
        else begin
            if(count <= 7'd62) begin
                w_i <= w[count + 1];
                k_i <= k[count + 1];
            end
            else begin
                w_i <= 32'b0;
                k_i <= 32'b0;
            end
        end
    end
    
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
            count <= 7'd0;
            ready <= 1'b0;
        end
        else begin
            count <= count + 1;
            if(count <= 7'd63) begin
                a     <= a_new;
                b     <= b_new;
                c     <= c_new;
                d     <= d_new;
                e     <= e_new;
                f     <= f_new;
                g     <= g_new;
                h     <= h_new;
                ready <= 1'b0;
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
                ready <= 1'b1;
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