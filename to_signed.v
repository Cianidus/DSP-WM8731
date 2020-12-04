module to_signed (
input clk, 
input we, 
input [15:0] i_data, 
output reg signed [15:0] o_data,
output reg re
);

always @(posedge clk)
begin
    if(we)
    begin
        re<=1;
        if(i_data < 16'h8000) begin
			  o_data[14:0] <= ~i_data[14:0];
			  o_data[15] <= 1;
		  end
        else begin
			  o_data[14:0] <= i_data[14:0];
			  o_data[15] <= 0;
		  end
    end
    else re <= 0;
end
endmodule 