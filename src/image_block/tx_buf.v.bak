/*






*/

`timescale 1ps/1ps

module  tx_buf (
                  input                 clk,
                  input                 rst,
                  input                 image_clk,
                  input                 image_rst,
                  input                 rx_frame_pause_req,   
                  input     [15:0]      rx_frame_req_pausetime,

                  output   reg [7:0]       tx_axis_tdata  ,
                  output   reg             tx_axis_tvalid ,
                  output   reg             tx_axis_tlast  ,
                  input                 tx_axis_tready ,    
                  output                rd_row_data_done, 
                  output                rd_en,
                  output reg   [12:0]   rd_addr, 
                  input        [7:0]    rd_data,    
                  input                 pkt_ready
                  );

localparam   IDLE = 0,
             ADD_HEADER = 1,
             RD_DATA = 2,
             PAUSE = 3;

//localparam   TWO_ROW_CNT = 4;  // read two lines of image from DDR3 need 5 times of read operation   modified at 2014/11/18 15:59:21
localparam   PKT_CNT = 1256;
localparam   HEADER_CNT = 18;
localparam   DLY = 1000;


reg     [1:0] current_state, next_state;
reg     [8:0] cnt512toN;
reg     [10:0] rd_ram_cnt;

reg           rd_image_done;
reg    [7:0]  data4lb_temp;

wire   [21:0] set_pause_time;
reg    [21:0] pause_cnt;
reg    [10:0] tx_bytes_cnt;
reg           pause_req_detect;
(*S="TRUE"*)reg      [31:0]   cnt_tx_row;
reg    [15:0] cnt_image_rows;

assign set_pause_time = (pause_req_detect == 1'b1)? {rx_frame_req_pausetime, 6'b0} : 'd3000;



// pause frame reception
always @(posedge image_clk)
begin
  if(image_rst)
    pause_req_detect <= #DLY  1'b0;
  else
    if(rx_frame_pause_req == 1'b1)
      pause_req_detect <= #DLY  1'b1;
    else
      if(pause_cnt == set_pause_time)
        pause_req_detect <= #DLY  1'b0;
      else;
end


always @(posedge image_clk)
begin
  if(image_rst)
    current_state <= #DLY  IDLE;
  else
    current_state <= #DLY  next_state;
end

always @ *
begin
	case(current_state)
		IDLE:         if(pkt_ready == 1'b1)
		                next_state = ADD_HEADER;
		              else
		                next_state = IDLE;
		                
		ADD_HEADER:   if(tx_bytes_cnt == 5'd16)
		                next_state = RD_DATA;
		              else
		                next_state = ADD_HEADER;
		
		RD_DATA:      //if(pkt_ready == 1'b0)
		              //  next_state = IDLE;
		              //else

		                if(tx_bytes_cnt == PKT_CNT + HEADER_CNT)
		                  next_state = PAUSE;
		                else
		                  next_state = RD_DATA;
		                
		PAUSE:        if(pause_cnt == set_pause_time)
		                if(pkt_ready == 1'b1)		                  
		                  next_state = ADD_HEADER;
		                else
		                  next_state = IDLE;
		              else
		                next_state = PAUSE;
		                
		default:        next_state = IDLE;
	endcase
end


always @(posedge image_clk)
begin
  if(image_rst)
    pause_cnt <= 'b0;
  else
    if(current_state == PAUSE)
      pause_cnt <= pause_cnt + 1'b1;
    else
      pause_cnt <= 'b0;
end

always @(posedge image_clk)
begin
  if(image_rst)
    cnt512toN <= #DLY  9'b0;
  else
    if(current_state == RD_DATA && tx_axis_tready == 1'b1)
      if(cnt512toN == 9'd63)
        cnt512toN <= #DLY  9'b0;
      else
        cnt512toN <= #DLY  cnt512toN + 1'b1;
    else;
//      cnt512toN <= #DLY  9'b0;
end


assign rd_row_data_done = (current_state == RD_DATA && tx_axis_tready == 1'b1 && rd_ram_cnt == PKT_CNT)? 1'b1:1'b0;



always @(posedge image_clk)
begin
  if(image_rst)
    rd_ram_cnt <= #DLY  11'b0;
  else
    if(current_state == RD_DATA)
      rd_ram_cnt <= #DLY  rd_ram_cnt + 1'b1;
    else
      rd_ram_cnt <= #DLY  11'b0;
end


always @(posedge image_clk)
begin
  if(image_rst)
    rd_addr <= #DLY  13'b0;
  else
    if(current_state == RD_DATA && tx_axis_tready == 1'b1 && tx_bytes_cnt < PKT_CNT + HEADER_CNT)
      rd_addr <= #DLY  rd_addr + 1'b1;
    else;
end

assign rd_en = (current_state == RD_DATA && tx_axis_tready == 1'b1 && tx_bytes_cnt < PKT_CNT + HEADER_CNT)? 1'b1: 1'b0;

// 2014-12-21, 16:1:36
/*
always @*
begin
      if(current_state == RD_DATA && tx_axis_tready == 1'b1)
        case(cnt512toN)
        9'd0:   data4lb_temp <= rd_data[511:504];
        9'd1:   data4lb_temp <= rd_data[503:496];
        9'd2:   data4lb_temp <= rd_data[495:488];
        9'd3:   data4lb_temp <= rd_data[487:480];
        9'd4:   data4lb_temp <= rd_data[479:472];
        9'd5:   data4lb_temp <= rd_data[471:464];
        9'd6:   data4lb_temp <= rd_data[463:456];
        9'd7:   data4lb_temp <= rd_data[455:448];
        9'd8:   data4lb_temp <= rd_data[447:440];
        9'd9:   data4lb_temp <= rd_data[439:432];
        9'd10:   data4lb_temp <= rd_data[431:424];
        9'd11:   data4lb_temp <= rd_data[423:416];
        9'd12:   data4lb_temp <= rd_data[415:408];
        9'd13:   data4lb_temp <= rd_data[407:400];
        9'd14:   data4lb_temp <= rd_data[399:392];
        9'd15:   data4lb_temp <= rd_data[391:384];
        9'd16:   data4lb_temp <= rd_data[383:376];
        9'd17:   data4lb_temp <= rd_data[375:368];
        9'd18:   data4lb_temp <= rd_data[367:360];
        9'd19:   data4lb_temp <= rd_data[359:352];
        9'd20:   data4lb_temp <= rd_data[351:344];
        9'd21:   data4lb_temp <= rd_data[343:336];
        9'd22:   data4lb_temp <= rd_data[335:328];
        9'd23:   data4lb_temp <= rd_data[327:320];
        9'd24:   data4lb_temp <= rd_data[319:312];
        9'd25:   data4lb_temp <= rd_data[311:304];
        9'd26:   data4lb_temp <= rd_data[303:296];
        9'd27:   data4lb_temp <= rd_data[295:288];
        9'd28:   data4lb_temp <= rd_data[287:280];
        9'd29:   data4lb_temp <= rd_data[279:272];
        9'd30:   data4lb_temp <= rd_data[271:264];
        9'd31:   data4lb_temp <= rd_data[263:256];
        9'd32:   data4lb_temp <= rd_data[255:248];
        9'd33:   data4lb_temp <= rd_data[247:240];
        9'd34:   data4lb_temp <= rd_data[239:232];
        9'd35:   data4lb_temp <= rd_data[231:224];
        9'd36:   data4lb_temp <= rd_data[223:216];
        9'd37:   data4lb_temp <= rd_data[215:208];
        9'd38:   data4lb_temp <= rd_data[207:200];
        9'd39:   data4lb_temp <= rd_data[199:192];
        9'd40:   data4lb_temp <= rd_data[191:184];
        9'd41:   data4lb_temp <= rd_data[183:176];
        9'd42:   data4lb_temp <= rd_data[175:168];
        9'd43:   data4lb_temp <= rd_data[167:160];
        9'd44:   data4lb_temp <= rd_data[159:152];
        9'd45:   data4lb_temp <= rd_data[151:144];
        9'd46:   data4lb_temp <= rd_data[143:136];
        9'd47:   data4lb_temp <= rd_data[135:128];
        9'd48:   data4lb_temp <= rd_data[127:120];
        9'd49:   data4lb_temp <= rd_data[119:112];
        9'd50:   data4lb_temp <= rd_data[111:104];
        9'd51:   data4lb_temp <= rd_data[103:96];
        9'd52:   data4lb_temp <= rd_data[95:88];
        9'd53:   data4lb_temp <= rd_data[87:80];
        9'd54:   data4lb_temp <= rd_data[79:72];
        9'd55:   data4lb_temp <= rd_data[71:64];
        9'd56:   data4lb_temp <= rd_data[63:56];
        9'd57:   data4lb_temp <= rd_data[55:48];
        9'd58:   data4lb_temp <= rd_data[47:40];
        9'd59:   data4lb_temp <= rd_data[39:32];
        9'd60:   data4lb_temp <= rd_data[31:24];
        9'd61:   data4lb_temp <= rd_data[23:16];
        9'd62:   data4lb_temp <= rd_data[15:8];
        9'd63:   data4lb_temp <= rd_data[7:0];
        default:   data4lb_temp <= 8'b0;
      endcase
      else;
end
*/
always @(posedge image_clk)
begin
  if(image_rst)
    tx_bytes_cnt <= #DLY  11'b0;
  else
    if(current_state == ADD_HEADER)
      tx_bytes_cnt <= #DLY  tx_bytes_cnt + 1'b1;
    else
      if(current_state == RD_DATA)      
        if(tx_axis_tvalid == 1'b1)
          tx_bytes_cnt <= #DLY  tx_bytes_cnt + 1'b1;
        else;
      else
        tx_bytes_cnt <= #DLY  11'b0;
end


//assign tx_axis_tdata = rd_data;


//assign tx_axis_tvalid = (current_state == RD_DATA && tx_axis_tready == 1'b1)? 1'b1: 1'b0;

//assign tx_axis_tlast = (current_state == RD_DATA && tx_axis_tready == 1'b1 && cnt512toN == 9'd63)? 1'b1: 1'b0;
//assign tx_axis_tlast = (current_state == RD_DATA && tx_axis_tready == 1'b1 && tx_bytes_cnt == PKT_CNT)? 1'b1: 1'b0;


always @(posedge image_clk)
begin
  if(image_rst)
    tx_axis_tdata <= #DLY  8'b0;
  else
    case(tx_bytes_cnt)
    	11'd0:    tx_axis_tdata <= #DLY  8'h5a;
    	11'd1:    tx_axis_tdata <= #DLY  8'h02;
    	11'd2:    tx_axis_tdata <= #DLY  8'h03;
    	11'd3:    tx_axis_tdata <= #DLY  8'h04;
    	11'd4:    tx_axis_tdata <= #DLY  8'h05;
    	11'd5:    tx_axis_tdata <= #DLY  8'h06;
    	11'd6:    tx_axis_tdata <= #DLY  8'hda;
    	11'd7:    tx_axis_tdata <= #DLY  8'h02;
    	11'd8:    tx_axis_tdata <= #DLY  8'h03;
    	11'd9:    tx_axis_tdata <= #DLY  8'h04;
    	11'd10:    tx_axis_tdata <= #DLY  8'h05;
    	11'd11:    tx_axis_tdata <= #DLY  8'h06;
    	11'd12:    tx_axis_tdata <= #DLY  8'h08;
    	11'd13:    tx_axis_tdata <= #DLY  8'h00;
    	11'd14:    tx_axis_tdata <= #DLY  cnt_tx_row[7:0];
    	11'd15:    tx_axis_tdata <= #DLY  cnt_tx_row[15:8];
    	11'd16:    tx_axis_tdata <= #DLY  cnt_image_rows[7:0];
    	11'd17:    tx_axis_tdata <= #DLY  cnt_image_rows[15:8];
    	default: 	 tx_axis_tdata <= #DLY  rd_data;
    endcase
end
always @(posedge image_clk)
begin
  if(image_rst)
    tx_axis_tvalid <= #DLY  1'b0;
  else
    if(current_state == RD_DATA && tx_axis_tready == 1'b1 || current_state == ADD_HEADER)
      tx_axis_tvalid <= #DLY   1'b1;
    else
      tx_axis_tvalid <= #DLY  1'b0;
end

always @(posedge image_clk)
begin
  if(image_rst)
    tx_axis_tlast <= #DLY  1'b0;
  else
    if(current_state == RD_DATA && tx_axis_tready == 1'b1 && tx_bytes_cnt == PKT_CNT + HEADER_CNT)
      tx_axis_tlast <= 1'b1;
    else
      tx_axis_tlast <= #DLY  1'b0;
end

//***********************************************************

always @(posedge image_clk)
begin
  if(image_rst)
    cnt_tx_row <= #DLY  32'b0;
  else
    if(tx_axis_tlast == 1'b1)
      cnt_tx_row <= #DLY  cnt_tx_row + 1'b1;
    else;
end

always @(posedge image_clk)
begin
  if(image_rst)
    cnt_image_rows <= #DLY  16'b0;
  else
    if(tx_axis_tlast == 1'b1)
      if(cnt_image_rows == 16'd696)
        cnt_image_rows <= #DLY  16'b0;
      else
        cnt_image_rows <= #DLY  cnt_image_rows + 1'b1;
    else;
end


endmodule