/*



*/
`timescale 1ps / 1ps

`include "../../src/include/defines.v"

module image_top #(

    parameter ADDR_WIDTH            = 28,  
    parameter DATA_WIDTH            = 512,
    parameter IMAGE_LINE_NUM        = 720
    )

                 (
                   input                      clk,
                   input                      rst,
                   input                      init_calib_complete,
                   
                   input                          app_rdy ,
                   output      [ADDR_WIDTH-1:0]   app_addr,         
                   output      [2:0]              app_cmd ,
                   output                         app_en  ,
                   
                   input                      app_wdf_rdy       ,          
                   output  [DATA_WIDTH-1:0]   app_wdf_data      ,
                   output  [DATA_WIDTH-1:0]   app_wdf_mask      ,
                   output                     app_wdf_end       ,
                   output                     app_wdf_wren      ,
                   input   [DATA_WIDTH-1:0]   app_rd_data       ,
                   input                      app_rd_data_end   ,
                   input                      app_rd_data_valid ,
                  
                  input          rx_fifo_clock     ,
                  input          rx_fifo_resetn    , 
                  input          clk_62p5          ,                              
                  input    [7:0] rx_axis_tdata  ,
                  input          rx_axis_tvalid ,
                  input          rx_axis_tlast  ,
                  input          rx_axis_tuser  ,
                  
                  input              tx_axis_tready ,                 
                  output  [7:0]      tx_axis_tdata  , 
                  output             tx_axis_tvalid ,                    
                  output             tx_axis_tlast  ,    
                  
                  output              rx_axis_tready,
                  output              debug_sig
                  );
// sync the two resets


localparam   Packet_len = 160*9+4;
`ifdef  LoopBack
localparam   LB_EN = 1'b1;

`else
localparam   LB_EN = 1'b0;
`endif


wire    image_block_rst_init;
reg     image_block_pre_rst;
reg     image_block_rst;

wire    ddr_rst_init;
reg     ddr_pre_rst;
reg     ddr_rst;
wire    [1:0] data4sr;
wire          data4sr_valid;
wire          post_ddr_ram_full;
wire          valid4tree_reg;
wire    [7:0] clsf_result;

wire          wr_row_done;
wire    [10:0] rd_addr_buf;
wire          pkt_ready;
wire    [7:0] rx_buf_data;

wire          tx_buf_full;

wire          rx_frame_pause_req;
wire  [15:0]  rx_frame_req_pausetime;
wire  [4:0]   rd_addr_loopback;
wire          rd_row_data_done_loopback;
wire  [511:0] rd_data_loopback;
wire          pkt_ready_loopback;
wire  [12:0]  rd_addr_result;
wire  [7:0]   rd_data_result;
wire          pkt_ready_result;
wire          rd_row_data_done_result;
wire  [12:0]   rd_addr_tx;  
wire  [7:0]   rd_data_tx;  
wire          pkt_ready_tx;
wire          rd_row_data_done_tx;
wire          rd_en;
wire          rx_buf_error;
wire          debug_result_buf;

assign debug_sig = rx_buf_error || debug_result_buf;
`ifdef  LoopBack
assign rd_addr_loopback = rd_addr_tx;
assign rd_row_data_done_loopback = rd_row_data_done_tx;
assign rd_data_tx = rd_data_loopback;
assign pkt_ready_tx = pkt_ready_loopback;
`else
assign rd_addr_result = rd_addr_tx;
assign rd_row_data_done_result = rd_row_data_done_tx;
assign rd_data_tx = rd_data_result;
assign pkt_ready_tx = pkt_ready_result;
`endif



