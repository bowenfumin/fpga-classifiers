/*



*/
`timescale 1ps / 1ps

module image_top #(

    parameter ADDR_WIDTH            = 28,  
    parameter DATA_WIDTH            = 512
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
                  output              clsf_result0,
                  output              clsf_result1,
                  output              clsf_result2,
                  output              clsf_result3,
                  output              rx_axis_tready 
                  );
// sync the two resets

wire    image_block_rst_init;
reg     image_block_pre_rst;
reg     image_block_rst;

wire    ddr_rst_init;
reg     ddr_pre_rst;
reg     ddr_rst;
wire    [5:0] data4sr;
wire          data4sr_valid;


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


  memc_intf   #(

      .ADDR_WIDTH           (ADDR_WIDTH),
      .DATA_WIDTH           (DATA_WIDTH),
      .Packet_len           (132)
    )
    u_memc_intf   (
                   .clk                 (clk                 ),
                   .rst                 (ddr_rst             ),
                   .init_calib_complete (init_calib_complete ),                
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
                   .rx_axis_tready               (rx_axis_tready ),
                   
                   .data4sr                      (data4sr        ),
                   .data4sr_valid                (data4sr_valid  )
                  );   
//**************************************************************************   

  image_proc  u_image_proc (
      .clk                          (rx_fifo_clock            ),
      .rst                          (image_block_rst          ),
      .data4sr                      (data4sr        ),
      .data4sr_valid                (data4sr_valid  ),
      .clsf_result0                 (clsf_result0),
      .clsf_result1                 (clsf_result1),
      .clsf_result2                 (clsf_result2),
      .clsf_result3                 (clsf_result3)
   );


//synthesis translate_off

integer file1;
reg     coin = 0;
reg     cmp_error;

initial
begin
	file1 = $fopen("ddr_wr_data1.txt","w"); 

end

always @(posedge clk)
begin
	if(app_wdf_wren == 1'b1)
	  coin <= ~coin;
	else;
end

always @( * )
begin
  if(app_wdf_wren == 1'b1)
    if(coin == 1'b0)
      if(app_wdf_data == 512'h12131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f5051)
        cmp_error <= 1'b0;
      else
        cmp_error <= 1'b1;
    else
      if(app_wdf_data == 512'h52535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f9091)
        cmp_error <= 1'b0;
      else
        cmp_error <= 1'b1;
  else
    cmp_error <= 1'b0;
    
end

always @(app_wdf_wren or cmp_error)
begin
	if(app_wdf_wren == 1'b1)
    $fdisplay(file1,"app_wdf_wren:%d, cmp_error: %d,  %h",app_wdf_wren,cmp_error,app_wdf_data);
  else;
end





//synthesis translate_on

endmodule