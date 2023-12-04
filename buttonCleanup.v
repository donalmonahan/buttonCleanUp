//////////////////////////////////////////////////////////////////////////////////
// Engineer:      Donal Monahan
// Target Device: XC7A100T-csg324 on Digilent Nexys 4 board
// Description:   Button clean-up module to deal with bounce.
//                Takes input from button and returns output when a press occurs.
//                Designed for a 5 MHz clock and synchronous reset.
//                
//  Created: 15 November 2023
//  
//////////////////////////////////////////////////////////////////////////////////

module buttonCleanup(
	input clk,								// 5 MHz clock signal
	input rst,								// reset signal
	input button,							// input signal from button
	output press							// output indicating successful press; goes high when changed is 1 and lastChanged is 0
	) ;
	
	// declare signals
	localparam [15:0] MAXCOUNT = 16'd40000;	// (clk freq 5 MHz) * (max bounce interval 8 ms) = (40k clock cycle threshold)
	localparam [15:0] ZEROS = 16'd0;		// 16-bit zero signal
	localparam [15:0] ONE = 16'd1;			// 16-bit one signal
	wire [15:0] sum;						// output from adder
	reg [15:0] nextCount;					// input to register storing count value
	reg [15:0] count;						// count value
	wire changed;							// output from comparison block; goes high when MAXCOUNT reached
	reg lastChanged;						// output from comparison block during last clock cycle
	
	// multiplexer to select nextCount value
	always @ (button or changed or sum)
		if (button && !changed) nextCount = sum;
		else if (button && changed) nextCount = MAXCOUNT;
		else nextCount = ZEROS;
		
	// register to store count value
	always @ (posedge clk)
		if (rst) count = ZEROS;
		else count = nextCount;
		
	// adder
	assign sum = count + ONE;
	
	// comparison block to detect count reaching MAXCOUNT
	assign changed = (count == MAXCOUNT);
	
	// register to store lastChanged value
	always @ (posedge clk)
		if (rst) lastChanged = ZEROS;
		else lastChanged = changed;
	
	// ANDing changed and the negation of lastChanged
	assign press = (changed && !lastChanged);
	
endmodule