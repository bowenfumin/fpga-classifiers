/*



*/


module result_proc #(
                    parameter   LineNumber = 36
                    )
                 (
                  input              clk,
                  input              rst,     
                  input              valid,
                  input   [7:0]      clsf_result,
                  input              tx_axis_fifo_tready ,
                  
                  output  reg [7:0]      tx_axis_fifo_tdata  , 
                  output  reg           tx_axis_fifo_tvalid ,                    
                  output  reg           tx_axis_fifo_tlast                    
                  
                  );


localparam  IDLE = 0,
            DATA = 1;
localparam  PKT_LEN = 629;


reg         valid_dly;
reg  [7:0]  clsf_result_dly1;
reg         wr_en;
reg  [10:0] wr_addr, rd_addr;
reg  [7:0]  wr_data;
wire [7:0]  rd_data;

reg  [9:0]  cnt_wren, cnt_rden, cnt_rden_dly1, cnt_rden_dly2;
reg         wr_done;
reg         rd_done;
reg  [1:0]  ram_pkt_num;
wire        pkt_ready;
reg  [10:0] cnt_row;

reg         current_state, current_state_dly1, current_state_dly2, next_state;

ram_result u_ram_result(          //depth 2048, width 8bit
  .clka                   (clk ),             
  .wea                    (wr_en  ),
  .addra                  (wr_addr  ),
  .dina                   (wr_data  ),
  .clkb                   (clk ),
  .addrb                  (rd_addr  ),
  .doutb                  (rd_data  )
);

always @(posedge clk)
begin
  if(rst)
    wr_en <= 1'b0;
  else
    wr_en <= valid;
end

always @(posedge clk)
begin
  if(rst)
    wr_data <= 8'b0;
  else
    wr_data <= clsf_result;
end

always @(posedge clk)
begin
  if(rst)
    wr_addr <= 11'b0;
  else
    if(wr_en == 1'b1)
      wr_addr <= wr_addr + 1'b1;
    else;
end

always @(posedge clk)
begin
  if(rst)
    cnt_wren <= 10'b0;
  else
    if(wr_en == 1'b1)
      if(cnt_wren == PKT_LEN-1)
        cnt_wren <= 10'b0;
      else
        cnt_wren <= cnt_wren + 1'b1;
end



always @(posedge clk)
begin
  if(rst)
    wr_done <= 1'b0;
  else
    if(cnt_wren == PKT_LEN - 1)
      wr_done <= 1'b1;
    else
      wr_done <= 1'b0;
end


always @(posedge clk)
begin
  if(rst)
    current_state <= IDLE;
  else
    current_state <= next_state;
end

always @(posedge clk)
begin
  if(rst)
    begin
    	current_state_dly1 <= IDLE;
    	current_state_dly2 <= IDLE;
    end
  else
    begin
    	current_state_dly1 <= current_state;
    	current_state_dly2 <= current_state_dly1;
    end
end

always @*
begin
	case(current_state)
		IDLE:        if(pkt_ready == 1'b1)
		               next_state = DATA;
		             else
		               next_state = IDLE;
		
		DATA:        if(cnt_rden == PKT_LEN-1)
		               next_state = IDLE;
		             else
		               next_state = DATA;
		               
	  default:     next_state = IDLE;
	endcase
	  
end


always @(posedge clk)
begin
  if(rst)
    rd_addr <= 11'b0;
  else
    if(current_state == DATA && pkt_ready == 1'b1)
      rd_addr <= rd_addr + 1'b1;
    else;
end

always @(posedge clk)
begin
  if(rst)
    cnt_rden <= 10'b0;
  else
    if(current_state == DATA && pkt_ready == 1'b1)
      if(cnt_rden == PKT_LEN-1)
        cnt_rden <= 10'b0;
      else
        cnt_rden <= cnt_rden + 1'b1;
    else;
end

always @(posedge clk)
begin
  if(rst)
    begin
    	cnt_rden_dly1 <= 10'b0;
    	cnt_rden_dly2 <= 10'b0;
    end
  else
    begin
    	cnt_rden_dly1 <= cnt_rden;
    	cnt_rden_dly2 <= cnt_rden_dly1;
    end
end

always @(posedge clk)
begin
  if(rst)
    rd_done <= 1'b0;
  else
    if(cnt_rden == PKT_LEN - 3)
      rd_done <= 1'b1;
    else
      rd_done <= 1'b0;
end

always @(posedge clk)
begin
  if(rst)
    cnt_row <= 11'b0;
  else
    if(rd_done == 1'b1)
      cnt_row <= cnt_row + 1'b1;
    else;
end

always @(posedge clk)
begin
  if(rst)
    ram_pkt_num <= 2'b0;
  else
    case({wr_done, rd_done})
    	2'b10:      ram_pkt_num <= ram_pkt_num + 1'b1;
    	2'b01:      ram_pkt_num <= ram_pkt_num - 1'b1;
    	
    	default:    ram_pkt_num <= ram_pkt_num;
    endcase
end

assign pkt_ready = (ram_pkt_num > 0)? 1'b1: 1'b0;

always @(posedge clk)
begin
  if(rst)
    tx_axis_fifo_tvalid <= 1'b0;
  else
    if(current_state_dly2 == DATA)
      tx_axis_fifo_tvalid <= 1'b1;
    else
      tx_axis_fifo_tvalid <= 1'b0;
end

always @(posedge clk)
begin
  if(rst)
    tx_axis_fifo_tdata <= 1'b0;
  else
    if(current_state_dly2 == DATA)
      tx_axis_fifo_tdata <= rd_data;
    else
      tx_axis_fifo_tdata <= 1'b0;
end


always @(posedge clk)
begin
  if(rst)
    tx_axis_fifo_tlast <= 1'b0;
  else
    if(current_state_dly2 == DATA && cnt_rden_dly2 == PKT_LEN - 1)
      tx_axis_fifo_tlast <= 1'b1;
    else
      tx_axis_fifo_tlast <= 1'b0;
end
endmodule