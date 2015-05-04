/*



*/

`timescale 1ps/1ps

module result_buf #(
                    parameter   LineNumber = 36
                    )
                 (
                  input              clk               ,    
                  input              rst              ,    
                  input              valid    ,    
                  input   [7:0]      data_in       ,    
                  input              rd_row_data_done  ,    
                  input              rd_en,
                  input   [12:0]      rd_addr           ,
                        
                  output  [7:0]      rd_data           ,
                  output             pkt_ready         ,
                  output             debug_result_buf,               
                  output             result_buf_full                       
                  
                  );


localparam   PKT_CNT = 1256;  // when small window move along the line, the number of result it gives is: 1280-24 = 1256

localparam   DLY = 1000;


reg    [5:0]cnt8to512;
reg         wr_en;
reg    [7:0]wr_data;
reg    [10:0]wr_en_cnt;
reg    [12:0]wr_addr;
reg         wr_en_done;
reg    [2:0]ram_pkt_cnt;


always @(posedge clk)
begin
  if(rst)
    wr_data <= #DLY  8'b0;
  else
    if(valid == 1'b1)
    	wr_data  <= #DLY  data_in;
    else;
end


always @(posedge clk)
begin
  if(rst)
    wr_en <= #DLY  1'b0;
  else
    if(valid == 1'b1)
      wr_en <= #DLY  1'b1;
    else
      wr_en <= #DLY  1'b0;
end

always @(posedge clk)
begin
  if(rst)
    wr_addr <= #DLY  13'b0;
  else
    if(wr_en == 1'b1)
      wr_addr <= #DLY  wr_addr + 1'b1;
    else;
end

always @(posedge clk)
begin
  if(rst)
    wr_en_cnt <= #DLY  11'b0;
  else
    if(wr_en == 1'b1)
      if(wr_en_cnt == PKT_CNT)
        wr_en_cnt <= #DLY  11'b0;
      else
        wr_en_cnt <= #DLY  wr_en_cnt + 1'b1;
    else;
end

always @(posedge clk)
begin
  if(rst)
    wr_en_done <= #DLY  1'b0;
  else
    if(wr_en == 1'b1 && wr_en_cnt == PKT_CNT)
        wr_en_done <= #DLY  1'b1;
    else
        wr_en_done <= #DLY  1'b0;
end


tx_result_ram u_tx_result_ram(          //depth 8192, width 8bit
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
    ram_pkt_cnt <= #DLY  3'b0;
  else
    case({wr_en_done,rd_row_data_done})
    	2'b01:    ram_pkt_cnt <= #DLY  ram_pkt_cnt - 1'b1;
    	2'b10:    ram_pkt_cnt <= #DLY  ram_pkt_cnt + 1'b1;
      default:  ram_pkt_cnt <= #DLY  ram_pkt_cnt;
    endcase
end

assign result_buf_full = (ram_pkt_cnt >= 2'd2)? 1'b1:1'b0;
assign pkt_ready = (ram_pkt_cnt > 2'd0)? 1'b1:1'b0;


//for debuggin
reg  [31:0] cnt_wr;
reg  [31:0] cnt_rd;
(*S="TRUE"*)reg         wr_overflow;
(*S="TRUE"*)reg         rd_through;


always @(posedge clk)
begin
  if(rst)
    cnt_wr <= #DLY 32'b0;
  else
    if(wr_en == 1'b1 && wr_addr == 'd8191)
      cnt_wr <= #DLY cnt_wr + 1'b1;
    else;
end

always @(posedge clk)
begin
  if(rst)
    cnt_rd <= #DLY 32'b0;
  else
    if(rd_en == 1'b1 && rd_addr == 'd8191)
      cnt_rd <= #DLY cnt_rd + 1'b1;
    else;
end

always @(posedge clk)
begin
  if(rst)
    wr_overflow <= #DLY  1'b0;
  else
    if(wr_addr > rd_addr && cnt_wr > cnt_rd)
      wr_overflow <= #DLY 1'b1;
    else
      wr_overflow <= #DLY  1'b0;
end

always @(posedge clk)
begin
  if(rst)
    rd_through <= #DLY 1'b0;
  else
    if(rd_addr > wr_addr && cnt_rd == cnt_wr)
      rd_through <= #DLY 1'b1;
    else
      rd_through <= #DLY 1'b0;
end

assign debug_result_buf = wr_overflow || rd_through;

endmodule