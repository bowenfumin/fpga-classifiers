/*






*/

`timescale 1ps/1ps

module  loopback_blk (
                  input                 clk,
                  input                 rst,
                  input                 image_clk,
                  input                 image_rst,
                  input      [511:0]    app_rd_data,
                  input                 app_rd_data_valid ,
                  input                 app_rdy ,                        
                  input     [2:0]       app_cmd ,
                  input                 app_en  ,
                  input                 rd_row_data_done,
                  input     [4:0]       rd_addr,
                  
                  output      [511:0]   rd_data,
                  output                pkt_ready,                      
                  output                loopback_buf_full
                  );

localparam   IDLE = 0,
             RD_DATA = 1,
             PAUSE = 2;

//localparam   TWO_ROW_CNT = 7; // 1280x3/512 = 7.5
localparam   TWO_ROW_CNT = 4;  // read two lines of image from DDR3 need 5 times of read operation   modified at 2014/11/18 15:59:21

localparam   DLY = 1000;

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

reg     [1:0] ram_pkt_num_cmd;




always @(posedge clk)
begin
  if(image_rst)
    wr_en <= #DLY 1'b0;
  else
    wr_en <= #DLY app_rd_data_valid;
end

always @(posedge clk)
begin
  if(rst)
    wr_addr <= #DLY 5'b0;
  else
    if(wr_en == 1'b1)
      wr_addr <= #DLY wr_addr + 1'b1;
    else;
end

always @(posedge clk)
begin
  if(rst)
    wr_data <= #DLY 512'b0;
  else
    wr_data <= #DLY app_rd_data;
end

always @(posedge clk)
begin
  if(rst)
    wr_en_cnt <= #DLY 4'b0;
  else
    if(wr_en == 1'b1)
      if(wr_en_cnt == TWO_ROW_CNT)
        wr_en_cnt <= #DLY 4'b0;
      else
        wr_en_cnt <= #DLY wr_en_cnt + 1'b1;
    else; 
end

always @(posedge clk)
begin
  if(rst)
    wr_en_done <= #DLY 1'b0;
  else
    if(wr_en == 1'b1 && wr_en_cnt == TWO_ROW_CNT)
      wr_en_done <= #DLY 1'b1;
    else
      wr_en_done <= #DLY 1'b0;
end

always @(posedge clk)
begin
  if(rst)
    wr_en_done_dly1 <= #DLY 1'b0;
  else
    wr_en_done_dly1 <= #DLY wr_en_done;
end

assign wr_en_done2ram = (wr_en_done | wr_en_done_dly1);

//*************************
// control ram_full signal
//*************************
always @(posedge clk)
begin
  if(rst)
    rd_ddr_cnt <= #DLY 4'b0;
  else
    if(app_cmd == 3'd1 && app_en == 1'b1 && app_rdy == 1'b1)
      if(rd_ddr_cnt == TWO_ROW_CNT)
        rd_ddr_cnt <= #DLY 4'b0;
      else
        rd_ddr_cnt <= #DLY rd_ddr_cnt + 1'b1;
    else; 
end

always @(posedge clk)
begin
  if(rst)
    req_row_data_done <= #DLY 1'b0;
  else
    if(app_cmd == 3'd1 && app_en == 1'b1 && app_rdy == 1'b1 && rd_ddr_cnt == TWO_ROW_CNT)
      req_row_data_done <= #DLY 1'b1;
    else
      req_row_data_done <= #DLY 1'b0;
end

always @(posedge clk)
begin
  if(rst)
    req_row_data_done_dly1 <= #DLY 1'b0;
  else
    req_row_data_done_dly1 <= #DLY req_row_data_done;
end

assign req_row_data_done2ram = (req_row_data_done | req_row_data_done_dly1);

post_ddr_ram u_tx_ram(          //depth 32, width 512bit
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
    wr_en_done2ram_dly1 <= #DLY 1'b0;
  else
    wr_en_done2ram_dly1 <= #DLY wr_en_done2ram;
end

always @(posedge image_clk)
begin
  if(image_rst)
    wr_en_done2ram_dly2 <= #DLY 1'b0;
  else
    wr_en_done2ram_dly2 <= #DLY wr_en_done2ram_dly1;
end


always @(posedge image_clk)
begin
  if(image_rst)
    wr_en_done2ram_dly3 <= #DLY 1'b0;
  else
    wr_en_done2ram_dly3 <= #DLY wr_en_done2ram_dly2;
end


assign wr_en_done_detect = (wr_en_done2ram_dly2 == 1'b1 && wr_en_done2ram_dly3 == 1'b0)? 1'b1:1'b0;

always @(posedge image_clk)
begin
  if(image_rst)
    ram_pkt_num_data <= #DLY 2'b0;
  else
    case({wr_en_done_detect,rd_row_data_done})
    	2'b10:    ram_pkt_num_data <= #DLY ram_pkt_num_data + 1'b1;
    	2'b01:    ram_pkt_num_data <= #DLY ram_pkt_num_data - 1'b1;
    	default:  ram_pkt_num_data <= #DLY ram_pkt_num_data;
    endcase
end
//for req_row_data_detect

always @(posedge image_clk)
begin
  if(image_rst)
    req_row_data_done2ram_dly1 <= #DLY 1'b0;
  else
    req_row_data_done2ram_dly1 <= #DLY req_row_data_done2ram;
end

always @(posedge image_clk)
begin
  if(image_rst)
    req_row_data_done2ram_dly2 <= #DLY 1'b0;
  else
    req_row_data_done2ram_dly2 <= #DLY req_row_data_done2ram_dly1;
end


always @(posedge image_clk)
begin
  if(image_rst)
    req_row_data_done2ram_dly3 <= #DLY 1'b0;
  else
    req_row_data_done2ram_dly3 <= #DLY req_row_data_done2ram_dly2;
end

always @(posedge image_clk)
begin
  if(image_rst)
    req_row_data_done_detect <= #DLY 1'b0;
  else
    if(req_row_data_done2ram_dly2 == 1'b1 && req_row_data_done2ram_dly3 == 1'b0)
      req_row_data_done_detect <= #DLY 1'b1;
    else
      req_row_data_done_detect <= #DLY 1'b0;
end


always @(posedge image_clk)
begin
  if(image_rst)
    ram_pkt_num_cmd <= #DLY 2'b0;
  else
    case({req_row_data_done_detect,rd_row_data_done})
    	2'b10:    ram_pkt_num_cmd <= #DLY ram_pkt_num_cmd + 1'b1;
    	2'b01:    ram_pkt_num_cmd <= #DLY ram_pkt_num_cmd - 1'b1;
    	default:  ram_pkt_num_cmd <= #DLY ram_pkt_num_cmd;
    endcase
end

assign loopback_buf_full = (ram_pkt_num_cmd > 2'd1)? 1'b1:1'b0;
assign pkt_ready = (ram_pkt_num_data > 2'd0)? 1'b1:1'b0;


endmodule