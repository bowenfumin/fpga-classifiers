/*



\Device\NPF_{A06B112E-3B2E-4505-A0F6-B5AF5A65DAEB}

\Device\Tcpip_{B3839AEF-1C61-4E9C-BEAE-B83B02D85C94}

\Device\NPF_{B8C62160-1B11-4DF4-B9DA-505488AE350C}

*/

module memc_intf  #(

    parameter ADDR_WIDTH            = 28,  
    parameter DATA_WIDTH            = 512,
    parameter ROW_NUM               = 720,
    parameter Packet_len            = 132+32,
    parameter LB_EN                 = 0
    )
                  (
                   input                          clk,
                   input                          rst,
                   input                          init_calib_complete,
                   
                   //for rx_buf module
                   input                          pkt_ready,
                   input       [7:0]              rx_buf_data,
                   output      reg                wr_row_done,
                   output      reg    [10:0]      rd_addr_buf,
                   
                   input                          app_rdy ,
                   output  reg [ADDR_WIDTH-1:0]   app_addr,         
                   output      [2:0]              app_cmd ,
                   output                         app_en  ,                   
                   input                          app_wdf_rdy       ,          
                   output  [DATA_WIDTH-1:0]       app_wdf_data      ,
                   output  [DATA_WIDTH-1:0]       app_wdf_mask      ,
                   output  reg                    app_wdf_end       ,
                   output                         app_wdf_wren      ,
                   input   [DATA_WIDTH-1:0]       app_rd_data       ,
                   input                          app_rd_data_end   ,
                   input                          app_rd_data_valid ,
                                                  
                   input                          rx_fifo_clock     ,
                   input                          rx_fifo_resetn    ,                              
                   input    [7:0]                 rx_axis_tdata  ,
                   input                          rx_axis_tvalid ,
                   input                          rx_axis_tlast  ,
//                   output                         rx_axis_tready ,
                   
                   output   [5:0]                 data4sr,
                   output                         data4sr_valid,
                   input                          post_ddr_ram_full,
                   input                          lb_ram_full                         
                  );

localparam    DLY = 1000;

localparam    IDLE = 0,
              WR_DATA = 1,
              RD_DATA2TREE = 2,
              RD_DATA2LB = 3,
              POST_DDR_RAM_FULL = 4,
              LB_RAM_FULL = 5;

localparam    WR_ROW2DDR_CNT = 5; // writing two lines of image needs 5 times of write

localparam    ROW_NUM_DIV2 = ROW_NUM >> 1; // now take every two lines as one line     modified at 2014/11/18 15:21:13
localparam    JUMP_ONE_IMAGE = (ROW_NUM << 2) + (ROW_NUM << 4);
//wire                pkt_ready;


//wire   [9:0] ROW_NUM_DIV2;
//wire   [9:0] JUMP_ONE_IMAGE;
//assign ROW_NUM_DIV2 = ROW_NUM >> 1;
//assign JUMP_ONE_IMAGE = (ROW_NUM << 2) + (ROW_NUM << 4);

reg       [2:0]     current_state, next_state, current_state_dly1,current_state_dly2;
reg    [ADDR_WIDTH-1:0]      wr_start_addr;
reg    [ADDR_WIDTH-1:0]      rd_start_addr;


reg                          rd_addr_en;
//wire   [7:0]                 rx_buf_data;
reg    [511:0]               wr2ddr_data;
//reg                          wr_row_done;
reg    [10:0]                wr_ddr_row_cnt;
reg                          wr_image_done;
reg    [11:0]                frame_cnt;
reg    [5:0]                 cnt8to512;
reg                          app_en_dly1;
reg                          app_en_dly2;

reg    [9:0]                 wr_data_cnt;
wire                         rd_row_done;
wire                         rd_image_done;
reg    [5:0]                 rd_cmd_cnt;
reg    [10:0]                rd_ddr_row_cnt;
reg    [5:0]                 wr_cmd_cnt;

reg    [3:0]                 rd4lb_cnt;

//*************************************
// post DDR signals
//************************************
//wire                         post_ddr_ram_full_dly2;
reg    [4:0]                 cnt_512to24;

