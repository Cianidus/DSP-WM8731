module to_unsigned (
input clk,  
input we, 
input signed [33:0] i_data, 
output reg [15:0] o_data,
output reg re
);
wire [15:0] trunc_data;

assign trunc_data = i_data[33:16];

always @(posedge clk)
begin
    if(we)
    begin
        re<=1;
        if(i_data > 16'h8000) begin
			  o_data[14:0] <= ~i_data[14:0];
			  o_data[15] <= 0;
		  end
        else begin
			  o_data[14:0] <= i_data[14:0];
			  o_data[15] <= 1;
		  end
    end
    else re <= 0;
end
endmodule 