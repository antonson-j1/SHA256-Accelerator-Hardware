`define width 32
`define ctrwidth 6
module seq_mult (
				// Outputs
    			p, rdy, 
				// Inputs
				clk, reset, a, b
				) ;

	input 		 			clk, reset;
	input 	[`width-1:0]	a, b;
	// *** Output declaration for 'p'
	output 	[2*`width-1:0] 	p;
	output 		 			rdy;
	
	// *** Register declarations for p, multiplier, multiplicand
	reg [2*`width-1:0] 	p;
	reg [2*`width-1:0] 	multiplier;
	reg [2*`width-1:0] 	multiplicand;
	reg 			 	rdy;
	reg [`ctrwidth:0] 	ctr;


    always @(posedge clk or posedge reset) 
	begin
    	if (reset) 
		begin
			rdy 			<= 0;
			p 				<= 0;
			ctr 			<= 0;
			multiplier 		<= {{`width{a[`width-1]}}, a}; // sign-extend
			multiplicand 	<= {{`width{b[`width-1]}}, b}; // sign-extend
    	end 
	 	
		else 
		begin 
			if (ctr < 2*`width ) /* *** How many times should the loop run? */
			begin
			// *** Code for multiplication
				multiplicand <= multiplicand << 1;

				if (multiplier[ctr]==1)
				begin
					p <= p + multiplicand;
				end

				ctr <= ctr + 1;
			end
		
			else 
			begin
				rdy <= 1; 		// Assert 'rdy' signal to indicate end of multiplication
	  		end
		end
    end
   
endmodule // seqmult