/*






*/

module  rx_buf #(
                         parameter Packet_len            = 160
                        )
                  (
                  input                 clk,
                  input                 rst,
                  input    [10:0]        rd_addr,
                  input                 init_calib_complete,
                  input                 rd_row_done,
                  output                pkt_ready,
                  output   [7:0]        rd_data_out,
                  
                  input                      rx_fifo_clock     ,
                  input                      rx_fifo_resetn    ,                               
                  input    [7:0]             rx_axis_tdata  ,
                  input                      rx_axis_tvalid ,
                  input                      rx_axis_tlast  ,
                  output   reg               rx_axis_tready,
                  output   reg               rx_frame_pause_req,
                  output   reg      [15:0]   rx_frame_req_pausetime,
                  output   reg               error1
                   
                  );




parameter  WR_IDLE      = 3'd0;
parameter  PRE_WR       = 3'd1;
parameter  WR_DATA      = 3'd2;
parameter  WR_BYPASS    = 3'd3;
parameter  WR_EOF       = 3'd4;
parameter  WR_RAM_FULL  = 3'd5;

localparam FRAME_LEN = 15'd1440;

localparam FRAME_DA = 48'hDA0203040506;

//localparam PAUSE_FRAME_DA = 48'h0180c2000001;   
localparam PAUSE_FRAME_DA = 48'h010000c28001; 
localparam PAUSE_FRAME_TYPE = 16'h8808;
localparam PAUSE_FRAME_OPCODE = 16'h0001;

//parameter  IMAGE_H = 11'd192;
//parameter  ROW_LEN = IMAGE_H >> 3;
//parameter  IMAGE_V = 10'd36;


reg      [2:0]   wr_current_state;
reg      [2:0]   wr_next_state;
reg      [13:0]  cnt_pkt;
//reg      [13:0]  cnt_pkt_dly1;
(*S="TRUE"*)reg      [31:0]   cnt_rx_row;
(*S="TRUE"*)reg      [31:0]   cnt_rx_err_pkt;
reg      [2:0]   cnt_pkt4ddr;

reg              full_frame_ready;
reg              full_frame_ready_dly1;
reg              full_frame_ready_dly2;
reg      [7:0]   rx_axis_tdata_dly[0:2];
reg      [7:0]   rx_axis_tdata_dly4;
reg              rx_axis_tvalid_dly1;
reg              rx_axis_tvalid_dly2;
reg              rx_axis_tlast_dly1;
reg              rx_axis_tlast_dly2;       
reg              rx_axis_tuser_dly1; 
reg              rx_axis_tuser_dly2;
reg              rx_axis_tready_dly1;
reg              rx_axis_tready_dly2;

//common write and read signals
reg              wr_en;
reg      [10:0]  wr_addr;
reg      [7:0]   wr_data;
reg              wr_bypass; //filter non-image packet,like IP packet

reg              ram_empty;
reg              ram_full;
reg      [8:0]   wr_2line_cnt;
reg              wr_done;
reg              wr_done_dly1;
wire             wr_done2rd;
reg              wr_done2rd_dly1;
reg              wr_done2rd_dly2;
reg              wr_done2rd_dly3;
reg              wr_done2rd_detect;
reg      [3:0]   ram_pkt_num;
reg      [47:0]  rx_frame_da;
reg      [47:0]  rx_frame_sa;
reg      [15:0]  rx_frame_typelen;
reg      [15:0]  rx_frame_opcode;
reg              len_err;
reg              len_err_dly1;


ram_bf_ddr u_ram_bf_ddr(
  .clka                   (clk ),             
  .wea                    (wr_en ),
  .addra                  (wr_addr ),
  .dina                   (wr_data ),
  .clkb                   (clk ),
  .addrb                  (rd_addr ),
  .doutb                  (rd_data_out )
);

always @(posedge rx_fifo_clock)
begin
  if(!rx_fifo_resetn)
    rx_axis_tready <= 1'b0;
  else
   // if(rd_current_state != RD_IDLE)
      rx_axis_tready <= 1'b1;
   // else
   //   rx_axis_tready <= 1'b1;
end   

always @(posedge rx_fifo_clock)
begin
  if(!rx_fifo_resetn)
    begin
    	rx_axis_tdata_dly[0] <= 8'b0;
    	rx_axis_tdata_dly[1] <= 8'b0;
    	rx_axis_tdata_dly[2] <= 8'b0;
    	rx_axis_tdata_dly4   <= 8'b0;
    end   
  else
    begin
    	rx_axis_tdata_dly[0] <= rx_axis_tdata;
    	rx_axis_tdata_dly[1] <= rx_axis_tdata_dly[0];
      rx_axis_tdata_dly[2] <= rx_axis_tdata_dly[1];
      rx_axis_tdata_dly4   <= rx_axis_tdata_dly[2];
    end
