module Main
(
	input  wire clockIN,
	input  wire uartRxIN,
	output wire uartTxOUT
);

defparam uart.CLOCK_FREQUENCY = 50_000_000;
defparam uart.BAUD_RATE       = 921600;

reg [7:0] txData;
reg txLoad  = 1'b0;

wire txReset = 1'b1;
wire rxReset = 1'b1;
wire [7:0] rxData;
wire txIdle;
wire txReady;
wire rxIdle;
wire rxReady;

UART uart
(
	.clockIN(clockIN),
	
	.nTxResetIN(txReset),
	.txDataIN(txData),
	.txLoadIN(txLoad),
	.txIdleOUT(txIdle),
	.txReadyOUT(txReady),
	.txOUT(uartTxOUT),
	
	.nRxResetIN(rxReset),
	.rxIN(uartRxIN), 
	.rxIdleOUT(rxIdle),
	.rxReadyOUT(rxReady),
	.rxDataOUT(rxData)
);

always @(posedge rxReady or negedge txReady) begin
	if(~txReady)
		txLoad <= 1'b0;
	else if(rxReady) begin
		txLoad <= 1'b1;
		txData <= rxData;
	end
end

endmodule 