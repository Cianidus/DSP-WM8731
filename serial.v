
module serial(clk,rst,rxd,txd,en,seg_data,key_input);

input clk,rst;
input rxd;        //�������ݽ��ն�
input key_input;  //��������

output[7:0] en;
output[7:0] seg_data;
reg[7:0] seg_data;
output txd;       //�������ݷ��Ͷ�
//output lowbit;


////////////////////inner reg////////////////////
reg[15:0] div_reg;//��Ƶ�������Ƶֵ�ɲ����ʾ����Ƶ���õ�Ƶ��8�������ʵ�ʱ��
reg[2:0]  div8_tras_reg;//�üĴ����ļ���ֵ��Ӧ����ʱ��ǰλ�ڵ�ʱ϶��
reg[2:0]  div8_rec_reg;//�üĴ����ļ���ֵ��Ӧ����ʱ��ǰλ�ڵ�ʱ϶��
reg[3:0] state_tras;//����״̬�Ĵ���
reg[3:0] state_rec;//����״̬�Ĵ���
reg clkbaud_tras;//�Բ�����ΪƵ�ʵķ���ʹ���ź�
reg clkbaud_rec;//�Բ�����ΪƵ�ʵĽ���ʹ���ź�
reg clkbaud8x;//��8��������ΪƵ�ʵ�ʱ�ӣ����������ǽ����ͻ�����һ��bit��ʱ�����ڷ�Ϊ8��ʱ϶

reg recstart;//��ʼ���ͱ�־
reg recstart_tmp;

reg trasstart;//��ʼ���ܱ�־

reg rxd_reg1;//���ռĴ���1
reg rxd_reg2;//���ռĴ���2����Ϊ��������Ϊ�첽�źţ������������
reg txd_reg;//���ͼĴ���
reg[7:0] rxd_buf;//�������ݻ���
reg[7:0] txd_buf;//�������ݻ���

reg[2:0] send_state;//ÿ�ΰ�����PC����"Welcome"�ַ��������Ƿ���״̬�Ĵ���
reg[19:0] cnt_delay;//��ʱȥ��������
reg start_delaycnt;//��ʼ��ʱ������־
reg key_entry1,key_entry2;//ȷ���м����±�־

////////////////////////////////////////////////
parameter div_par=16'hA3;
//��Ƶ��������ֵ�ɶ�Ӧ�Ĳ����ʼ������ã����˲�����Ƶ��ʱ��Ƶ���ǲ������ʵ�8	
//�����˴�ֵ��Ӧ9600�Ĳ����ʣ�����Ƶ����ʱ��Ƶ����9600*8  (CLK  50M)

////////////////////////////////////////////////
assign txd=txd_reg;
//assign lowbit=0;

assign en=0;//7��������ʹ���źŸ�ֵ

