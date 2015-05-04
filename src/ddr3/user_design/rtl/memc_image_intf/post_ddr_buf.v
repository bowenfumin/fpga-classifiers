/*






*/

`timescale 1ps/1ps

`include "E:/study_in_UdeM/project/sim_for_video_evaluation/sim_v16_macddr/src/include/defines.v"


module  post_ddr_buf #(
                    parameter   LineNumber = 36
                    )
                    (
                  input                 clk,
                  input                 rst,
                  input                 image_clk,
                  input                 image_rst,
                  input   [511:0]       app_rd_data,
                  input                 app_rd_data_valid ,
                  input                 app_rdy ,                        
                  input       [2:0]     app_cmd ,
                  input                 app_en  ,   
                  input                 result_buf_full,
                  
                  `ifdef MoveBy1Pixel
                    output              data4sr,
                  `else
                    output  [1:0]       data4sr,     
                  `endif
                  output  reg           data4sr_valid,      
                  input                 one_frame_done,
                  output                to_full,               
                  output                post_ddr_ram_full
                  );

`ifdef MoveBy1Pixel
  localparam MAXCNT4SR = 512;
`else
  localparam MAXCNT4SR = 255;
`endif

localparam   IDLE = 0,
             RD_DATA = 1,
             PRE_RESULT_FULL = 2,
             RESULT_FULL = 3,
             WAIT        =4;

//localparam   TWO_ROW_CNT = 7; // 1280x3/512 = 7.5
localparam   TWO_ROW_CNT = 5;  // read two lines of image from DDR3 need 5 times of read operation   modified at 2014/11/18 15:59:21
//localparam   read_one_frame = LineNumber/2 - 1;
localparam   DLY = 1000;

wire  [8:0] read_one_frame;

reg           wr_en;
reg   [511:0] wr_data;
reg   [4:0]   wr_addr;
reg   [3:0]   wr_en_cnt;
reg           wr_en_done;
reg           wr_en_done_dly1;
wire          wr_en_done2ram;
reg           wr_en_done2ram_dly1;
reg           wr_en_done2ram_dly2;
reg           wr_en_done2ram_dly3;
wire          wr_en_done_detect;
reg     [1:0] ram_pkt_num_data;


reg     [3:0] rd_ddr_cnt;
reg           req_row_data_done;
reg           req_row_data_done_dly1;
wire          req_row_data_done2ram;
reg           req_row_data_done2ram_dly1;
reg           req_row_data_done2ram_dly2;
reg           req_row_data_done2ram_dly3;
reg           req_row_data_done_detect;


reg   [4:0]   rd_addr;
wire  [511:0] rd_data;
reg           rd_row_data_done;
reg     [1:0] ram_pkt_num_cmd;

reg     [2:0] current_state, next_state;
wire          pkt_ready;
reg     [8:0] cnt512toN;
reg     [2:0] rd_ram_cnt;
reg     [8:0] rd_cnt;
reg     [4:0] pre_result_full_cnt;
(*keep = "true"*) reg     [8:0] cnt512toN_copy1;
(*keep = "true"*) reg     [8:0] cnt512toN_copy2;
(*keep = "true"*) reg     [8:0] cnt512toN_copy3;
(*keep = "true"*) reg     [8:0] cnt512toN_copy4;

assign read_one_frame = (LineNumber>>1)-1'b1;

`ifdef MoveBy1Pixel
  reg            data4sr_temp;
`else
  reg   [1:0]    data4sr_temp;
`endif
always @(posedge clk)
begin
  if(image_rst)
    wr_en <= #DLY  1'b0;
  else
    wr_en <= #DLY  app_rd_data_valid;
end

always @(posedge clk)
begin
  if(rst)
    wr_addr <= #DLY  5'b0;
  else
    if(wr_en == 1'b1)
      wr_addr <= #DLY  wr_addr + 1'b1;
    else;
end

always @(posedge clk)
begin
  if(rst)
    wr_data <= #DLY  512'b0;
  else
    wr_data <= #DLY  app_rd_data;
end

always @(posedge clk)
begin
  if(rst)
    wr_en_cnt <= #DLY  4'b0;
  else
    if(wr_en == 1'b1)
      if(wr_en_cnt == (TWO_ROW_CNT-1))
        wr_en_cnt <= #DLY  4'b0;
      else
        wr_en_cnt <= #DLY  wr_en_cnt + 1'b1;
    else; 
end

always @(posedge clk)
begin
  if(rst)
    wr_en_done <= #DLY  1'b0;
  else
    if(wr_en == 1'b1 && wr_en_cnt == (TWO_ROW_CNT-1))
      wr_en_done <= #DLY  1'b1;
    else
      wr_en_done <= #DLY  1'b0;
end

always @(posedge clk)
begin
  if(rst)
    wr_en_done_dly1 <= #DLY  1'b0;
  else
    wr_en_done_dly1 <= #DLY  wr_en_done;
end

assign wr_en_done2ram = (wr_en_done | wr_en_done_dly1);

//*************************
// control ram_full signal
//*************************
always @(posedge clk)
begin
  if(rst)
    rd_ddr_cnt <= #DLY  4'b0;
  else
    if(app_cmd == 3'd1 && app_en == 1'b1 && app_rdy == 1'b1)
      if(rd_ddr_cnt == (TWO_ROW_CNT-1))
        rd_ddr_cnt <= #DLY  4'b0;
      else
        rd_ddr_cnt <= #DLY  rd_ddr_cnt + 1'b1;
    else; 
end

always @(posedge clk)
begin
  if(rst)
    req_row_data_done <= #DLY  1'b0;
  else
    if(app_cmd == 3'd1 && app_en == 1'b1 && app_rdy == 1'b1 && rd_ddr_cnt == (TWO_ROW_CNT-1))
      req_row_data_done <= #DLY  1'b1;
    else
      req_row_data_done <= #DLY  1'b0;
end

always @(posedge clk)
begin
  if(rst)
    req_row_data_done_dly1 <= #DLY  1'b0;
  else
    req_row_data_done_dly1 <= #DLY  req_row_data_done;
end

assign req_row_data_done2ram = (req_row_data_done | req_row_data_done_dly1);

post_ddr_ram u_post_ddr_ram(          //depth 32, width 512bit
  .clka                   (clk ),             
  .wea                    (wr_en  ),
  .addra                  (wr_addr  ),
  .dina                   (wr_data  ),
  .clkb                   (image_clk ),
  .addrb                  (rd_addr  ),
  .doutb                  (rd_data  )
);

//***************************
// read side
//***************************


// for wr_en_done_detect

always @(posedge image_clk)
begin
  if(image_rst)
    wr_en_done2ram_dly1 <= #DLY  1'b0;
  else
    wr_en_done2ram_dly1 <= #DLY  wr_en_done2ram;
end

always @(posedge image_clk)
begin
  if(image_rst)
    wr_en_done2ram_dly2 <= #DLY  1'b0;
  else
    wr_en_done2ram_dly2 <= #DLY  wr_en_done2ram_dly1;
end


always @(posedge image_clk)
begin
  if(image_rst)
    wr_en_done2ram_dly3 <= #DLY  1'b0;
  else
    wr_en_done2ram_dly3 <= #DLY  wr_en_done2ram_dly2;
end


assign wr_en_done_detect = (wr_en_done2ram_dly2 == 1'b1 && wr_en_done2ram_dly3 == 1'b0)? 1'b1:1'b0;

always @(posedge image_clk)
begin
  if(image_rst)
    ram_pkt_num_data <= #DLY  2'b0;
  else
    case({wr_en_done_detect,rd_row_data_done})
    	2'b10:    ram_pkt_num_data <= #DLY  ram_pkt_num_data + 1'b1;
    	2'b01:    ram_pkt_num_data <= #DLY  ram_pkt_num_data - 1'b1;
    	default:  ram_pkt_num_data <= #DLY  ram_pkt_num_data;
    endcase
end
//for req_row_data_detect

always @(posedge image_clk)
begin
  if(image_rst)
    req_row_data_done2ram_dly1 <= #DLY  1'b0;
  else
    req_row_data_done2ram_dly1 <= #DLY  req_row_data_done2ram;
end

always @(posedge image_clk)
begin
  if(image_rst)
    req_row_data_done2ram_dly2 <= #DLY  1'b0;
  else
    req_row_data_done2ram_dly2 <= #DLY  req_row_data_done2ram_dly1;
end


always @(posedge image_clk)
begin
  if(image_rst)
    req_row_data_done2ram_dly3 <= #DLY  1'b0;
  else
    req_row_data_done2ram_dly3 <= #DLY  req_row_data_done2ram_dly2;
end

always @(posedge image_clk)
begin
  if(image_rst)
    req_row_data_done_detect <= #DLY  1'b0;
  else
    if(req_row_data_done2ram_dly2 == 1'b1 && req_row_data_done2ram_dly3 == 1'b0)
      req_row_data_done_detect <= #DLY  1'b1;
    else
      req_row_data_done_detect <= #DLY  1'b0;
end


always @(posedge image_clk)
begin
  if(image_rst)
    ram_pkt_num_cmd <= #DLY  2'b0;
  else
    case({req_row_data_done_detect,rd_row_data_done})
    	2'b10:    ram_pkt_num_cmd <= #DLY  ram_pkt_num_cmd + 1'b1;
    	2'b01:    ram_pkt_num_cmd <= #DLY  ram_pkt_num_cmd - 1'b1;
    	default:  ram_pkt_num_cmd <= #DLY  ram_pkt_num_cmd;
    endcase
end

assign post_ddr_ram_full = (ram_pkt_num_cmd > 2'd1)? 1'b1:1'b0;
assign pkt_ready = (ram_pkt_num_data > 2'd0)? 1'b1:1'b0;



always @(posedge image_clk)
begin
  if(image_rst)
    current_state <= #DLY  IDLE;
  else
    current_state <= #DLY  next_state;
end

//always @ *
//begin
//	case(current_state)
//		IDLE:         if(pkt_ready == 1'b1)
//		                next_state = RD_DATA;
//		              else
//		                next_state = IDLE;
//		
//		RD_DATA:      if(pkt_ready == 1'b0)
//		                next_state = IDLE;
//		              else
//		                next_state = RD_DATA;
//		                
//		default:        next_state = IDLE;
//	endcase
//end


always @ *
begin
	case(current_state)
		IDLE:         if(result_buf_full == 1'b1)
		                next_state = IDLE;
		              else
		                if(pkt_ready == 1'b1)
		                  next_state = RD_DATA;
		                else
		                  next_state = IDLE;
		
		RD_DATA:      //if(cnt512toN == (MAXCNT4SR-1) && rd_ram_cnt == (TWO_ROW_CNT-1))
		              if( (&cnt512toN) && rd_ram_cnt == (TWO_ROW_CNT-1))
		                if(rd_cnt == read_one_frame)
		                  next_state = WAIT;
		                else
		                  if(result_buf_full == 1'b1)
		                    next_state = PRE_RESULT_FULL;
		                  else
		                    if(pkt_ready == 1'b0)
		                      next_state = IDLE;
		                    else
		                      next_state = RD_DATA;
		              else
		                next_state = RD_DATA;
		PRE_RESULT_FULL: if(pre_result_full_cnt == 'd23)
		                   next_state = RESULT_FULL;
		                 else
		                   next_state = PRE_RESULT_FULL;
		                  
		RESULT_FULL:    if(result_buf_full == 1'b0)
		                  next_state = RD_DATA;
		                else
		                  next_state = RESULT_FULL;
		
		// to wait for transferring the whole image
		WAIT:           if(one_frame_done == 1'b1)
		                  next_state = IDLE;
		                else
		                  next_state = WAIT;             
		default:        next_state = IDLE;
	endcase
end

assign to_full = (current_state == RESULT_FULL)? 1'b1: 1'b0;

always @(posedge image_clk)
begin
  if(image_rst)
    pre_result_full_cnt <=  #DLY 5'b0;
  else
    if(current_state == PRE_RESULT_FULL)
      if(pre_result_full_cnt == 'd23)
        pre_result_full_cnt <=  #DLY 5'b0;
      else
        pre_result_full_cnt <=  #DLY pre_result_full_cnt + 1'b1;
    else;
end

always @(posedge image_clk)
begin
  if(image_rst)
    cnt512toN <= #DLY  9'b0;
  else
    if(current_state == RD_DATA || current_state == PRE_RESULT_FULL )
     // if(cnt512toN == (MAXCNT4SR-1))
      if(&cnt512toN)
        cnt512toN <= #DLY  9'b0;
      else
        cnt512toN <= #DLY  cnt512toN + 1'b1;
    else;
end

/******************************************************
 duplicate the registers to fix timing issue
 
 always @(posedge image_clk)
begin
  if(image_rst)
    cnt512toN_copy1 <= #DLY  9'b0;
  else
    if(current_state == RD_DATA || current_state == PRE_RESULT_FULL )
      if(&cnt512toN_copy1)
        cnt512toN_copy1 <= #DLY  9'b0;
      else
        cnt512toN_copy1 <= #DLY  cnt512toN_copy1 + 1'b1;
    else;
end


always @(posedge image_clk)
begin
  if(image_rst)
    cnt512toN_copy2 <= #DLY  9'b0;
  else
    if(current_state == RD_DATA || current_state == PRE_RESULT_FULL )
      if(&cnt512toN_copy2)
        cnt512toN_copy2 <= #DLY  9'b0;
      else
        cnt512toN_copy2 <= #DLY  cnt512toN_copy2 + 1'b1;
    else;
end



always @(posedge image_clk)
begin
  if(image_rst)
    cnt512toN_copy3 <= #DLY  9'b0;
  else
    if(current_state == RD_DATA || current_state == PRE_RESULT_FULL )
      if(&cnt512toN_copy3)
        cnt512toN_copy3 <= #DLY  9'b0;
      else
        cnt512toN_copy3 <= #DLY  cnt512toN_copy3 + 1'b1;
    else;
end


always @(posedge image_clk)
begin
  if(image_rst)
    cnt512toN_copy4 <= #DLY  9'b0;
  else
    if(current_state == RD_DATA || current_state == PRE_RESULT_FULL )
      if(&cnt512toN_copy4)
        cnt512toN_copy4 <= #DLY  9'b0;
      else
        cnt512toN_copy4 <= #DLY  cnt512toN_copy4 + 1'b1;
    else;
end

********************************************************/


always @(posedge image_clk)
begin
  if(image_rst)
    rd_row_data_done <= #DLY  1'b0;
  else
    if((&cnt512toN) && rd_ram_cnt == (TWO_ROW_CNT-1))
      rd_row_data_done <= #DLY  1'b1;
    else
      rd_row_data_done <= #DLY  1'b0;
end

always @(posedge image_clk)
begin
  if(image_rst)
    rd_ram_cnt <= #DLY  3'b0;
  else
    //if(current_state == RD_DATA && cnt512toN == (MAXCNT4SR-1))
    if(&cnt512toN)
      if(rd_ram_cnt == (TWO_ROW_CNT-1))
        rd_ram_cnt <= #DLY  3'b0;
      else
        rd_ram_cnt <= #DLY  rd_ram_cnt + 1'b1;
    else;
end



always @(posedge image_clk)
begin
  if(image_rst)
    rd_cnt <= #DLY 9'b0;
  else
    if((&cnt512toN) && rd_ram_cnt == (TWO_ROW_CNT-1))
      if(rd_cnt == read_one_frame)
        rd_cnt <= #DLY 9'b0;
      else
        rd_cnt <= #DLY rd_cnt + 1'b1;
    else;
end



always @(posedge image_clk)
begin
  if(image_rst)
    rd_addr <= #DLY  5'b0;
  else
    if(cnt512toN == (MAXCNT4SR-2))
      rd_addr <= #DLY  rd_addr + 1'b1;
    else;
end



`ifdef MoveBy1Pixel
// 2014-12-28, 10:33:40

always @(posedge image_clk)
begin
    if(image_rst)
      data4sr_temp <= 1'b0;
    else
    //  if(current_state == RD_DATA || current_state == PRE_RESULT_FULL )
        case(cnt512toN)
        9'd0:   data4sr_temp <= #DLY  rd_data[511];
        9'd1:   data4sr_temp <= #DLY  rd_data[510];
        9'd2:   data4sr_temp <= #DLY  rd_data[509];
        9'd3:   data4sr_temp <= #DLY  rd_data[508];
        9'd4:   data4sr_temp <= #DLY  rd_data[507];
        9'd5:   data4sr_temp <= #DLY  rd_data[506];
        9'd6:   data4sr_temp <= #DLY  rd_data[505];
        9'd7:   data4sr_temp <= #DLY  rd_data[504];
        9'd8:   data4sr_temp <= #DLY  rd_data[503];
        9'd9:   data4sr_temp <= #DLY  rd_data[502];
        9'd10:   data4sr_temp <= #DLY  rd_data[501];
        9'd11:   data4sr_temp <= #DLY  rd_data[500];
        9'd12:   data4sr_temp <= #DLY  rd_data[499];
        9'd13:   data4sr_temp <= #DLY  rd_data[498];
        9'd14:   data4sr_temp <= #DLY  rd_data[497];
        9'd15:   data4sr_temp <= #DLY  rd_data[496];
        9'd16:   data4sr_temp <= #DLY  rd_data[495];
        9'd17:   data4sr_temp <= #DLY  rd_data[494];
        9'd18:   data4sr_temp <= #DLY  rd_data[493];
        9'd19:   data4sr_temp <= #DLY  rd_data[492];
        9'd20:   data4sr_temp <= #DLY  rd_data[491];
        9'd21:   data4sr_temp <= #DLY  rd_data[490];
        9'd22:   data4sr_temp <= #DLY  rd_data[489];
        9'd23:   data4sr_temp <= #DLY  rd_data[488];
        9'd24:   data4sr_temp <= #DLY  rd_data[487];
        9'd25:   data4sr_temp <= #DLY  rd_data[486];
        9'd26:   data4sr_temp <= #DLY  rd_data[485];
        9'd27:   data4sr_temp <= #DLY  rd_data[484];
        9'd28:   data4sr_temp <= #DLY  rd_data[483];
        9'd29:   data4sr_temp <= #DLY  rd_data[482];
        9'd30:   data4sr_temp <= #DLY  rd_data[481];
        9'd31:   data4sr_temp <= #DLY  rd_data[480];
        9'd32:   data4sr_temp <= #DLY  rd_data[479];
        9'd33:   data4sr_temp <= #DLY  rd_data[478];
        9'd34:   data4sr_temp <= #DLY  rd_data[477];
        9'd35:   data4sr_temp <= #DLY  rd_data[476];
        9'd36:   data4sr_temp <= #DLY  rd_data[475];
        9'd37:   data4sr_temp <= #DLY  rd_data[474];
        9'd38:   data4sr_temp <= #DLY  rd_data[473];
        9'd39:   data4sr_temp <= #DLY  rd_data[472];
        9'd40:   data4sr_temp <= #DLY  rd_data[471];
        9'd41:   data4sr_temp <= #DLY  rd_data[470];
        9'd42:   data4sr_temp <= #DLY  rd_data[469];
        9'd43:   data4sr_temp <= #DLY  rd_data[468];
        9'd44:   data4sr_temp <= #DLY  rd_data[467];
        9'd45:   data4sr_temp <= #DLY  rd_data[466];
        9'd46:   data4sr_temp <= #DLY  rd_data[465];
        9'd47:   data4sr_temp <= #DLY  rd_data[464];
        9'd48:   data4sr_temp <= #DLY  rd_data[463];
        9'd49:   data4sr_temp <= #DLY  rd_data[462];
        9'd50:   data4sr_temp <= #DLY  rd_data[461];
        9'd51:   data4sr_temp <= #DLY  rd_data[460];
        9'd52:   data4sr_temp <= #DLY  rd_data[459];
        9'd53:   data4sr_temp <= #DLY  rd_data[458];
        9'd54:   data4sr_temp <= #DLY  rd_data[457];
        9'd55:   data4sr_temp <= #DLY  rd_data[456];
        9'd56:   data4sr_temp <= #DLY  rd_data[455];
        9'd57:   data4sr_temp <= #DLY  rd_data[454];
        9'd58:   data4sr_temp <= #DLY  rd_data[453];
        9'd59:   data4sr_temp <= #DLY  rd_data[452];
        9'd60:   data4sr_temp <= #DLY  rd_data[451];
        9'd61:   data4sr_temp <= #DLY  rd_data[450];
        9'd62:   data4sr_temp <= #DLY  rd_data[449];
        9'd63:   data4sr_temp <= #DLY  rd_data[448];
        9'd64:   data4sr_temp <= #DLY  rd_data[447];
        9'd65:   data4sr_temp <= #DLY  rd_data[446];
        9'd66:   data4sr_temp <= #DLY  rd_data[445];
        9'd67:   data4sr_temp <= #DLY  rd_data[444];
        9'd68:   data4sr_temp <= #DLY  rd_data[443];
        9'd69:   data4sr_temp <= #DLY  rd_data[442];
        9'd70:   data4sr_temp <= #DLY  rd_data[441];
        9'd71:   data4sr_temp <= #DLY  rd_data[440];
        9'd72:   data4sr_temp <= #DLY  rd_data[439];
        9'd73:   data4sr_temp <= #DLY  rd_data[438];
        9'd74:   data4sr_temp <= #DLY  rd_data[437];
        9'd75:   data4sr_temp <= #DLY  rd_data[436];
        9'd76:   data4sr_temp <= #DLY  rd_data[435];
        9'd77:   data4sr_temp <= #DLY  rd_data[434];
        9'd78:   data4sr_temp <= #DLY  rd_data[433];
        9'd79:   data4sr_temp <= #DLY  rd_data[432];
        9'd80:   data4sr_temp <= #DLY  rd_data[431];
        9'd81:   data4sr_temp <= #DLY  rd_data[430];
        9'd82:   data4sr_temp <= #DLY  rd_data[429];
        9'd83:   data4sr_temp <= #DLY  rd_data[428];
        9'd84:   data4sr_temp <= #DLY  rd_data[427];
        9'd85:   data4sr_temp <= #DLY  rd_data[426];
        9'd86:   data4sr_temp <= #DLY  rd_data[425];
        9'd87:   data4sr_temp <= #DLY  rd_data[424];
        9'd88:   data4sr_temp <= #DLY  rd_data[423];
        9'd89:   data4sr_temp <= #DLY  rd_data[422];
        9'd90:   data4sr_temp <= #DLY  rd_data[421];
        9'd91:   data4sr_temp <= #DLY  rd_data[420];
        9'd92:   data4sr_temp <= #DLY  rd_data[419];
        9'd93:   data4sr_temp <= #DLY  rd_data[418];
        9'd94:   data4sr_temp <= #DLY  rd_data[417];
        9'd95:   data4sr_temp <= #DLY  rd_data[416];
        9'd96:   data4sr_temp <= #DLY  rd_data[415];
        9'd97:   data4sr_temp <= #DLY  rd_data[414];
        9'd98:   data4sr_temp <= #DLY  rd_data[413];
        9'd99:   data4sr_temp <= #DLY  rd_data[412];
        9'd100:   data4sr_temp <= #DLY  rd_data[411];
        9'd101:   data4sr_temp <= #DLY  rd_data[410];
        9'd102:   data4sr_temp <= #DLY  rd_data[409];
        9'd103:   data4sr_temp <= #DLY  rd_data[408];
        9'd104:   data4sr_temp <= #DLY  rd_data[407];
        9'd105:   data4sr_temp <= #DLY  rd_data[406];
        9'd106:   data4sr_temp <= #DLY  rd_data[405];
        9'd107:   data4sr_temp <= #DLY  rd_data[404];
        9'd108:   data4sr_temp <= #DLY  rd_data[403];
        9'd109:   data4sr_temp <= #DLY  rd_data[402];
        9'd110:   data4sr_temp <= #DLY  rd_data[401];
        9'd111:   data4sr_temp <= #DLY  rd_data[400];
        9'd112:   data4sr_temp <= #DLY  rd_data[399];
        9'd113:   data4sr_temp <= #DLY  rd_data[398];
        9'd114:   data4sr_temp <= #DLY  rd_data[397];
        9'd115:   data4sr_temp <= #DLY  rd_data[396];
        9'd116:   data4sr_temp <= #DLY  rd_data[395];
        9'd117:   data4sr_temp <= #DLY  rd_data[394];
        9'd118:   data4sr_temp <= #DLY  rd_data[393];
        9'd119:   data4sr_temp <= #DLY  rd_data[392];
        9'd120:   data4sr_temp <= #DLY  rd_data[391];
        9'd121:   data4sr_temp <= #DLY  rd_data[390];
        9'd122:   data4sr_temp <= #DLY  rd_data[389];
        9'd123:   data4sr_temp <= #DLY  rd_data[388];
        9'd124:   data4sr_temp <= #DLY  rd_data[387];
        9'd125:   data4sr_temp <= #DLY  rd_data[386];
        9'd126:   data4sr_temp <= #DLY  rd_data[385];
        9'd127:   data4sr_temp <= #DLY  rd_data[384];
        9'd128:   data4sr_temp <= #DLY  rd_data[383];
        9'd129:   data4sr_temp <= #DLY  rd_data[382];
        9'd130:   data4sr_temp <= #DLY  rd_data[381];
        9'd131:   data4sr_temp <= #DLY  rd_data[380];
        9'd132:   data4sr_temp <= #DLY  rd_data[379];
        9'd133:   data4sr_temp <= #DLY  rd_data[378];
        9'd134:   data4sr_temp <= #DLY  rd_data[377];
        9'd135:   data4sr_temp <= #DLY  rd_data[376];
        9'd136:   data4sr_temp <= #DLY  rd_data[375];
        9'd137:   data4sr_temp <= #DLY  rd_data[374];
        9'd138:   data4sr_temp <= #DLY  rd_data[373];
        9'd139:   data4sr_temp <= #DLY  rd_data[372];
        9'd140:   data4sr_temp <= #DLY  rd_data[371];
        9'd141:   data4sr_temp <= #DLY  rd_data[370];
        9'd142:   data4sr_temp <= #DLY  rd_data[369];
        9'd143:   data4sr_temp <= #DLY  rd_data[368];
        9'd144:   data4sr_temp <= #DLY  rd_data[367];
        9'd145:   data4sr_temp <= #DLY  rd_data[366];
        9'd146:   data4sr_temp <= #DLY  rd_data[365];
        9'd147:   data4sr_temp <= #DLY  rd_data[364];
        9'd148:   data4sr_temp <= #DLY  rd_data[363];
        9'd149:   data4sr_temp <= #DLY  rd_data[362];
        9'd150:   data4sr_temp <= #DLY  rd_data[361];
        9'd151:   data4sr_temp <= #DLY  rd_data[360];
        9'd152:   data4sr_temp <= #DLY  rd_data[359];
        9'd153:   data4sr_temp <= #DLY  rd_data[358];
        9'd154:   data4sr_temp <= #DLY  rd_data[357];
        9'd155:   data4sr_temp <= #DLY  rd_data[356];
        9'd156:   data4sr_temp <= #DLY  rd_data[355];
        9'd157:   data4sr_temp <= #DLY  rd_data[354];
        9'd158:   data4sr_temp <= #DLY  rd_data[353];
        9'd159:   data4sr_temp <= #DLY  rd_data[352];
        9'd160:   data4sr_temp <= #DLY  rd_data[351];
        9'd161:   data4sr_temp <= #DLY  rd_data[350];
        9'd162:   data4sr_temp <= #DLY  rd_data[349];
        9'd163:   data4sr_temp <= #DLY  rd_data[348];
        9'd164:   data4sr_temp <= #DLY  rd_data[347];
        9'd165:   data4sr_temp <= #DLY  rd_data[346];
        9'd166:   data4sr_temp <= #DLY  rd_data[345];
        9'd167:   data4sr_temp <= #DLY  rd_data[344];
        9'd168:   data4sr_temp <= #DLY  rd_data[343];
        9'd169:   data4sr_temp <= #DLY  rd_data[342];
        9'd170:   data4sr_temp <= #DLY  rd_data[341];
        9'd171:   data4sr_temp <= #DLY  rd_data[340];
        9'd172:   data4sr_temp <= #DLY  rd_data[339];
        9'd173:   data4sr_temp <= #DLY  rd_data[338];
        9'd174:   data4sr_temp <= #DLY  rd_data[337];
        9'd175:   data4sr_temp <= #DLY  rd_data[336];
        9'd176:   data4sr_temp <= #DLY  rd_data[335];
        9'd177:   data4sr_temp <= #DLY  rd_data[334];
        9'd178:   data4sr_temp <= #DLY  rd_data[333];
        9'd179:   data4sr_temp <= #DLY  rd_data[332];
        9'd180:   data4sr_temp <= #DLY  rd_data[331];
        9'd181:   data4sr_temp <= #DLY  rd_data[330];
        9'd182:   data4sr_temp <= #DLY  rd_data[329];
        9'd183:   data4sr_temp <= #DLY  rd_data[328];
        9'd184:   data4sr_temp <= #DLY  rd_data[327];
        9'd185:   data4sr_temp <= #DLY  rd_data[326];
        9'd186:   data4sr_temp <= #DLY  rd_data[325];
        9'd187:   data4sr_temp <= #DLY  rd_data[324];
        9'd188:   data4sr_temp <= #DLY  rd_data[323];
        9'd189:   data4sr_temp <= #DLY  rd_data[322];
        9'd190:   data4sr_temp <= #DLY  rd_data[321];
        9'd191:   data4sr_temp <= #DLY  rd_data[320];
        9'd192:   data4sr_temp <= #DLY  rd_data[319];
        9'd193:   data4sr_temp <= #DLY  rd_data[318];
        9'd194:   data4sr_temp <= #DLY  rd_data[317];
        9'd195:   data4sr_temp <= #DLY  rd_data[316];
        9'd196:   data4sr_temp <= #DLY  rd_data[315];
        9'd197:   data4sr_temp <= #DLY  rd_data[314];
        9'd198:   data4sr_temp <= #DLY  rd_data[313];
        9'd199:   data4sr_temp <= #DLY  rd_data[312];
        9'd200:   data4sr_temp <= #DLY  rd_data[311];
        9'd201:   data4sr_temp <= #DLY  rd_data[310];
        9'd202:   data4sr_temp <= #DLY  rd_data[309];
        9'd203:   data4sr_temp <= #DLY  rd_data[308];
        9'd204:   data4sr_temp <= #DLY  rd_data[307];
        9'd205:   data4sr_temp <= #DLY  rd_data[306];
        9'd206:   data4sr_temp <= #DLY  rd_data[305];
        9'd207:   data4sr_temp <= #DLY  rd_data[304];
        9'd208:   data4sr_temp <= #DLY  rd_data[303];
        9'd209:   data4sr_temp <= #DLY  rd_data[302];
        9'd210:   data4sr_temp <= #DLY  rd_data[301];
        9'd211:   data4sr_temp <= #DLY  rd_data[300];
        9'd212:   data4sr_temp <= #DLY  rd_data[299];
        9'd213:   data4sr_temp <= #DLY  rd_data[298];
        9'd214:   data4sr_temp <= #DLY  rd_data[297];
        9'd215:   data4sr_temp <= #DLY  rd_data[296];
        9'd216:   data4sr_temp <= #DLY  rd_data[295];
        9'd217:   data4sr_temp <= #DLY  rd_data[294];
        9'd218:   data4sr_temp <= #DLY  rd_data[293];
        9'd219:   data4sr_temp <= #DLY  rd_data[292];
        9'd220:   data4sr_temp <= #DLY  rd_data[291];
        9'd221:   data4sr_temp <= #DLY  rd_data[290];
        9'd222:   data4sr_temp <= #DLY  rd_data[289];
        9'd223:   data4sr_temp <= #DLY  rd_data[288];
        9'd224:   data4sr_temp <= #DLY  rd_data[287];
        9'd225:   data4sr_temp <= #DLY  rd_data[286];
        9'd226:   data4sr_temp <= #DLY  rd_data[285];
        9'd227:   data4sr_temp <= #DLY  rd_data[284];
        9'd228:   data4sr_temp <= #DLY  rd_data[283];
        9'd229:   data4sr_temp <= #DLY  rd_data[282];
        9'd230:   data4sr_temp <= #DLY  rd_data[281];
        9'd231:   data4sr_temp <= #DLY  rd_data[280];
        9'd232:   data4sr_temp <= #DLY  rd_data[279];
        9'd233:   data4sr_temp <= #DLY  rd_data[278];
        9'd234:   data4sr_temp <= #DLY  rd_data[277];
        9'd235:   data4sr_temp <= #DLY  rd_data[276];
        9'd236:   data4sr_temp <= #DLY  rd_data[275];
        9'd237:   data4sr_temp <= #DLY  rd_data[274];
        9'd238:   data4sr_temp <= #DLY  rd_data[273];
        9'd239:   data4sr_temp <= #DLY  rd_data[272];
        9'd240:   data4sr_temp <= #DLY  rd_data[271];
        9'd241:   data4sr_temp <= #DLY  rd_data[270];
        9'd242:   data4sr_temp <= #DLY  rd_data[269];
        9'd243:   data4sr_temp <= #DLY  rd_data[268];
        9'd244:   data4sr_temp <= #DLY  rd_data[267];
        9'd245:   data4sr_temp <= #DLY  rd_data[266];
        9'd246:   data4sr_temp <= #DLY  rd_data[265];
        9'd247:   data4sr_temp <= #DLY  rd_data[264];
        9'd248:   data4sr_temp <= #DLY  rd_data[263];
        9'd249:   data4sr_temp <= #DLY  rd_data[262];
        9'd250:   data4sr_temp <= #DLY  rd_data[261];
        9'd251:   data4sr_temp <= #DLY  rd_data[260];
        9'd252:   data4sr_temp <= #DLY  rd_data[259];
        9'd253:   data4sr_temp <= #DLY  rd_data[258];
        9'd254:   data4sr_temp <= #DLY  rd_data[257];
        9'd255:   data4sr_temp <= #DLY  rd_data[256];
        9'd256:   data4sr_temp <= #DLY  rd_data[255];
        9'd257:   data4sr_temp <= #DLY  rd_data[254];
        9'd258:   data4sr_temp <= #DLY  rd_data[253];
        9'd259:   data4sr_temp <= #DLY  rd_data[252];
        9'd260:   data4sr_temp <= #DLY  rd_data[251];
        9'd261:   data4sr_temp <= #DLY  rd_data[250];
        9'd262:   data4sr_temp <= #DLY  rd_data[249];
        9'd263:   data4sr_temp <= #DLY  rd_data[248];
        9'd264:   data4sr_temp <= #DLY  rd_data[247];
        9'd265:   data4sr_temp <= #DLY  rd_data[246];
        9'd266:   data4sr_temp <= #DLY  rd_data[245];
        9'd267:   data4sr_temp <= #DLY  rd_data[244];
        9'd268:   data4sr_temp <= #DLY  rd_data[243];
        9'd269:   data4sr_temp <= #DLY  rd_data[242];
        9'd270:   data4sr_temp <= #DLY  rd_data[241];
        9'd271:   data4sr_temp <= #DLY  rd_data[240];
        9'd272:   data4sr_temp <= #DLY  rd_data[239];
        9'd273:   data4sr_temp <= #DLY  rd_data[238];
        9'd274:   data4sr_temp <= #DLY  rd_data[237];
        9'd275:   data4sr_temp <= #DLY  rd_data[236];
        9'd276:   data4sr_temp <= #DLY  rd_data[235];
        9'd277:   data4sr_temp <= #DLY  rd_data[234];
        9'd278:   data4sr_temp <= #DLY  rd_data[233];
        9'd279:   data4sr_temp <= #DLY  rd_data[232];
        9'd280:   data4sr_temp <= #DLY  rd_data[231];
        9'd281:   data4sr_temp <= #DLY  rd_data[230];
        9'd282:   data4sr_temp <= #DLY  rd_data[229];
        9'd283:   data4sr_temp <= #DLY  rd_data[228];
        9'd284:   data4sr_temp <= #DLY  rd_data[227];
        9'd285:   data4sr_temp <= #DLY  rd_data[226];
        9'd286:   data4sr_temp <= #DLY  rd_data[225];
        9'd287:   data4sr_temp <= #DLY  rd_data[224];
        9'd288:   data4sr_temp <= #DLY  rd_data[223];
        9'd289:   data4sr_temp <= #DLY  rd_data[222];
        9'd290:   data4sr_temp <= #DLY  rd_data[221];
        9'd291:   data4sr_temp <= #DLY  rd_data[220];
        9'd292:   data4sr_temp <= #DLY  rd_data[219];
        9'd293:   data4sr_temp <= #DLY  rd_data[218];
        9'd294:   data4sr_temp <= #DLY  rd_data[217];
        9'd295:   data4sr_temp <= #DLY  rd_data[216];
        9'd296:   data4sr_temp <= #DLY  rd_data[215];
        9'd297:   data4sr_temp <= #DLY  rd_data[214];
        9'd298:   data4sr_temp <= #DLY  rd_data[213];
        9'd299:   data4sr_temp <= #DLY  rd_data[212];
        9'd300:   data4sr_temp <= #DLY  rd_data[211];
        9'd301:   data4sr_temp <= #DLY  rd_data[210];
        9'd302:   data4sr_temp <= #DLY  rd_data[209];
        9'd303:   data4sr_temp <= #DLY  rd_data[208];
        9'd304:   data4sr_temp <= #DLY  rd_data[207];
        9'd305:   data4sr_temp <= #DLY  rd_data[206];
        9'd306:   data4sr_temp <= #DLY  rd_data[205];
        9'd307:   data4sr_temp <= #DLY  rd_data[204];
        9'd308:   data4sr_temp <= #DLY  rd_data[203];
        9'd309:   data4sr_temp <= #DLY  rd_data[202];
        9'd310:   data4sr_temp <= #DLY  rd_data[201];
        9'd311:   data4sr_temp <= #DLY  rd_data[200];
        9'd312:   data4sr_temp <= #DLY  rd_data[199];
        9'd313:   data4sr_temp <= #DLY  rd_data[198];
        9'd314:   data4sr_temp <= #DLY  rd_data[197];
        9'd315:   data4sr_temp <= #DLY  rd_data[196];
        9'd316:   data4sr_temp <= #DLY  rd_data[195];
        9'd317:   data4sr_temp <= #DLY  rd_data[194];
        9'd318:   data4sr_temp <= #DLY  rd_data[193];
        9'd319:   data4sr_temp <= #DLY  rd_data[192];
        9'd320:   data4sr_temp <= #DLY  rd_data[191];
        9'd321:   data4sr_temp <= #DLY  rd_data[190];
        9'd322:   data4sr_temp <= #DLY  rd_data[189];
        9'd323:   data4sr_temp <= #DLY  rd_data[188];
        9'd324:   data4sr_temp <= #DLY  rd_data[187];
        9'd325:   data4sr_temp <= #DLY  rd_data[186];
        9'd326:   data4sr_temp <= #DLY  rd_data[185];
        9'd327:   data4sr_temp <= #DLY  rd_data[184];
        9'd328:   data4sr_temp <= #DLY  rd_data[183];
        9'd329:   data4sr_temp <= #DLY  rd_data[182];
        9'd330:   data4sr_temp <= #DLY  rd_data[181];
        9'd331:   data4sr_temp <= #DLY  rd_data[180];
        9'd332:   data4sr_temp <= #DLY  rd_data[179];
        9'd333:   data4sr_temp <= #DLY  rd_data[178];
        9'd334:   data4sr_temp <= #DLY  rd_data[177];
        9'd335:   data4sr_temp <= #DLY  rd_data[176];
        9'd336:   data4sr_temp <= #DLY  rd_data[175];
        9'd337:   data4sr_temp <= #DLY  rd_data[174];
        9'd338:   data4sr_temp <= #DLY  rd_data[173];
        9'd339:   data4sr_temp <= #DLY  rd_data[172];
        9'd340:   data4sr_temp <= #DLY  rd_data[171];
        9'd341:   data4sr_temp <= #DLY  rd_data[170];
        9'd342:   data4sr_temp <= #DLY  rd_data[169];
        9'd343:   data4sr_temp <= #DLY  rd_data[168];
        9'd344:   data4sr_temp <= #DLY  rd_data[167];
        9'd345:   data4sr_temp <= #DLY  rd_data[166];
        9'd346:   data4sr_temp <= #DLY  rd_data[165];
        9'd347:   data4sr_temp <= #DLY  rd_data[164];
        9'd348:   data4sr_temp <= #DLY  rd_data[163];
        9'd349:   data4sr_temp <= #DLY  rd_data[162];
        9'd350:   data4sr_temp <= #DLY  rd_data[161];
        9'd351:   data4sr_temp <= #DLY  rd_data[160];
        9'd352:   data4sr_temp <= #DLY  rd_data[159];
        9'd353:   data4sr_temp <= #DLY  rd_data[158];
        9'd354:   data4sr_temp <= #DLY  rd_data[157];
        9'd355:   data4sr_temp <= #DLY  rd_data[156];
        9'd356:   data4sr_temp <= #DLY  rd_data[155];
        9'd357:   data4sr_temp <= #DLY  rd_data[154];
        9'd358:   data4sr_temp <= #DLY  rd_data[153];
        9'd359:   data4sr_temp <= #DLY  rd_data[152];
        9'd360:   data4sr_temp <= #DLY  rd_data[151];
        9'd361:   data4sr_temp <= #DLY  rd_data[150];
        9'd362:   data4sr_temp <= #DLY  rd_data[149];
        9'd363:   data4sr_temp <= #DLY  rd_data[148];
        9'd364:   data4sr_temp <= #DLY  rd_data[147];
        9'd365:   data4sr_temp <= #DLY  rd_data[146];
        9'd366:   data4sr_temp <= #DLY  rd_data[145];
        9'd367:   data4sr_temp <= #DLY  rd_data[144];
        9'd368:   data4sr_temp <= #DLY  rd_data[143];
        9'd369:   data4sr_temp <= #DLY  rd_data[142];
        9'd370:   data4sr_temp <= #DLY  rd_data[141];
        9'd371:   data4sr_temp <= #DLY  rd_data[140];
        9'd372:   data4sr_temp <= #DLY  rd_data[139];
        9'd373:   data4sr_temp <= #DLY  rd_data[138];
        9'd374:   data4sr_temp <= #DLY  rd_data[137];
        9'd375:   data4sr_temp <= #DLY  rd_data[136];
        9'd376:   data4sr_temp <= #DLY  rd_data[135];
        9'd377:   data4sr_temp <= #DLY  rd_data[134];
        9'd378:   data4sr_temp <= #DLY  rd_data[133];
        9'd379:   data4sr_temp <= #DLY  rd_data[132];
        9'd380:   data4sr_temp <= #DLY  rd_data[131];
        9'd381:   data4sr_temp <= #DLY  rd_data[130];
        9'd382:   data4sr_temp <= #DLY  rd_data[129];
        9'd383:   data4sr_temp <= #DLY  rd_data[128];
        9'd384:   data4sr_temp <= #DLY  rd_data[127];
        9'd385:   data4sr_temp <= #DLY  rd_data[126];
        9'd386:   data4sr_temp <= #DLY  rd_data[125];
        9'd387:   data4sr_temp <= #DLY  rd_data[124];
        9'd388:   data4sr_temp <= #DLY  rd_data[123];
        9'd389:   data4sr_temp <= #DLY  rd_data[122];
        9'd390:   data4sr_temp <= #DLY  rd_data[121];
        9'd391:   data4sr_temp <= #DLY  rd_data[120];
        9'd392:   data4sr_temp <= #DLY  rd_data[119];
        9'd393:   data4sr_temp <= #DLY  rd_data[118];
        9'd394:   data4sr_temp <= #DLY  rd_data[117];
        9'd395:   data4sr_temp <= #DLY  rd_data[116];
        9'd396:   data4sr_temp <= #DLY  rd_data[115];
        9'd397:   data4sr_temp <= #DLY  rd_data[114];
        9'd398:   data4sr_temp <= #DLY  rd_data[113];
        9'd399:   data4sr_temp <= #DLY  rd_data[112];
        9'd400:   data4sr_temp <= #DLY  rd_data[111];
        9'd401:   data4sr_temp <= #DLY  rd_data[110];
        9'd402:   data4sr_temp <= #DLY  rd_data[109];
        9'd403:   data4sr_temp <= #DLY  rd_data[108];
        9'd404:   data4sr_temp <= #DLY  rd_data[107];
        9'd405:   data4sr_temp <= #DLY  rd_data[106];
        9'd406:   data4sr_temp <= #DLY  rd_data[105];
        9'd407:   data4sr_temp <= #DLY  rd_data[104];
        9'd408:   data4sr_temp <= #DLY  rd_data[103];
        9'd409:   data4sr_temp <= #DLY  rd_data[102];
        9'd410:   data4sr_temp <= #DLY  rd_data[101];
        9'd411:   data4sr_temp <= #DLY  rd_data[100];
        9'd412:   data4sr_temp <= #DLY  rd_data[99];
        9'd413:   data4sr_temp <= #DLY  rd_data[98];
        9'd414:   data4sr_temp <= #DLY  rd_data[97];
        9'd415:   data4sr_temp <= #DLY  rd_data[96];
        9'd416:   data4sr_temp <= #DLY  rd_data[95];
        9'd417:   data4sr_temp <= #DLY  rd_data[94];
        9'd418:   data4sr_temp <= #DLY  rd_data[93];
        9'd419:   data4sr_temp <= #DLY  rd_data[92];
        9'd420:   data4sr_temp <= #DLY  rd_data[91];
        9'd421:   data4sr_temp <= #DLY  rd_data[90];
        9'd422:   data4sr_temp <= #DLY  rd_data[89];
        9'd423:   data4sr_temp <= #DLY  rd_data[88];
        9'd424:   data4sr_temp <= #DLY  rd_data[87];
        9'd425:   data4sr_temp <= #DLY  rd_data[86];
        9'd426:   data4sr_temp <= #DLY  rd_data[85];
        9'd427:   data4sr_temp <= #DLY  rd_data[84];
        9'd428:   data4sr_temp <= #DLY  rd_data[83];
        9'd429:   data4sr_temp <= #DLY  rd_data[82];
        9'd430:   data4sr_temp <= #DLY  rd_data[81];
        9'd431:   data4sr_temp <= #DLY  rd_data[80];
        9'd432:   data4sr_temp <= #DLY  rd_data[79];
        9'd433:   data4sr_temp <= #DLY  rd_data[78];
        9'd434:   data4sr_temp <= #DLY  rd_data[77];
        9'd435:   data4sr_temp <= #DLY  rd_data[76];
        9'd436:   data4sr_temp <= #DLY  rd_data[75];
        9'd437:   data4sr_temp <= #DLY  rd_data[74];
        9'd438:   data4sr_temp <= #DLY  rd_data[73];
        9'd439:   data4sr_temp <= #DLY  rd_data[72];
        9'd440:   data4sr_temp <= #DLY  rd_data[71];
        9'd441:   data4sr_temp <= #DLY  rd_data[70];
        9'd442:   data4sr_temp <= #DLY  rd_data[69];
        9'd443:   data4sr_temp <= #DLY  rd_data[68];
        9'd444:   data4sr_temp <= #DLY  rd_data[67];
        9'd445:   data4sr_temp <= #DLY  rd_data[66];
        9'd446:   data4sr_temp <= #DLY  rd_data[65];
        9'd447:   data4sr_temp <= #DLY  rd_data[64];
        9'd448:   data4sr_temp <= #DLY  rd_data[63];
        9'd449:   data4sr_temp <= #DLY  rd_data[62];
        9'd450:   data4sr_temp <= #DLY  rd_data[61];
        9'd451:   data4sr_temp <= #DLY  rd_data[60];
        9'd452:   data4sr_temp <= #DLY  rd_data[59];
        9'd453:   data4sr_temp <= #DLY  rd_data[58];
        9'd454:   data4sr_temp <= #DLY  rd_data[57];
        9'd455:   data4sr_temp <= #DLY  rd_data[56];
        9'd456:   data4sr_temp <= #DLY  rd_data[55];
        9'd457:   data4sr_temp <= #DLY  rd_data[54];
        9'd458:   data4sr_temp <= #DLY  rd_data[53];
        9'd459:   data4sr_temp <= #DLY  rd_data[52];
        9'd460:   data4sr_temp <= #DLY  rd_data[51];
        9'd461:   data4sr_temp <= #DLY  rd_data[50];
        9'd462:   data4sr_temp <= #DLY  rd_data[49];
        9'd463:   data4sr_temp <= #DLY  rd_data[48];
        9'd464:   data4sr_temp <= #DLY  rd_data[47];
        9'd465:   data4sr_temp <= #DLY  rd_data[46];
        9'd466:   data4sr_temp <= #DLY  rd_data[45];
        9'd467:   data4sr_temp <= #DLY  rd_data[44];
        9'd468:   data4sr_temp <= #DLY  rd_data[43];
        9'd469:   data4sr_temp <= #DLY  rd_data[42];
        9'd470:   data4sr_temp <= #DLY  rd_data[41];
        9'd471:   data4sr_temp <= #DLY  rd_data[40];
        9'd472:   data4sr_temp <= #DLY  rd_data[39];
        9'd473:   data4sr_temp <= #DLY  rd_data[38];
        9'd474:   data4sr_temp <= #DLY  rd_data[37];
        9'd475:   data4sr_temp <= #DLY  rd_data[36];
        9'd476:   data4sr_temp <= #DLY  rd_data[35];
        9'd477:   data4sr_temp <= #DLY  rd_data[34];
        9'd478:   data4sr_temp <= #DLY  rd_data[33];
        9'd479:   data4sr_temp <= #DLY  rd_data[32];
        9'd480:   data4sr_temp <= #DLY  rd_data[31];
        9'd481:   data4sr_temp <= #DLY  rd_data[30];
        9'd482:   data4sr_temp <= #DLY  rd_data[29];
        9'd483:   data4sr_temp <= #DLY  rd_data[28];
        9'd484:   data4sr_temp <= #DLY  rd_data[27];
        9'd485:   data4sr_temp <= #DLY  rd_data[26];
        9'd486:   data4sr_temp <= #DLY  rd_data[25];
        9'd487:   data4sr_temp <= #DLY  rd_data[24];
        9'd488:   data4sr_temp <= #DLY  rd_data[23];
        9'd489:   data4sr_temp <= #DLY  rd_data[22];
        9'd490:   data4sr_temp <= #DLY  rd_data[21];
        9'd491:   data4sr_temp <= #DLY  rd_data[20];
        9'd492:   data4sr_temp <= #DLY  rd_data[19];
        9'd493:   data4sr_temp <= #DLY  rd_data[18];
        9'd494:   data4sr_temp <= #DLY  rd_data[17];
        9'd495:   data4sr_temp <= #DLY  rd_data[16];
        9'd496:   data4sr_temp <= #DLY  rd_data[15];
        9'd497:   data4sr_temp <= #DLY  rd_data[14];
        9'd498:   data4sr_temp <= #DLY  rd_data[13];
        9'd499:   data4sr_temp <= #DLY  rd_data[12];
        9'd500:   data4sr_temp <= #DLY  rd_data[11];
        9'd501:   data4sr_temp <= #DLY  rd_data[10];
        9'd502:   data4sr_temp <= #DLY  rd_data[9];
        9'd503:   data4sr_temp <= #DLY  rd_data[8];
        9'd504:   data4sr_temp <= #DLY  rd_data[7];
        9'd505:   data4sr_temp <= #DLY  rd_data[6];
        9'd506:   data4sr_temp <= #DLY  rd_data[5];
        9'd507:   data4sr_temp <= #DLY  rd_data[4];
        9'd508:   data4sr_temp <= #DLY  rd_data[3];
        9'd509:   data4sr_temp <= #DLY  rd_data[2];
        9'd510:   data4sr_temp <= #DLY  rd_data[1];
        9'd511:   data4sr_temp <= #DLY  rd_data[0];
        default:   data4sr_temp <= 2'b0;
      endcase
     // else;
end


assign data4sr = data4sr_temp;

`else
// 2014-12-4, 21:17:13

always @(posedge image_clk)
begin
    if(image_rst)
      data4sr_temp <= 2'b0;
    else
      if(current_state == RD_DATA)
        case(cnt512toN)
        9'd0:   data4sr_temp <= #DLY  rd_data[511:510];
        9'd1:   data4sr_temp <= #DLY  rd_data[509:508];
        9'd2:   data4sr_temp <= #DLY  rd_data[507:506];
        9'd3:   data4sr_temp <= #DLY  rd_data[505:504];
        9'd4:   data4sr_temp <= #DLY  rd_data[503:502];
        9'd5:   data4sr_temp <= #DLY  rd_data[501:500];
        9'd6:   data4sr_temp <= #DLY  rd_data[499:498];
        9'd7:   data4sr_temp <= #DLY  rd_data[497:496];
        9'd8:   data4sr_temp <= #DLY  rd_data[495:494];
        9'd9:   data4sr_temp <= #DLY  rd_data[493:492];
        9'd10:   data4sr_temp <= #DLY  rd_data[491:490];
        9'd11:   data4sr_temp <= #DLY  rd_data[489:488];
        9'd12:   data4sr_temp <= #DLY  rd_data[487:486];
        9'd13:   data4sr_temp <= #DLY  rd_data[485:484];
        9'd14:   data4sr_temp <= #DLY  rd_data[483:482];
        9'd15:   data4sr_temp <= #DLY  rd_data[481:480];
        9'd16:   data4sr_temp <= #DLY  rd_data[479:478];
        9'd17:   data4sr_temp <= #DLY  rd_data[477:476];
        9'd18:   data4sr_temp <= #DLY  rd_data[475:474];
        9'd19:   data4sr_temp <= #DLY  rd_data[473:472];
        9'd20:   data4sr_temp <= #DLY  rd_data[471:470];
        9'd21:   data4sr_temp <= #DLY  rd_data[469:468];
        9'd22:   data4sr_temp <= #DLY  rd_data[467:466];
        9'd23:   data4sr_temp <= #DLY  rd_data[465:464];
        9'd24:   data4sr_temp <= #DLY  rd_data[463:462];
        9'd25:   data4sr_temp <= #DLY  rd_data[461:460];
        9'd26:   data4sr_temp <= #DLY  rd_data[459:458];
        9'd27:   data4sr_temp <= #DLY  rd_data[457:456];
        9'd28:   data4sr_temp <= #DLY  rd_data[455:454];
        9'd29:   data4sr_temp <= #DLY  rd_data[453:452];
        9'd30:   data4sr_temp <= #DLY  rd_data[451:450];
        9'd31:   data4sr_temp <= #DLY  rd_data[449:448];
        9'd32:   data4sr_temp <= #DLY  rd_data[447:446];
        9'd33:   data4sr_temp <= #DLY  rd_data[445:444];
        9'd34:   data4sr_temp <= #DLY  rd_data[443:442];
        9'd35:   data4sr_temp <= #DLY  rd_data[441:440];
        9'd36:   data4sr_temp <= #DLY  rd_data[439:438];
        9'd37:   data4sr_temp <= #DLY  rd_data[437:436];
        9'd38:   data4sr_temp <= #DLY  rd_data[435:434];
        9'd39:   data4sr_temp <= #DLY  rd_data[433:432];
        9'd40:   data4sr_temp <= #DLY  rd_data[431:430];
        9'd41:   data4sr_temp <= #DLY  rd_data[429:428];
        9'd42:   data4sr_temp <= #DLY  rd_data[427:426];
        9'd43:   data4sr_temp <= #DLY  rd_data[425:424];
        9'd44:   data4sr_temp <= #DLY  rd_data[423:422];
        9'd45:   data4sr_temp <= #DLY  rd_data[421:420];
        9'd46:   data4sr_temp <= #DLY  rd_data[419:418];
        9'd47:   data4sr_temp <= #DLY  rd_data[417:416];
        9'd48:   data4sr_temp <= #DLY  rd_data[415:414];
        9'd49:   data4sr_temp <= #DLY  rd_data[413:412];
        9'd50:   data4sr_temp <= #DLY  rd_data[411:410];
        9'd51:   data4sr_temp <= #DLY  rd_data[409:408];
        9'd52:   data4sr_temp <= #DLY  rd_data[407:406];
        9'd53:   data4sr_temp <= #DLY  rd_data[405:404];
        9'd54:   data4sr_temp <= #DLY  rd_data[403:402];
        9'd55:   data4sr_temp <= #DLY  rd_data[401:400];
        9'd56:   data4sr_temp <= #DLY  rd_data[399:398];
        9'd57:   data4sr_temp <= #DLY  rd_data[397:396];
        9'd58:   data4sr_temp <= #DLY  rd_data[395:394];
        9'd59:   data4sr_temp <= #DLY  rd_data[393:392];
        9'd60:   data4sr_temp <= #DLY  rd_data[391:390];
        9'd61:   data4sr_temp <= #DLY  rd_data[389:388];
        9'd62:   data4sr_temp <= #DLY  rd_data[387:386];
        9'd63:   data4sr_temp <= #DLY  rd_data[385:384];
        9'd64:   data4sr_temp <= #DLY  rd_data[383:382];
        9'd65:   data4sr_temp <= #DLY  rd_data[381:380];
        9'd66:   data4sr_temp <= #DLY  rd_data[379:378];
        9'd67:   data4sr_temp <= #DLY  rd_data[377:376];
        9'd68:   data4sr_temp <= #DLY  rd_data[375:374];
        9'd69:   data4sr_temp <= #DLY  rd_data[373:372];
        9'd70:   data4sr_temp <= #DLY  rd_data[371:370];
        9'd71:   data4sr_temp <= #DLY  rd_data[369:368];
        9'd72:   data4sr_temp <= #DLY  rd_data[367:366];
        9'd73:   data4sr_temp <= #DLY  rd_data[365:364];
        9'd74:   data4sr_temp <= #DLY  rd_data[363:362];
        9'd75:   data4sr_temp <= #DLY  rd_data[361:360];
        9'd76:   data4sr_temp <= #DLY  rd_data[359:358];
        9'd77:   data4sr_temp <= #DLY  rd_data[357:356];
        9'd78:   data4sr_temp <= #DLY  rd_data[355:354];
        9'd79:   data4sr_temp <= #DLY  rd_data[353:352];
        9'd80:   data4sr_temp <= #DLY  rd_data[351:350];
        9'd81:   data4sr_temp <= #DLY  rd_data[349:348];
        9'd82:   data4sr_temp <= #DLY  rd_data[347:346];
        9'd83:   data4sr_temp <= #DLY  rd_data[345:344];
        9'd84:   data4sr_temp <= #DLY  rd_data[343:342];
        9'd85:   data4sr_temp <= #DLY  rd_data[341:340];
        9'd86:   data4sr_temp <= #DLY  rd_data[339:338];
        9'd87:   data4sr_temp <= #DLY  rd_data[337:336];
        9'd88:   data4sr_temp <= #DLY  rd_data[335:334];
        9'd89:   data4sr_temp <= #DLY  rd_data[333:332];
        9'd90:   data4sr_temp <= #DLY  rd_data[331:330];
        9'd91:   data4sr_temp <= #DLY  rd_data[329:328];
        9'd92:   data4sr_temp <= #DLY  rd_data[327:326];
        9'd93:   data4sr_temp <= #DLY  rd_data[325:324];
        9'd94:   data4sr_temp <= #DLY  rd_data[323:322];
        9'd95:   data4sr_temp <= #DLY  rd_data[321:320];
        9'd96:   data4sr_temp <= #DLY  rd_data[319:318];
        9'd97:   data4sr_temp <= #DLY  rd_data[317:316];
        9'd98:   data4sr_temp <= #DLY  rd_data[315:314];
        9'd99:   data4sr_temp <= #DLY  rd_data[313:312];
        9'd100:   data4sr_temp <= #DLY  rd_data[311:310];
        9'd101:   data4sr_temp <= #DLY  rd_data[309:308];
        9'd102:   data4sr_temp <= #DLY  rd_data[307:306];
        9'd103:   data4sr_temp <= #DLY  rd_data[305:304];
        9'd104:   data4sr_temp <= #DLY  rd_data[303:302];
        9'd105:   data4sr_temp <= #DLY  rd_data[301:300];
        9'd106:   data4sr_temp <= #DLY  rd_data[299:298];
        9'd107:   data4sr_temp <= #DLY  rd_data[297:296];
        9'd108:   data4sr_temp <= #DLY  rd_data[295:294];
        9'd109:   data4sr_temp <= #DLY  rd_data[293:292];
        9'd110:   data4sr_temp <= #DLY  rd_data[291:290];
        9'd111:   data4sr_temp <= #DLY  rd_data[289:288];
        9'd112:   data4sr_temp <= #DLY  rd_data[287:286];
        9'd113:   data4sr_temp <= #DLY  rd_data[285:284];
        9'd114:   data4sr_temp <= #DLY  rd_data[283:282];
        9'd115:   data4sr_temp <= #DLY  rd_data[281:280];
        9'd116:   data4sr_temp <= #DLY  rd_data[279:278];
        9'd117:   data4sr_temp <= #DLY  rd_data[277:276];
        9'd118:   data4sr_temp <= #DLY  rd_data[275:274];
        9'd119:   data4sr_temp <= #DLY  rd_data[273:272];
        9'd120:   data4sr_temp <= #DLY  rd_data[271:270];
        9'd121:   data4sr_temp <= #DLY  rd_data[269:268];
        9'd122:   data4sr_temp <= #DLY  rd_data[267:266];
        9'd123:   data4sr_temp <= #DLY  rd_data[265:264];
        9'd124:   data4sr_temp <= #DLY  rd_data[263:262];
        9'd125:   data4sr_temp <= #DLY  rd_data[261:260];
        9'd126:   data4sr_temp <= #DLY  rd_data[259:258];
        9'd127:   data4sr_temp <= #DLY  rd_data[257:256];
        9'd128:   data4sr_temp <= #DLY  rd_data[255:254];
        9'd129:   data4sr_temp <= #DLY  rd_data[253:252];
        9'd130:   data4sr_temp <= #DLY  rd_data[251:250];
        9'd131:   data4sr_temp <= #DLY  rd_data[249:248];
        9'd132:   data4sr_temp <= #DLY  rd_data[247:246];
        9'd133:   data4sr_temp <= #DLY  rd_data[245:244];
        9'd134:   data4sr_temp <= #DLY  rd_data[243:242];
        9'd135:   data4sr_temp <= #DLY  rd_data[241:240];
        9'd136:   data4sr_temp <= #DLY  rd_data[239:238];
        9'd137:   data4sr_temp <= #DLY  rd_data[237:236];
        9'd138:   data4sr_temp <= #DLY  rd_data[235:234];
        9'd139:   data4sr_temp <= #DLY  rd_data[233:232];
        9'd140:   data4sr_temp <= #DLY  rd_data[231:230];
        9'd141:   data4sr_temp <= #DLY  rd_data[229:228];
        9'd142:   data4sr_temp <= #DLY  rd_data[227:226];
        9'd143:   data4sr_temp <= #DLY  rd_data[225:224];
        9'd144:   data4sr_temp <= #DLY  rd_data[223:222];
        9'd145:   data4sr_temp <= #DLY  rd_data[221:220];
        9'd146:   data4sr_temp <= #DLY  rd_data[219:218];
        9'd147:   data4sr_temp <= #DLY  rd_data[217:216];
        9'd148:   data4sr_temp <= #DLY  rd_data[215:214];
        9'd149:   data4sr_temp <= #DLY  rd_data[213:212];
        9'd150:   data4sr_temp <= #DLY  rd_data[211:210];
        9'd151:   data4sr_temp <= #DLY  rd_data[209:208];
        9'd152:   data4sr_temp <= #DLY  rd_data[207:206];
        9'd153:   data4sr_temp <= #DLY  rd_data[205:204];
        9'd154:   data4sr_temp <= #DLY  rd_data[203:202];
        9'd155:   data4sr_temp <= #DLY  rd_data[201:200];
        9'd156:   data4sr_temp <= #DLY  rd_data[199:198];
        9'd157:   data4sr_temp <= #DLY  rd_data[197:196];
        9'd158:   data4sr_temp <= #DLY  rd_data[195:194];
        9'd159:   data4sr_temp <= #DLY  rd_data[193:192];
        9'd160:   data4sr_temp <= #DLY  rd_data[191:190];
        9'd161:   data4sr_temp <= #DLY  rd_data[189:188];
        9'd162:   data4sr_temp <= #DLY  rd_data[187:186];
        9'd163:   data4sr_temp <= #DLY  rd_data[185:184];
        9'd164:   data4sr_temp <= #DLY  rd_data[183:182];
        9'd165:   data4sr_temp <= #DLY  rd_data[181:180];
        9'd166:   data4sr_temp <= #DLY  rd_data[179:178];
        9'd167:   data4sr_temp <= #DLY  rd_data[177:176];
        9'd168:   data4sr_temp <= #DLY  rd_data[175:174];
        9'd169:   data4sr_temp <= #DLY  rd_data[173:172];
        9'd170:   data4sr_temp <= #DLY  rd_data[171:170];
        9'd171:   data4sr_temp <= #DLY  rd_data[169:168];
        9'd172:   data4sr_temp <= #DLY  rd_data[167:166];
        9'd173:   data4sr_temp <= #DLY  rd_data[165:164];
        9'd174:   data4sr_temp <= #DLY  rd_data[163:162];
        9'd175:   data4sr_temp <= #DLY  rd_data[161:160];
        9'd176:   data4sr_temp <= #DLY  rd_data[159:158];
        9'd177:   data4sr_temp <= #DLY  rd_data[157:156];
        9'd178:   data4sr_temp <= #DLY  rd_data[155:154];
        9'd179:   data4sr_temp <= #DLY  rd_data[153:152];
        9'd180:   data4sr_temp <= #DLY  rd_data[151:150];
        9'd181:   data4sr_temp <= #DLY  rd_data[149:148];
        9'd182:   data4sr_temp <= #DLY  rd_data[147:146];
        9'd183:   data4sr_temp <= #DLY  rd_data[145:144];
        9'd184:   data4sr_temp <= #DLY  rd_data[143:142];
        9'd185:   data4sr_temp <= #DLY  rd_data[141:140];
        9'd186:   data4sr_temp <= #DLY  rd_data[139:138];
        9'd187:   data4sr_temp <= #DLY  rd_data[137:136];
        9'd188:   data4sr_temp <= #DLY  rd_data[135:134];
        9'd189:   data4sr_temp <= #DLY  rd_data[133:132];
        9'd190:   data4sr_temp <= #DLY  rd_data[131:130];
        9'd191:   data4sr_temp <= #DLY  rd_data[129:128];
        9'd192:   data4sr_temp <= #DLY  rd_data[127:126];
        9'd193:   data4sr_temp <= #DLY  rd_data[125:124];
        9'd194:   data4sr_temp <= #DLY  rd_data[123:122];
        9'd195:   data4sr_temp <= #DLY  rd_data[121:120];
        9'd196:   data4sr_temp <= #DLY  rd_data[119:118];
        9'd197:   data4sr_temp <= #DLY  rd_data[117:116];
        9'd198:   data4sr_temp <= #DLY  rd_data[115:114];
        9'd199:   data4sr_temp <= #DLY  rd_data[113:112];
        9'd200:   data4sr_temp <= #DLY  rd_data[111:110];
        9'd201:   data4sr_temp <= #DLY  rd_data[109:108];
        9'd202:   data4sr_temp <= #DLY  rd_data[107:106];
        9'd203:   data4sr_temp <= #DLY  rd_data[105:104];
        9'd204:   data4sr_temp <= #DLY  rd_data[103:102];
        9'd205:   data4sr_temp <= #DLY  rd_data[101:100];
        9'd206:   data4sr_temp <= #DLY  rd_data[99:98];
        9'd207:   data4sr_temp <= #DLY  rd_data[97:96];
        9'd208:   data4sr_temp <= #DLY  rd_data[95:94];
        9'd209:   data4sr_temp <= #DLY  rd_data[93:92];
        9'd210:   data4sr_temp <= #DLY  rd_data[91:90];
        9'd211:   data4sr_temp <= #DLY  rd_data[89:88];
        9'd212:   data4sr_temp <= #DLY  rd_data[87:86];
        9'd213:   data4sr_temp <= #DLY  rd_data[85:84];
        9'd214:   data4sr_temp <= #DLY  rd_data[83:82];
        9'd215:   data4sr_temp <= #DLY  rd_data[81:80];
        9'd216:   data4sr_temp <= #DLY  rd_data[79:78];
        9'd217:   data4sr_temp <= #DLY  rd_data[77:76];
        9'd218:   data4sr_temp <= #DLY  rd_data[75:74];
        9'd219:   data4sr_temp <= #DLY  rd_data[73:72];
        9'd220:   data4sr_temp <= #DLY  rd_data[71:70];
        9'd221:   data4sr_temp <= #DLY  rd_data[69:68];
        9'd222:   data4sr_temp <= #DLY  rd_data[67:66];
        9'd223:   data4sr_temp <= #DLY  rd_data[65:64];
        9'd224:   data4sr_temp <= #DLY  rd_data[63:62];
        9'd225:   data4sr_temp <= #DLY  rd_data[61:60];
        9'd226:   data4sr_temp <= #DLY  rd_data[59:58];
        9'd227:   data4sr_temp <= #DLY  rd_data[57:56];
        9'd228:   data4sr_temp <= #DLY  rd_data[55:54];
        9'd229:   data4sr_temp <= #DLY  rd_data[53:52];
        9'd230:   data4sr_temp <= #DLY  rd_data[51:50];
        9'd231:   data4sr_temp <= #DLY  rd_data[49:48];
        9'd232:   data4sr_temp <= #DLY  rd_data[47:46];
        9'd233:   data4sr_temp <= #DLY  rd_data[45:44];
        9'd234:   data4sr_temp <= #DLY  rd_data[43:42];
        9'd235:   data4sr_temp <= #DLY  rd_data[41:40];
        9'd236:   data4sr_temp <= #DLY  rd_data[39:38];
        9'd237:   data4sr_temp <= #DLY  rd_data[37:36];
        9'd238:   data4sr_temp <= #DLY  rd_data[35:34];
        9'd239:   data4sr_temp <= #DLY  rd_data[33:32];
        9'd240:   data4sr_temp <= #DLY  rd_data[31:30];
        9'd241:   data4sr_temp <= #DLY  rd_data[29:28];
        9'd242:   data4sr_temp <= #DLY  rd_data[27:26];
        9'd243:   data4sr_temp <= #DLY  rd_data[25:24];
        9'd244:   data4sr_temp <= #DLY  rd_data[23:22];
        9'd245:   data4sr_temp <= #DLY  rd_data[21:20];
        9'd246:   data4sr_temp <= #DLY  rd_data[19:18];
        9'd247:   data4sr_temp <= #DLY  rd_data[17:16];
        9'd248:   data4sr_temp <= #DLY  rd_data[15:14];
        9'd249:   data4sr_temp <= #DLY  rd_data[13:12];
        9'd250:   data4sr_temp <= #DLY  rd_data[11:10];
        9'd251:   data4sr_temp <= #DLY  rd_data[9:8];
        9'd252:   data4sr_temp <= #DLY  rd_data[7:6];
        9'd253:   data4sr_temp <= #DLY  rd_data[5:4];
        9'd254:   data4sr_temp <= #DLY  rd_data[3:2];
        9'd255:   data4sr_temp <= #DLY  rd_data[1:0];
        default:   data4sr_temp <= 2'b0;
      endcase
      else;
end


assign data4sr = {data4sr_temp[0], data4sr_temp[1]};

`endif


always @(posedge image_clk)
begin
  if(image_rst)
    data4sr_valid <= #DLY  1'b0;
  else
    if(current_state == RD_DATA  || current_state == PRE_RESULT_FULL )
      data4sr_valid <= #DLY  1'b1;
    else
      data4sr_valid <= #DLY  1'b0;
end

endmodule