end



always @(posedge rx_fifo_clock)
begin
  if(!rx_fifo_resetn)
    begin
    	rx_axis_tlast_dly1 <= 8'b0;
    	rx_axis_tlast_dly2 <= 8'b0;
    end   
  else
    begin
    	rx_axis_tlast_dly1 <= rx_axis_tlast;
      rx_axis_tlast_dly2 <= rx_axis_tlast_dly1;
    end
end

always @(posedge rx_fifo_clock)
begin
  if(!rx_fifo_resetn)
    begin
    	rx_axis_tvalid_dly1 <= 8'b0;
    	rx_axis_tvalid_dly2 <= 8'b0;
    end   
  else
    begin
    	rx_axis_tvalid_dly1 <= rx_axis_tvalid;
      rx_axis_tvalid_dly2 <= rx_axis_tvalid_dly1;
    end
end

always @(posedge rx_fifo_clock)
begin
  if(!rx_fifo_resetn)
    begin
    	rx_axis_tready_dly1 <= 8'b0;
    	rx_axis_tready_dly2 <= 8'b0;
    end   
  else
    begin
    	rx_axis_tready_dly1 <= rx_axis_tready;
      rx_axis_tready_dly2 <= rx_axis_tready_dly1;
    end
end

always @(posedge rx_fifo_clock)
begin
  if(!rx_fifo_resetn)
    wr_current_state <= WR_IDLE;
  else
    wr_current_state <= wr_next_state;
end



