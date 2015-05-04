/*



*/


module result_buf #(
                    parameter   LineNumber = 36
                    )
                 (
                  input              clk               ,    
                  input              rst              ,    
                  input              valid    ,    
                  input   [7:0]      data_in       ,    
                  input              rd_row_data_done  ,    
                  input   [4:0]      rd_addr           ,
                        
                  output  [511:0]      rd_data           ,
                  output             pkt_ready         ,               
                  output             result_buf_full                       
                  
                  );

localparam   IDLE = 0,
             RD_DATA = 1,
             PAUSE = 2;

//localparam   TWO_ROW_CNT = 7; // 1280x3/512 = 7.5
localparam   TWO_ROW_CNT = 4;  // read two lines of image from DDR3 need 5 times of read operation   modified at 2014/11/18 15:59:21

localparam   DLY = 1000;


reg    [5:0]cnt8to512;
reg         wr_en;
reg  [511:0]wr_data;
reg    [2:0]wr_en_cnt;
reg    [4:0]wr_addr;
reg         wr_en_done;
reg    [2:0]ram_pkt_cnt;


always @(posedge clk)
begin
  if(rst)
    wr_data <= 512'b0;
  else
    if(valid == 1'b1)
    begin
    	wr_data[7:0] <= data_in;
    	wr_data[511:8] <= wr_data[503:0];
    end
    else;
end

always @(posedge clk)
begin
  if(rst)
    cnt8to512 <= 6'b0;
  else
    if(valid == 1'b1)
      cnt8to512 <= cnt8to512 + 1'b1;
    else;
end

always @(posedge clk)
begin
  if(rst)
    wr_en <= 1'b0;
  else
    if(cnt8to512 == 6'd63)
      wr_en <= 1'b1;
    else
      wr_en <= 1'b0;
end

always @(posedge clk)
begin
  if(rst)
    wr_addr <= 5'b0;
  else
    if(wr_en == 1'b1)
      wr_addr <= wr_addr + 1'b1;
    else;
end

always @(posedge clk)
begin
  if(rst)
    wr_en_cnt <= 3'b0;
  else
    if(wr_en == 1'b1)
      if(wr_en_cnt == TWO_ROW_CNT)
        wr_en_cnt <= 3'b0;
      else
        wr_en_cnt <= wr_en_cnt + 1'b1;
    else;
end

always @(posedge clk)
begin
  if(rst)
    wr_en_done <= 1'b0;
  else
    if(wr_en == 1'b1 && wr_en_cnt == TWO_ROW_CNT)
        wr_en_done <= 1'b1;
    else
        wr_en_done <= 1'b0;
end


post_ddr_ram u_tx_ram(          //depth 32, width 512bit
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
    ram_pkt_cnt <= 3'b0;
  else
    case({wr_en_done,rd_row_data_done})
    	2'b01:    ram_pkt_cnt <= ram_pkt_cnt - 1'b1;
    	2'b10:    ram_pkt_cnt <= ram_pkt_cnt + 1'b1;
      default:  ram_pkt_cnt <= ram_pkt_cnt;
    endcase
end

assign result_buf_full = (ram_pkt_cnt > 2'd2)? 1'b1:1'b0;
assign pkt_ready = (ram_pkt_cnt > 2'd0)? 1'b1:1'b0;


endmodule