//*************************
// create sync reset 
//*************************
   eth_reset_sync image_reset_gen (
      .clk              (rx_fifo_clock),
      .enable           (init_calib_complete),
      .reset_in         (~rx_fifo_resetn),
      .reset_out        (image_block_rst_init)
   );
   // Create fully synchronous reset in the gtx_clk domain.
   always @(posedge rx_fifo_clock)
   begin
     if (image_block_rst_init) begin
       image_block_pre_rst  <= 1;
       image_block_rst      <= 1;
     end
     else begin
       image_block_pre_rst  <= 0;
       image_block_rst      <= image_block_pre_rst;
     end
   end
   
   eth_reset_sync ddr_reset_gen (
      .clk              (clk),
      .enable           (init_calib_complete),
      .reset_in         (rst),
      .reset_out        (ddr_rst_init)
   );
   // Create fully synchronous reset in the gtx_clk domain.
   always @(posedge clk)
   begin
     if (ddr_rst_init) begin
       ddr_pre_rst  <= 1;
       ddr_rst      <= 1;
     end
     else begin
       ddr_pre_rst  <= 0;
       ddr_rst      <= ddr_pre_rst;
     end
   end


    rx_buf  #(
                 .Packet_len (Packet_len)
                )

                u_rx_buf           
                  (
                  .clk                 (clk), // 200MHz
                  .rst                 (rst),
                  .rd_addr             (rd_addr_buf),
                  .rd_row_done         (wr_row_done),
                  .init_calib_complete (init_calib_complete),
                  .pkt_ready           (pkt_ready),
                  .rd_data_out         (rx_buf_data), // data to be written into ddr
                  
                  .rx_fifo_clock                (rx_fifo_clock ),  //125MHz
                  .rx_fifo_resetn               (rx_fifo_resetn),
                  .rx_axis_tdata                (rx_axis_tdata),
                  .rx_axis_tvalid               (rx_axis_tvalid),
                  .rx_axis_tlast                (rx_axis_tlast),
                  .rx_axis_tready               (rx_axis_tready ),
                  .rx_frame_pause_req           (rx_frame_pause_req),
                  .rx_frame_req_pausetime       (rx_frame_req_pausetime),
                  .error1                       (rx_buf_error) //debug_sig) 
                  );


   tx_buf u_tx_buf(
                             .clk                    (clk                   ),
                             .rst                    (ddr_rst || ~LB_EN     ),
                             .image_clk              (rx_fifo_clock         ),
                             .image_rst              (image_block_rst       ), 
                             .rx_frame_pause_req     (rx_frame_pause_req    ),
                             .rx_frame_req_pausetime (rx_frame_req_pausetime),
                             .tx_axis_tdata          (tx_axis_tdata         ),
                             .tx_axis_tvalid         (tx_axis_tvalid        ),
                             .tx_axis_tlast          (tx_axis_tlast         ),
                             .tx_axis_tready         (tx_axis_tready        ),
                             .rd_row_data_done       (rd_row_data_done_tx   ),
                             .rd_en                  (rd_en                 ),                          
                             .rd_addr                (rd_addr_tx            ),
                             .rd_data                (rd_data_tx            ), 
                             .pkt_ready              (pkt_ready_tx          )
                           );
  
   loopback_blk u_loopback_blk(
                             .clk                    (clk                   ),
                             .rst                    (ddr_rst || ~LB_EN     ),
                             .image_clk              (rx_fifo_clock         ),
                             .image_rst              (image_block_rst       ),
                             .app_rd_data            (app_rd_data           ),
                             .app_rd_data_valid      (app_rd_data_valid     ),
                             .app_rdy                (app_rdy               ),                         
                             .app_cmd                (app_cmd               ), 
                             .app_en                 (app_en                ),  
                             .rd_row_data_done       (rd_row_data_done_loopback),
                             .rd_addr                (rd_addr_loopback      ),
                             .rd_data                (rd_data_loopback      ),
                             .pkt_ready              (pkt_ready_loopback    ),                            
                             .loopback_buf_full      (loopback_buf_full     )
                             
                             );


  memc_intf   #(

      .ADDR_WIDTH           (ADDR_WIDTH),
      .DATA_WIDTH           (DATA_WIDTH),
      .ROW_NUM              (IMAGE_LINE_NUM       ),
      .Packet_len           (Packet_len),    //  9*1280bit/8bit = 9*160bytes
      .LB_EN                (LB_EN     )
    )
    u_memc_intf   (
                   .clk                 (clk                 ),
                   .rst                 (ddr_rst             ),
                   .init_calib_complete (init_calib_complete ),  
                   .pkt_ready           (pkt_ready           ),
                   .rx_buf_data         (rx_buf_data         ),
                   .wr_row_done         (wr_row_done         ),                     
                   .rd_addr_buf         (rd_addr_buf         ),           
                   .app_rdy             (app_rdy             ),
                   .app_addr            (app_addr            ),
                   .app_cmd             (app_cmd             ),
                   .app_en              (app_en              ), 
                   .app_wdf_rdy         (app_wdf_rdy         ),               
                   .app_wdf_data        (app_wdf_data        ),
                   .app_wdf_end         (app_wdf_end         ),
                   .app_wdf_mask        (app_wdf_mask        ),
                   .app_wdf_wren        (app_wdf_wren        ),
                   .app_rd_data         (app_rd_data         ),
                   .app_rd_data_end     (app_rd_data_end     ),
                   .app_rd_data_valid   (app_rd_data_valid   ),
                   
                   .rx_fifo_clock                (rx_fifo_clock ),
                   .rx_fifo_resetn               (~image_block_rst),
                   .rx_axis_tdata                (rx_axis_tdata),
                   .rx_axis_tvalid               (rx_axis_tvalid),
                   .rx_axis_tlast                (rx_axis_tlast),
                  // .rx_axis_tready               (rx_axis_tready ),
                   
                   .data4sr                      (data4sr        ),
                   .data4sr_valid                (data4sr_valid  ),
                   .post_ddr_ram_full            (post_ddr_ram_full),
                   .lb_ram_full                  (loopback_buf_full      )
                  );   
   