always @*
begin
	case(wr_current_state)
		WR_IDLE: if(rx_axis_tready_dly2 == 1'b1 &&  rx_axis_tvalid_dly2 == 1'b1)
		           wr_next_state = PRE_WR;
		         else
		           wr_next_state = WR_IDLE;
		           
		PRE_WR:  if(cnt_pkt == 14'd17)
		           if(wr_bypass == 1'b1)
		             wr_next_state = WR_BYPASS;
		           else
		             wr_next_state = WR_DATA;
		         else
		           wr_next_state = PRE_WR;
		           
		WR_DATA: if(rx_axis_tready_dly2 == 1'b0)
		           wr_next_state = WR_RAM_FULL;
		         else
		           if(rx_axis_tlast_dly2 == 1'b1)
		             wr_next_state = WR_EOF;
		           else
		             wr_next_state = WR_DATA;
		             
		WR_BYPASS:  if(rx_axis_tlast_dly2 == 1'b1)
		              wr_next_state = WR_IDLE;
		            else
		              wr_next_state = WR_BYPASS;
		
		WR_EOF:  if(rx_axis_tready_dly2 == 1'b1 &&  rx_axis_tvalid_dly2 == 1'b1)
		           wr_next_state = PRE_WR;
		         else
		           wr_next_state = WR_IDLE;
		WR_RAM_FULL: if(rx_axis_tready_dly2 == 1'b1)
		               wr_next_state = WR_DATA;
		             else
		               wr_next_state = WR_RAM_FULL;
		default:
		          wr_next_state = WR_IDLE; 
	endcase
end


always @(posedge rx_fifo_clock)
begin
  if(!rx_fifo_resetn)
    cnt_pkt <= 14'b0;
  else
    case(wr_current_state)
    	WR_IDLE:    cnt_pkt <= 14'b0;
    	PRE_WR:     cnt_pkt <= cnt_pkt + 1'b1;
    	WR_DATA:    cnt_pkt <= cnt_pkt + 1'b1;
    	WR_BYPASS:  cnt_pkt <= cnt_pkt + 1'b1;
    	WR_EOF:     if(rx_axis_tready_dly2 == 1'b1 &&  rx_axis_tvalid_dly2 == 1'b1)
    	              cnt_pkt <= 14'b0;
    	            else
    	              cnt_pkt <= cnt_pkt + 1'b1;
    	default:     cnt_pkt <= cnt_pkt;
    endcase    
end

//always @(posedge rx_fifo_clock)
//begin
//  if(!rx_fifo_resetn)
//    cnt_8to24 <= 2'b0;
//  else   	
//    if(wr_current_state == WR_DATA || wr_current_state == WR_EOF)
//      if(cnt_8to24 == 2'd2)
//        cnt_8to24 <= 2'b0;
//      else
//        cnt_8to24 <= cnt_8to24 + 1'b1;
//    else;
//end

//always @(posedge rx_fifo_clock)
//begin
//  if(!rx_fifo_resetn)
//    cnt_pkt_dly1 <= 14'b0;
//  else
//    cnt_pkt_dly1 <= cnt_pkt;
//end

always @(posedge rx_fifo_clock)
begin
  if(!rx_fifo_resetn)
    wr_bypass <= 1'b0;
  else
    if(wr_current_state == PRE_WR && ((cnt_pkt == 14'd6 && rx_frame_da != FRAME_DA) || (cnt_pkt == 14'd14 && rx_frame_typelen != 16'h0800)))
      wr_bypass <= 1'b1;
    else
      if(wr_current_state == WR_IDLE)
        wr_bypass <= 1'b0;
      else;
end

// check the ethernet frame lenght, if it's wrong, then reset the ram address
//always @(posedge rx_fifo_clock)
//begin
//  if(!rx_fifo_resetn)
//    len_err <= 1'b0;
//  else
//    if( rx_axis_tlast_dly2 == 1'b1 && cnt_pkt != 'd1456)
//      len_err <= 1'b1;
//    else
//      len_err <= 1'b0;   
//end

//always @(posedge rx_fifo_clock)
//begin
//  if(!rx_fifo_resetn)
//    len_err_dly1 <= 1'b0;
//  else
//    len_err_dly1 <= len_err;
//end


always @(posedge rx_fifo_clock)
begin
  if(!rx_fifo_resetn)
    wr_data <= 8'b0;
  else
    wr_data <= rx_axis_tdata_dly[2];
end


always @(posedge rx_fifo_clock)
begin
  if(!rx_fifo_resetn)
    wr_en <= 1'b0;
  else
    if(wr_current_state == WR_DATA || wr_current_state == WR_EOF)
      wr_en <= 1'b1;
    else
      wr_en <= 1'b0;
end

always @(posedge rx_fifo_clock)
begin
  if(!rx_fifo_resetn)
    wr_addr <= 15'b0;
  else
    if(wr_en == 1'b1)
      wr_addr <= wr_addr + 1'b1;
    else;
end

//count rows
always @(posedge rx_fifo_clock)
begin
  if(!rx_fifo_resetn)
    cnt_rx_row <= 32'b0;
  else
    if(wr_current_state == WR_EOF && cnt_pkt == 'd1457)
      cnt_rx_row <= cnt_rx_row + 1'b1;
    else;
end

always @(posedge rx_fifo_clock)
begin
  if(!rx_fifo_resetn)
    cnt_rx_err_pkt <= 32'b0;
  else
    if(wr_current_state == WR_EOF && cnt_pkt != 'd1457)
      cnt_rx_err_pkt <= cnt_rx_err_pkt + 1'b1;
    else;
end

/****************************************************
        Extract DA SA TYPE/LEN OPCODE PAUSETIME
*****************************************************/
always @(posedge rx_fifo_clock)
begin
  if(!rx_fifo_resetn)
    rx_frame_da <= 48'b0;
  else
    if(wr_current_state == PRE_WR && cnt_pkt < 'd6)
    begin
    	rx_frame_da[7:0] <= rx_axis_tdata_dly[2];
    	rx_frame_da[47:8] <= rx_frame_da[39:0];
    end
end

always @(posedge rx_fifo_clock)
begin
  if(!rx_fifo_resetn)
    rx_frame_sa <= 48'b0;
  else
    if(wr_current_state == PRE_WR && (cnt_pkt >= 'd6 && cnt_pkt < 'd12))
    begin
    	rx_frame_sa[7:0] <= rx_axis_tdata_dly[2];
    	rx_frame_sa[47:8] <= rx_frame_sa[39:0];
    end
end

always @(posedge rx_fifo_clock)
begin
  if(!rx_fifo_resetn)
    rx_frame_typelen <= 16'b0;
  else
    if(wr_current_state == PRE_WR && (cnt_pkt == 'd12 || cnt_pkt == 'd13))
    begin
    	rx_frame_typelen[7:0] <= rx_axis_tdata_dly[2];
    	rx_frame_typelen[15:8] <= rx_frame_typelen[7:0];
    end
end

always @(posedge rx_fifo_clock)
begin
  if(!rx_fifo_resetn)
    rx_frame_opcode <= 16'b0;
  else
    if(wr_current_state == PRE_WR && (cnt_pkt == 'd14 || cnt_pkt == 'd15))
    begin
    	rx_frame_opcode[7:0] <= rx_axis_tdata_dly[2];
    	rx_frame_opcode[15:8] <= rx_frame_opcode[7:0];
    end
end

always @(posedge rx_fifo_clock)
begin
  if(!rx_fifo_resetn)
    rx_frame_req_pausetime <= 16'b0;
  else
    if(wr_current_state == PRE_WR && (cnt_pkt == 'd16 || cnt_pkt == 'd17))
    begin
    	rx_frame_req_pausetime[7:0] <= rx_axis_tdata_dly[2];
    	rx_frame_req_pausetime[15:8] <= rx_frame_req_pausetime[7:0];
    end
end



always @(posedge rx_fifo_clock)
begin
  if(!rx_fifo_resetn)
    rx_frame_pause_req <= 1'b0;
  else
    if(wr_current_state == PRE_WR && cnt_pkt == 'd16 && rx_frame_da == PAUSE_FRAME_DA)// && rx_frame_typelen == PAUSE_FRAME_TYPE && rx_frame_opcode == PAUSE_FRAME_OPCODE)
      rx_frame_pause_req <= 1'b1;
    else
      rx_frame_pause_req <= 1'b0;
end
//***************************************
// generate pkt_ready signal by crossing clock region
//***************************************

always @(posedge rx_fifo_clock)
begin
  if(!rx_fifo_resetn)
    wr_2line_cnt <= 9'b0;
  else
    if(wr_en == 1'b1)
      if(wr_2line_cnt == 'd319)
        wr_2line_cnt <= 9'b0;
      else
        wr_2line_cnt <= wr_2line_cnt + 1'b1;       
    else;
end
// modified at 2014/11/18 15:15:28
always @(posedge rx_fifo_clock)
begin
  if(!rx_fifo_resetn)
    wr_done <= 1'b0;
  else
    if(wr_2line_cnt == 'd319)
      wr_done <= 1'b1;
    else
      wr_done <= 1'b0;
end
//always @(posedge rx_fifo_clock)
//begin
//  if(!rx_fifo_resetn)
//    wr_done <= 1'b0;
//  else
//    if(wr_current_state == WR_EOF)
//      wr_done <= 1'b1;
//    else
//      wr_done <= 1'b0;
//end

always @(posedge rx_fifo_clock)
begin
  if(!rx_fifo_resetn)
    wr_done_dly1 <= 1'b0;
  else
    wr_done_dly1 <= wr_done;
end

assign  wr_done2rd = (wr_done | wr_done_dly1);

// make wr_done2rd cross clock region
always @(posedge clk)
begin
  if(rst)
    wr_done2rd_dly1 <= 1'b0;
  else
    wr_done2rd_dly1 <= wr_done2rd;
end

always @(posedge clk)
begin
  if(rst)
    wr_done2rd_dly2 <= 1'b0;
  else
    wr_done2rd_dly2 <= wr_done2rd_dly1;
end

always @(posedge clk)
begin
  if(rst)
    wr_done2rd_dly3 <= 1'b0;
  else
    wr_done2rd_dly3 <= wr_done2rd_dly2;
end

always @(posedge clk)
begin
  if(rst)
    wr_done2rd_detect <= 1'b0;
  else
    if(wr_done2rd_dly3 == 1'b0 && wr_done2rd_dly2 == 1'b1)
      wr_done2rd_detect <= 1'b1;
    else
      wr_done2rd_detect <= 1'b0;
end

always @(posedge clk)
begin
  if(rst)
    ram_pkt_num <= 4'b0;
  else
    case({wr_done2rd_detect, rd_row_done})
    	2'b01:    ram_pkt_num <= ram_pkt_num - 1'b1;
    	2'b10:    ram_pkt_num <= ram_pkt_num + 1'b1;
    	default:  ram_pkt_num <= ram_pkt_num;
    endcase
end

assign pkt_ready = (ram_pkt_num > 4'd0)? 1'b1: 1'b0;


//debug

reg    sig_dly1,sig_dly2;
reg    pos_detect, neg_detect;


always @(posedge rx_fifo_clock)
begin
  if(!rx_fifo_resetn)
  begin
    sig_dly1 <= 1'b0;
    sig_dly2 <= 1'b0;
  end
  else
    begin
    	sig_dly1 <= cnt_rx_row[0];
    	sig_dly2 <= sig_dly1;
    end
end

always @(posedge rx_fifo_clock)
begin
  if(!rx_fifo_resetn)
    pos_detect <= 1'b0;
  else
    if(sig_dly1 == 1'b1 && sig_dly2 == 1'b0)
      pos_detect <= 1'b1;
    else
      pos_detect <= 1'b0;
end

always @(posedge rx_fifo_clock)
begin
  if(!rx_fifo_resetn)
    neg_detect <= 1'b0;
  else
    if(sig_dly1 == 1'b0 && sig_dly2 == 1'b1)
      neg_detect <= 1'b1;
    else
      neg_detect <= 1'b0;
end

always @(posedge rx_fifo_clock)
begin
  if(!rx_fifo_resetn)
    error1 <= 1'b0;
  else
    if((pos_detect == 1'b1 && wr_2line_cnt != 'd160) ||(neg_detect == 1'b1 && wr_2line_cnt != 'd0))
      error1 <= 1'b1;
    else;
end

endmodule