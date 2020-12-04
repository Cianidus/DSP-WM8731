/***************************************/
//	Author: Ahmad Alastal 				   //
//												   //
//	Completion date: 25/7/2019 11.00PM  //
//												   //
//	Title: WM8731 Audio CODEC demo	   //
//												   //
//	Main function: Audio demonstration  //
/***************************************/
module i2c_config (
	input clk,reset,
	inout SDIN,
	output SCLK,
	output [2:0] ACK_LEDR
);
reg [3:0] counter; //selecting register address and its corresponding data
reg counting_state,ignition,read_enable; 	
reg [15:0] MUX_input;
reg [17:0] read_counter;
wire finish_flag;

//============================================
//Instantiation section
I2C_Protocol I2C(
	.clk(clk),
	.reset(reset),
	.ignition(ignition),
	.MUX_input(MUX_input),
	.ACK(ACK_LEDR),
	.SDIN(SDIN),
	.finish_flag(finish_flag),
	.SCLK(SCLK)
);

// generate 6 configuration pulses 
always @(posedge clk)
	begin
	if(!reset) 
		begin
		counting_state <= 0;
		read_enable <= 0;
		end
	else
		begin
		case(counting_state)
		0:
			begin
			ignition <= 1;
			read_enable <= 0;
			if(counter == 8) counting_state <= 1; //was 8
			end
		1:
			begin
			read_enable <= 1;
			ignition <= 0;
			end
		endcase
		end
	end
//============================================
// this counter is used to switch between registers
always @(posedge SCLK)
	begin
		case(counter) //MUX_input[15:9] register address, MUX_input[8:0] register data
		0: MUX_input <= 16'h1201; // activate interface
		1: MUX_input <= 16'h0460; // left headphone out
		2: MUX_input <= 16'h0C00; // power down control
		3: MUX_input <= 16'h0812; // analog audio path control
		4: MUX_input <= 16'h0A00; // digital audio path control
		5: MUX_input <= 16'h102F; // sampling control
		6: MUX_input <= 16'h0E23; // digital audio interface format
		7: MUX_input <= 16'h0660; // right headphone out
		8: MUX_input <= 16'h1E00; // reset device
		endcase
	end
always @(posedge finish_flag)
	begin
	counter <= counter + 1;
	end
endmodule 