reg [ADDR_WIDTH-1:0]   wr_app_addr_base;
reg [ADDR_WIDTH-1:0]   rd_app_addr_base;
reg [ADDR_WIDTH-1:0]   wr_app_addr_offset;
reg [ADDR_WIDTH-1:0]   rd_app_addr_offset;

reg                    post_ddr_ram_full_dly1, post_ddr_ram_full_dly2;



assign         app_wdf_mask = 0;


//  deal with cross clock domain signal
always @(posedge clk)
begin
  if(rst)
  begin
  	post_ddr_ram_full_dly1 <= # DLY 1'b0;
  	post_ddr_ram_full_dly2 <= # DLY 1'b0;
  end
  else
  begin
  	post_ddr_ram_full_dly1 <= # DLY post_ddr_ram_full;
  	post_ddr_ram_full_dly2 <= # DLY post_ddr_ram_full_dly1;
  end
    
end


always @(posedge clk)
begin
  if(rst)
    current_state <= # DLY  IDLE;
  else
    current_state <= # DLY  next_state;
end

always @(posedge clk)
begin
  if(rst)
    begin
      current_state_dly1 <= # DLY  IDLE;
      current_state_dly2 <= # DLY  IDLE;
    end
  else
    begin
      current_state_dly1 <= # DLY  current_state;
      current_state_dly2 <= # DLY  current_state_dly1;
    end
end

/*
localparam    IDLE = 0,
              WR_DATA = 1,
              RD_DATA2TREE = 2,
              RD_DATA2LB = 3,
              POST_DDR_RAM_FULL = 4,
              LB_RAM_FULL = 5;
*/