always@(posedge clk )
begin
	if(!rst) begin 
		cnt_delay<=0;
		start_delaycnt<=0;
	 end
	else if(start_delaycnt) begin
		if(cnt_delay!=20'd800000) begin
			cnt_delay<=cnt_delay+1;
		 end
		else begin
			cnt_delay<=0;
			start_delaycnt<=0;
		 end
	 end
	else begin
		if(!key_input&&cnt_delay==0)
				start_delaycnt<=1;
	 end
end

always@(posedge clk)
begin
	if(!rst) 
		key_entry1<=0;
	else begin
		if(key_entry2)
			key_entry1<=0;
		else if(cnt_delay==20'd800000) begin
			if(!key_input)
				key_entry1<=1;
		 end
	 end
end

always@(posedge clk )
begin
	if(!rst)
		div_reg<=0;
	else begin
		if(div_reg==div_par-1)
			div_reg<=0;
		else
			div_reg<=div_reg+1;
	 end
end

always@(posedge clk)//��Ƶ�õ�8�������ʵ�ʱ��
begin
	if(!rst)
		clkbaud8x<=0;
	else if(div_reg==div_par-1)
		clkbaud8x<=~clkbaud8x;
end


always@(posedge clkbaud8x or negedge rst)
begin
	if(!rst)
		div8_rec_reg<=0;
	else if(recstart)//���տ�ʼ��־
		div8_rec_reg<=div8_rec_reg+1;//���տ�ʼ����ʱ϶����8�������ʵ�ʱ���¼�1ѭ��
end

always@(posedge clkbaud8x or negedge rst)
begin
	if(!rst)
		div8_tras_reg<=0;
	else if(trasstart)
		div8_tras_reg<=div8_tras_reg+1;//���Ϳ�ʼ����ʱ϶����8�������ʵ�ʱ���¼�1ѭ��
end

always@(div8_rec_reg)
begin
	if(div8_rec_reg==7)
		clkbaud_rec=1;//�ڵ�7��ʱ϶������ʹ���ź���Ч�������ݴ���
	else
		clkbaud_rec=0;
end

always@(div8_tras_reg)
begin
	if(div8_tras_reg==7)
		clkbaud_tras=1;//�ڵ�7��ʱ϶������ʹ���ź���Ч�������ݷ���
	else
		clkbaud_tras=0;
end

always@(posedge clkbaud8x or negedge rst)
begin
	if(!rst) begin
		txd_reg<=1;
		trasstart<=0;
		txd_buf<=0;
		state_tras<=0;
		send_state<=0;
		key_entry2<=0;
	 end
	else begin
		if(!key_entry2) begin
			if(key_entry1) begin
				key_entry2<=1;
				txd_buf<=8'd50; //"2"
			 end
		 end
		else  begin
			case(state_tras)
				4'b0000: begin  //������ʼλ
					if(!trasstart&&send_state<7) 
						trasstart<=1;
					else if(send_state<7) begin
						if(clkbaud_tras) begin
							txd_reg<=0;
							state_tras<=state_tras+1;
						 end
					 end
					else begin
						key_entry2<=0;
						state_tras<=0;
					 end					
				end		
				4'b0001: begin //���͵�1λ
					if(clkbaud_tras) begin
						txd_reg<=txd_buf[0];
						txd_buf[6:0]<=txd_buf[7:1];
						state_tras<=state_tras+1;
					 end
				 end
				4'b0010: begin //���͵�2λ
					if(clkbaud_tras) begin
						txd_reg<=txd_buf[0];
						txd_buf[6:0]<=txd_buf[7:1];
						state_tras<=state_tras+1;
					 end
				 end
				 4'b0011: begin //���͵�3λ
				 	if(clkbaud_tras) begin
						txd_reg<=txd_buf[0];
						txd_buf[6:0]<=txd_buf[7:1];
						state_tras<=state_tras+1;
					 end
				 end
				4'b0100: begin //���͵�4λ
					if(clkbaud_tras) begin
						txd_reg<=txd_buf[0];
						txd_buf[6:0]<=txd_buf[7:1];
						state_tras<=state_tras+1;
					 end
				 end
				4'b0101: begin //���͵�5λ
					if(clkbaud_tras) begin
						txd_reg<=txd_buf[0];
						txd_buf[6:0]<=txd_buf[7:1];
						state_tras<=state_tras+1;
					 end
				 end
				4'b0110: begin //���͵�6λ
					if(clkbaud_tras) begin
						txd_reg<=txd_buf[0];
						txd_buf[6:0]<=txd_buf[7:1];
						state_tras<=state_tras+1;
					 end
				 end
				4'b0111: begin //���͵�7λ
					if(clkbaud_tras) begin
						txd_reg<=txd_buf[0];
						txd_buf[6:0]<=txd_buf[7:1];
						state_tras<=state_tras+1;
					 end
				 end
				4'b1000: begin //���͵�8λ
					if(clkbaud_tras) begin
						txd_reg<=txd_buf[0];
						txd_buf[6:0]<=txd_buf[7:1];
						state_tras<=state_tras+1;
					 end
				 end
				4'b1001: begin //����ֹͣλ
					if(clkbaud_tras) begin
						txd_reg<=1;
						txd_buf<=8'h55;
						state_tras<=state_tras+1;
					 end
				 end
				4'b1111:begin 
					if(clkbaud_tras) begin
						state_tras<=state_tras+1;
						send_state<=send_state+1;
						trasstart<=0;
						case(send_state)
							3'b000:
								txd_buf<=8'd49;//"1"
							3'b001:
								txd_buf<=8'd32;//" "
							3'b010:
								txd_buf<=8'd69;//"E"
							3'b011:
								txd_buf<=8'd68;//"D"
							3'b100:
								txd_buf<=8'd65;//"A"
							3'b101:
								txd_buf<=8'd10;//"e"
							default:
								txd_buf<=0;
						 endcase
					 end
				 end
				default: begin
					if(clkbaud_tras) begin
						state_tras<=state_tras+1;
						trasstart<=1;
					 end
				 end
			 endcase
		 end
	 end
end

always@(posedge clkbaud8x or negedge rst)//����PC��������
begin
	if(!rst) begin
		rxd_reg1<=0;
		rxd_reg2<=0;
		rxd_buf<=0;
		state_rec<=0;
		recstart<=0;
		recstart_tmp<=0;
	 end
	else  begin
		 rxd_reg1<=rxd;
		 rxd_reg2<=rxd_reg1;
		 if(state_rec==0) begin
			 if(recstart_tmp==1) begin
		 		recstart<=1;
		 		recstart_tmp<=0;
				state_rec<=state_rec+1;
		  	  end
		 	 else if(!rxd_reg1&&rxd_reg2) //���⵽��ʼλ���½��أ���������״̬
				recstart_tmp<=1;
		   end
		 else if(state_rec>=1&&state_rec<=8) begin
		 	 if(clkbaud_rec) begin
			 	rxd_buf[7]<=rxd_reg2;
				rxd_buf[6:0]<=rxd_buf[7:1];
				state_rec<=state_rec+1;
			  end
		  end
		 else if(state_rec==9) begin
		 	if(clkbaud_rec) begin
		 		state_rec<=0;
				recstart<=0;
			 end
		  end
	  end
end

always@(rxd_buf) //�����ܵ���������������ʾ���
begin
      case (rxd_buf)
		8'h30:
			seg_data=8'b11001110;
		8'h31:
			seg_data=8'b11111101;
		8'h32:
			seg_data=8'b10101100;
		8'h33:
			seg_data=8'b10111011;
		8'h34:
			seg_data=8'b10011010;
		8'h35:
			seg_data=8'b10011001;
		8'h36:
			seg_data=8'b10001000;
		8'h37:
			seg_data=8'b11110110;
		8'h38:
			seg_data=8'b10000101;
		8'h39:
			seg_data=8'b10010100;
		8'h41:
			seg_data=8'b10001000;
		8'h42:
			seg_data=8'b10000011;
		8'h43:
			seg_data=8'b11000110;
		8'h44:
			seg_data=8'b10100001;
		8'h45:
			seg_data=8'b10000110;
		8'h46:
			seg_data=8'b10001110;
		default:
			seg_data=8'b11111111;
	 endcase
end	

endmodule
	
