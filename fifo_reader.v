module fifo_driver (input clk, input rd_en, input rst, input [15:0] i_data,  output reg data_valid, output reg [7:0] o_data);
reg [1:0] cnt = 0;
reg work_driver;
always @(posedge clk)
begin
    if (!rst)
    begin
        data_valid <= 0;
        o_data <= 0;
        cnt <= 0;    
    end
    else begin
    if(rd_en)
        begin
        if(cnt == 0) begin
            o_data <= i_data[15:8];
            data_valid <= 1;
            cnt <= cnt+1;     
            end
        if(cnt == 1) begin 
            o_data <= i_data[7:0];
            data_valid <= 1;  
            cnt <= cnt+1;     
            end 
        if(cnt > 1) begin
            data_valid <= 0;
            end           
        end
    else begin
        cnt <= 0;
    end
    end
end

endmodule 