always @( * )
begin
	case(current_state)
		IDLE:       if(init_calib_complete == 1'b1 && pkt_ready == 1'b1) //give priority to WRITE DDR, then READ DDR
		              next_state = WR_DATA;
		            else
		                if(frame_cnt >  12'b0)
		                  if(LB_EN == 1'b1)
		                    next_state = RD_DATA2LB;
		                  else
		                    next_state = RD_DATA2TREE;
		                else
		                  next_state = IDLE;
	  
	  WR_DATA:    if(wr_row_done == 1'b1)
	                next_state = IDLE;
	              else
	                next_state = WR_DATA;
	                
	  RD_DATA2TREE:    if(post_ddr_ram_full_dly2 == 1'b1)
//	                     next_state = POST_DDR_RAM_FULL;
                       next_state = IDLE;
	                   else
//     	                 if(rd_cmd_cnt == (WR_ROW2DDR_CNT-1'b1) && (current_state == RD_DATA2TREE && app_en == 1'b1 && app_rdy == 1'b1) && rd_ddr_row_cnt == (ROW_NUM_DIV2 - 1))
                       if(rd_cmd_cnt == (WR_ROW2DDR_CNT-1'b1) && (current_state == RD_DATA2TREE && app_en == 1'b1 && app_rdy == 1'b1))
	                       next_state = IDLE;
	                     else
	                       next_state = RD_DATA2TREE;
	                  
	  RD_DATA2LB:  if(lb_ram_full == 1'b1)
//	                 next_state = LB_RAM_FULL;
	                 next_state = IDLE;
	               else
//	                 if(rd_cmd_cnt == (WR_ROW2DDR_CNT-1'b1) && (current_state == RD_DATA2LB && app_en == 1'b1 && app_rdy == 1'b1) && rd_ddr_row_cnt == (ROW_NUM_DIV2 - 1))
	                 if(rd_cmd_cnt == (WR_ROW2DDR_CNT-1'b1) && (current_state == RD_DATA2LB && app_en == 1'b1 && app_rdy == 1'b1))
	                   next_state = IDLE;
	                 else
	                   next_state = RD_DATA2LB;
	                 
	  POST_DDR_RAM_FULL:   if(post_ddr_ram_full_dly2 == 1'b0)
	                         next_state = RD_DATA2TREE;
	                       else
	                         next_state = POST_DDR_RAM_FULL;
	  
	  LB_RAM_FULL:   if(lb_ram_full == 1'b0)
	                   next_state = RD_DATA2LB;
	                 else
	                   next_state = LB_RAM_FULL;
	  default:    next_state = IDLE;
	endcase
end



//*********  rd pre-DDR ram signals ********************
always @(posedge clk)
begin
  if(rst)
    cnt8to512 <= # DLY  6'b0;
  else
    if(current_state == WR_DATA)
      if(cnt8to512 == 6'd63 && app_rdy == 1'b0)
        cnt8to512 <= # DLY  cnt8to512;
      else
        cnt8to512 <= # DLY  cnt8to512 + 1'b1;
    else
      cnt8to512 <= # DLY  6'b0;
end

always @(posedge clk)
begin
  if(rst)
    rd_addr_buf <= # DLY  11'b0;
  else
    if(current_state == WR_DATA)
      if((cnt8to512 == 6'd63 && app_rdy == 1'b0) || wr_row_done == 1'b1)
        rd_addr_buf <= # DLY  rd_addr_buf;
      else
        rd_addr_buf <= # DLY  rd_addr_buf + 1'b1;
    else;
end


always @(posedge clk)
begin
  if(rst)
    rd_addr_en <= # DLY  11'b0;
  else
    if(current_state == WR_DATA)
      if((cnt8to512 == 6'd63 && app_rdy == 1'b0) || wr_row_done == 1'b1)
        rd_addr_en <= # DLY  1'b0;
      else
        rd_addr_en <= # DLY  1'b1;
    else;
end

//*********** DDR command interface ****************

assign  app_cmd = (current_state == RD_DATA2TREE || current_state == RD_DATA2LB )? 1'b1:1'b0;
assign  app_en = ((current_state == WR_DATA && cnt8to512 == 6'd63 && app_rdy == 1'b1) ||
                 (((current_state == RD_DATA2TREE && post_ddr_ram_full_dly2 == 1'b0) || (current_state == RD_DATA2LB && lb_ram_full == 1'b0)) && app_rdy == 1'b1 ))? 1'b1:1'b0;

always @(posedge clk)
begin
  if(rst)
    begin
    	app_en_dly1 <= # DLY  1'b0;
    	app_en_dly2 <= # DLY  1'b0;
    end
  else
    begin
    	app_en_dly1 <= # DLY  app_en;
    	app_en_dly2 <= # DLY  app_en_dly1;
    end

end

/************************************************************
    manage app_addr control

*************************************************************/
//always @(posedge clk)
//begin
//  if(rst)
//    app_addr <= # DLY  'd0;
//  else
//    case(current_state)
//      IDLE:         if(wr_image_done == 1'b1)
//                      app_addr <= # DLY  'd0;
//                    else
//                      app_addr <= # DLY  app_addr;
//    	WR_DATA:      //if(wr_image_done == 1'b1)
//                    //  app_addr <= # DLY  rd_start_addr;
//    	              //else
//    	                if(app_rdy == 1'b1 && app_en == 1'b1)
//    	                  app_addr <= # DLY  app_addr + 'd8;
//                      else
//                        app_addr <= # DLY  app_addr;
//
//      RD_DATA2TREE:
//                      if(app_rdy == 1'b1 && app_en == 1'b1)
//    	                  app_addr <= # DLY  app_addr + 'd8;
//                      else
//                        app_addr <= # DLY  app_addr;
//      RD_DATA2LB:
//                      if(app_rdy == 1'b1 && app_en == 1'b1)
//    	                  app_addr <= # DLY  app_addr + 'd8;
//                      else
//                        app_addr <= # DLY  app_addr;
//                                         
//      POST_DDR_RAM_FULL:       app_addr <= # DLY  app_addr;
//      
//      LB_RAM_FULL:             app_addr <= # DLY  app_addr;
//      default:      app_addr <= # DLY  'd0;
//    endcase
//end

//  for write ddr side
always @(posedge clk)
begin
  if(rst)
    wr_app_addr_offset <= # DLY  'b0;
  else
    if(current_state == WR_DATA && app_rdy == 1'b1 && app_en == 1'b1)
      if(wr_cmd_cnt == (WR_ROW2DDR_CNT - 1'b1) && wr_ddr_row_cnt == (ROW_NUM_DIV2-1))
        wr_app_addr_offset <= # DLY  'b0;
      else
        wr_app_addr_offset <= # DLY  wr_app_addr_offset + 'd8;
    else;    
end

always @(posedge clk)
begin
  if(rst)
    wr_app_addr_base <= # DLY  'b0;
  else
    if(current_state == WR_DATA && app_rdy == 1'b1 && app_en == 1'b1 && wr_cmd_cnt == (WR_ROW2DDR_CNT - 1'b1) && wr_ddr_row_cnt == (ROW_NUM_DIV2-1))
      wr_app_addr_base <= # DLY  wr_app_addr_base + JUMP_ONE_IMAGE;
    else;
end

//  for read ddr side
always @(posedge clk)
begin
  if(rst)
    rd_app_addr_offset <= # DLY  'b0;
  else
    if((current_state == RD_DATA2TREE || current_state == RD_DATA2LB )&& app_rdy == 1'b1 && app_en == 1'b1)
      if(rd_cmd_cnt == (WR_ROW2DDR_CNT - 1'b1) && rd_ddr_row_cnt == (ROW_NUM_DIV2-1))
        rd_app_addr_offset <= # DLY  'b0;
      else
        rd_app_addr_offset <= # DLY  rd_app_addr_offset + 'd8;
    else;    
end

always @(posedge clk)
begin
  if(rst)
    rd_app_addr_base <= # DLY  'b0;
  else
    if((current_state == RD_DATA2TREE || current_state == RD_DATA2LB ) && app_rdy == 1'b1 && app_en == 1'b1 && rd_cmd_cnt == (WR_ROW2DDR_CNT - 1'b1) && rd_ddr_row_cnt == (ROW_NUM_DIV2-1))
      rd_app_addr_base <= # DLY  rd_app_addr_base + JUMP_ONE_IMAGE;
    else;
end

always @ *
begin
    case(current_state)
    	WR_DATA:          app_addr <= # DLY  wr_app_addr_base + wr_app_addr_offset;

      RD_DATA2TREE:     app_addr <= # DLY  rd_app_addr_base + rd_app_addr_offset;
                      
      RD_DATA2LB:       app_addr <= # DLY  rd_app_addr_base + rd_app_addr_offset;

      default:          app_addr <= # DLY  app_addr;
    endcase
end

//***************************************

always @(posedge clk)
begin
  if(rst)
    wr_image_done <= # DLY  1'b0;
  else
    if((wr_ddr_row_cnt == (ROW_NUM_DIV2-1)) && wr_row_done == 1'b1)
      wr_image_done <= # DLY  1'b1;
    else
      wr_image_done <= # DLY  1'b0;
end


assign rd_image_done = (rd_cmd_cnt == (WR_ROW2DDR_CNT-1'b1) && 
                        ((current_state == RD_DATA2TREE || current_state == RD_DATA2LB) && app_en == 1'b1 && app_rdy == 1'b1) && 
                        rd_ddr_row_cnt == (ROW_NUM_DIV2 - 1))? 1'b1 : 1'b0;

always @(posedge clk)
begin
  if(rst)
    frame_cnt <= # DLY  12'b0;
  else
    case({wr_image_done, rd_image_done})
    	2'b10: frame_cnt <= # DLY  frame_cnt + 1'b1;
    	2'b01: frame_cnt <= # DLY  frame_cnt - 1'b1;
    	
    	default: frame_cnt <= # DLY  frame_cnt;
    endcase
end


always @(posedge clk)
begin
  if(rst)
    wr_ddr_row_cnt <= # DLY  11'b0;
  else
    if(wr_row_done == 1'b1)
      if(wr_ddr_row_cnt == (ROW_NUM_DIV2-1))
        wr_ddr_row_cnt <= # DLY  11'b0;
      else
        wr_ddr_row_cnt <= # DLY  wr_ddr_row_cnt + 1'b1;
    else;
end


//************DDR3 data path ****************
assign app_wdf_wren = (current_state_dly2 == WR_DATA)? app_en_dly2:1'b0;


always @(posedge clk)
begin
  if(rst)
    wr2ddr_data <= # DLY  512'b0;
  else
    	if(rd_addr_en == 1'b1)
    	begin
    	  wr2ddr_data[7:0] <= # DLY  rx_buf_data;
    	  wr2ddr_data[511:8] <= # DLY  wr2ddr_data[503:0];
    	end
    	else;
end

always @(posedge clk)
begin
  if(rst)
    app_wdf_end <= # DLY  1'b0;
  else
    if(current_state == WR_DATA)
      app_wdf_end <= # DLY  1'b1;
    else
      app_wdf_end <= # DLY  1'b0;
end

assign   app_wdf_data = wr2ddr_data;


always @(posedge clk)
begin
  if(rst)
    wr_data_cnt <= # DLY  10'b0;
  else
    if(app_wdf_rdy && app_wdf_wren)
      wr_data_cnt <= # DLY  wr_data_cnt + 1'b1;
    else;
end


always @(posedge clk)
begin
  if(rst)
    wr_cmd_cnt <= # DLY  6'b0;
  else
    if(current_state == WR_DATA && app_en == 1'b1 && app_rdy == 1'b1)
      if(wr_cmd_cnt == (WR_ROW2DDR_CNT - 1'b1))
        wr_cmd_cnt <= # DLY  6'b0;
      else
        wr_cmd_cnt <= # DLY  wr_cmd_cnt + 1'b1;
    else
      if(current_state != WR_DATA)
        wr_cmd_cnt <= # DLY  6'b0;
      else;
end

always @(posedge clk)
begin
  if(rst)
    wr_row_done <= # DLY  1'b0;
  else
    if(wr_cmd_cnt == (WR_ROW2DDR_CNT - 1'b1) && (current_state == WR_DATA && app_en == 1'b1 && app_rdy == 1'b1))
      wr_row_done <= # DLY  1'b1;
    else
      wr_row_done <= # DLY  1'b0;
end


//************************************
//  read DDR signals
//************************************

always @(posedge clk)
begin
  if(rst)
    rd_cmd_cnt <= # DLY  4'b0;
  else
    if((current_state == RD_DATA2TREE || current_state == RD_DATA2LB)&& app_en == 1'b1 && app_rdy == 1'b1)
      if(rd_cmd_cnt == (WR_ROW2DDR_CNT - 1'b1))
        rd_cmd_cnt <= # DLY  4'b0;
      else
        rd_cmd_cnt <= # DLY  rd_cmd_cnt + 1'b1;
    else;
end

assign rd_row_done = (rd_cmd_cnt == (WR_ROW2DDR_CNT-1'b1) && ((current_state == RD_DATA2TREE || current_state == RD_DATA2LB) && app_en == 1'b1 && app_rdy == 1'b1))? 1'b1:1'b0;
always @(posedge clk)
begin
  if(rst)
    rd_ddr_row_cnt <= # DLY  11'b0;
  else
    if(rd_cmd_cnt == (WR_ROW2DDR_CNT-1'b1) && ((current_state == RD_DATA2TREE || current_state == RD_DATA2LB) && app_en == 1'b1 && app_rdy == 1'b1))
      if(rd_ddr_row_cnt == (ROW_NUM_DIV2 - 1))
        rd_ddr_row_cnt <= # DLY  11'b0;
      else
        rd_ddr_row_cnt <= # DLY  rd_ddr_row_cnt + 1'b1;
    else;
end


//post_ddr_buf u_post_ddr_buf(
//                             .clk               (clk),
//                             .rst               (rst),
//                             .image_clk         (rx_fifo_clock),
//                             .image_rst         (~rx_fifo_resetn),
//                             .app_rd_data       (app_rd_data),
//                             .app_rd_data_valid (app_rd_data_valid),
//                             .app_rdy           (app_rdy),                         
//                             .app_cmd           (app_cmd), 
//                             .app_en            (app_en),  
//                             .data4sr           (data4sr),
//                             .data4sr_valid     (data4sr_valid    ),
//                             .post_ddr_ram_full_dly2 (post_ddr_ram_full_dly2)
//                           );


//loop_back u_loop_back (
//                       .clk               (clk),
//                       .rst               (rst),
//                       .image_clk         (rx_fifo_clock),
//                       .image_rst         (~rx_fifo_resetn),                      
//                       .ddr_rden          (ddr_rden   ),                      
//                       .data4sr           (data4sr),
//                       .data4sr_valid     (data4sr_valid    ),
//                       .pkt_ready         (lb_pkt_ready),
//                       .data2ddr          (lp_data)
//                      );

endmodule