`ifdef MoveBy1Pixel
  image_proc1px  #(
                .LineNumber(IMAGE_LINE_NUM)
                )
      u_image_proc (
      .clk                          (rx_fifo_clock            ),
      .rst                          (image_block_rst          ),
      .ddr_clk                      (clk            ),
      .ddr_rst                      (ddr_rst),
      .app_rd_data                  (app_rd_data),
      .app_rd_data_valid            (app_rd_data_valid),
      .app_rdy                      (app_rdy),                         
      .app_cmd                      (app_cmd), 
      .app_en                       (app_en),
      .rd_en                        (rd_en                 ),
      .rd_addr_result               (rd_addr_result        ),
      .rd_row_data_done             (rd_row_data_done_result),
      .post_ddr_ram_full            (post_ddr_ram_full),
      .rd_data_result               (rd_data_result        ),
      .debug_result_buf             (debug_result_buf      ),
      .pkt_ready_result             (pkt_ready_result      )
   );
`else
  image_proc2px  #(
                .LineNumber(IMAGE_LINE_NUM)
                )
      u_image_proc (
      .clk                          (rx_fifo_clock            ),
      .rst                          (image_block_rst          ),
      .ddr_clk                      (clk            ),
      .ddr_rst                      (ddr_rst),
      .app_rd_data                  (app_rd_data),
      .app_rd_data_valid            (app_rd_data_valid),
      .app_rdy                      (app_rdy),                         
      .app_cmd                      (app_cmd), 
      .app_en                       (app_en),
      .clsf_result0                 (clsf_result0),
      .clsf_result1                 (clsf_result1),
      .clsf_result2                 (clsf_result2),
      .clsf_result3                 (clsf_result3),
      .post_ddr_ram_full            (post_ddr_ram_full),
      .valid4tree_reg               (valid4tree_reg)
   );

`endif

   



endmodule