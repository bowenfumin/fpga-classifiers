/*



*/

`include "../../src/include/defines.v"

module image_proc1px #(
                    parameter   LineNumber = 36
                    )
                 (
                  input                 clk,
                  input                 rst,
                  input                 ddr_clk,
                  input                 ddr_rst,
                  input   [511:0]       app_rd_data,
                  input                 app_rd_data_valid ,
                  input                 app_rdy ,                        
                  input   [2:0]         app_cmd ,
                  input                 app_en  ,
                  input                 rd_en,
                  input   [12:0]        rd_addr_result, 
                  input                 rd_row_data_done,
                  output                post_ddr_ram_full,
                  
                   
                  output   [7:0]        rd_data_result,
                  output                debug_result_buf,
                  output                pkt_ready_result
                  
                  );
localparam   DLY = 1000;
localparam   LinePixelNum = 1280;
localparam   MoveStep = 1;
localparam   MoveCount = LinePixelNum/MoveStep;
localparam   PreCnt4Valid = MoveCount*23 + 24/MoveStep - 2;
localparam   LineMoveLimit = MoveCount - 24/MoveStep;
//localparam   LineNumber = 36;
localparam   TreeInputWidth = 576;  // 24x24x1bit
localparam   StopScanLine = LineNumber - 24+1;


localparam   IDLE = 0,
             SHIFT = 1,
             VALID = 2,
             INVALID = 3,
             FULL = 4;
             

reg      [23:0] sreg_1,sreg_2,sreg_3,sreg_4,sreg_5,sreg_6,sreg_7,sreg_8,sreg_9,sreg_10,sreg_11,sreg_12,sreg_13,sreg_14,sreg_15,sreg_16,sreg_17,sreg_18,sreg_19,sreg_20,sreg_21,sreg_22,sreg_23,sreg_24;
wire     shift_data_out1_up, shift_data_out1_down,shift_data_out2_up, shift_data_out2_down,shift_data_out3_up, shift_data_out3_down,shift_data_out4_up, shift_data_out4_down,shift_data_out5_up, shift_data_out5_down,shift_data_out6_up, shift_data_out6_down,shift_data_out7_up, shift_data_out7_down,shift_data_out8_up, shift_data_out8_down,shift_data_out9_up, shift_data_out9_down,shift_data_out10_up, shift_data_out10_down,shift_data_out11_up, shift_data_out11_down,shift_data_out12_up, shift_data_out12_down,shift_data_out13_up, shift_data_out13_down,shift_data_out14_up, shift_data_out14_down,shift_data_out15_up, shift_data_out15_down,shift_data_out16_up, shift_data_out16_down,shift_data_out17_up, shift_data_out17_down,shift_data_out18_up, shift_data_out18_down,shift_data_out19_up, shift_data_out19_down,shift_data_out20_up, shift_data_out20_down,shift_data_out21_up, shift_data_out21_down,shift_data_out22_up, shift_data_out22_down,shift_data_out23_up, shift_data_out23_down,shift_data_out24_up, shift_data_out24_down;
wire     [TreeInputWidth-1:0] tree_data_in;
reg      [TreeInputWidth-1:0] tree_data_in_reg;
reg      [TreeInputWidth-1:0] tree_data_in_reorder_reg;

reg      [2:0]  current_state, next_state;
reg      [15:0] cnt_valid4tree;
wire            valid4tree;
reg             valid4tree_reg;
reg    [TreeInputWidth-1:0] tree_data_in_reorder;
reg      [10:0] cnt_lines;
wire                 data4sr;
wire                 data4sr_valid;
wire     [7:0]  result_data;
wire            result_buf_full;
reg             result_buf_full_dly1;
wire            clk_en;
wire            clsf_result0;
wire            clsf_result1;
wire            clsf_result2;
wire            clsf_result3;
wire            clsf_result4;
reg             one_frame_done;
wire            to_full;




   post_ddr_buf  #(
                        .LineNumber(LineNumber)
                        )
                 u_post_ddr_buf(
                             .clk               (ddr_clk),
                             .rst               (ddr_rst),
                             .image_clk         (clk),
                             .image_rst         (rst),
                             .app_rd_data       (app_rd_data),
                             .app_rd_data_valid (app_rd_data_valid),
                             .app_rdy           (app_rdy),                         
                             .app_cmd           (app_cmd), 
                             .app_en            (app_en),  
                             .result_buf_full   (result_buf_full  ),
                             .data4sr           (data4sr),
                             .data4sr_valid     (data4sr_valid    ),
                             .one_frame_done    (one_frame_done   ),
                             .to_full           (to_full          ),
                             .post_ddr_ram_full (post_ddr_ram_full)                           
                           );

//************************************************************
// for simulation only
// inject data directly from image
//************************************************************
`ifdef InjectFromImage
reg     valid4tree_temp;
reg     [TreeInputWidth-1:0] patch_data_reverse;
always @(posedge clk)
begin
  if(rst)
    valid4tree_temp <= #DLY  1'b0;
  else
    valid4tree_temp <= #DLY  1'b1;
end

assign valid4tree = valid4tree_temp;

integer i;
always @ *
begin
  for(i=0; i< TreeInputWidth; i=i+1)
  begin
	  patch_data_reverse[TreeInputWidth-1 - i] = demo_tb.patch_data[i];
  end
end

assign tree_data_in = patch_data_reverse;

`else

//**************************************
// state machine to output valid signal to clsf_tree
//**************************************
always @(posedge clk)
begin
  if(rst)
    current_state <= #DLY  IDLE;
  else
    current_state <= #DLY  next_state;
end

always @*
begin
	case(current_state)
		IDLE:        if(data4sr_valid == 1'b1)
		               next_state = SHIFT;
		             else
		               next_state = IDLE;
		
		SHIFT:       if(cnt_valid4tree == PreCnt4Valid)
		               next_state = VALID;
		             else
		               next_state = SHIFT;
		               
		VALID:       if(cnt_valid4tree == LineMoveLimit)
		               next_state = INVALID;
		             else
		               next_state = VALID;
		//means result buffer is full
		FULL:        if(result_buf_full_dly1 == 1'b0)		               
		               next_state = VALID;
		             else
		               next_state = FULL;
		               
		INVALID:     if(cnt_valid4tree == MoveCount-1) //MoveCount=1280
		               if(cnt_lines == StopScanLine-1) // one image finished
		                 next_state = IDLE;
		               else
		                 if(to_full == 1'b1)
		                   next_state = FULL;
		                 else
		                   next_state = VALID;
		             else
		               next_state = INVALID;
		               
	endcase
end


always @(posedge clk)
begin
  if(rst)
    result_buf_full_dly1 <=  #DLY 1'b0;
  else
    result_buf_full_dly1 <=  #DLY result_buf_full;
end

always @(posedge clk)
begin
  if(rst)
    one_frame_done <= #DLY  1'b0;
  else
    if(current_state == INVALID && cnt_valid4tree == MoveCount-1 && cnt_lines == StopScanLine-1)
      one_frame_done <= #DLY  1'b1;
    else
      one_frame_done <= #DLY  1'b0;
     
end

always @(posedge clk)
begin
  if(rst)
    cnt_valid4tree <= #DLY  16'b0;
  else
    if(current_state == SHIFT)
      if(cnt_valid4tree == PreCnt4Valid)
        cnt_valid4tree <= #DLY  'd0;
      else
        cnt_valid4tree <= #DLY  cnt_valid4tree + 1'b1;
    else
      if(current_state == VALID)
        cnt_valid4tree <= #DLY  cnt_valid4tree + 1'b1;
      else
        if(current_state == INVALID)
          if(cnt_valid4tree == MoveCount-1)
            cnt_valid4tree <= #DLY  'd0;
          else
            cnt_valid4tree <= #DLY  cnt_valid4tree + 1'b1;
        else;
end


//always @(posedge clk)
//begin
//  if(rst)
//    valid4tree <= #DLY  1'b0;
//  else
//    if(current_state == VALID)
//      valid4tree <= #DLY  1'b1;
//    else
//      valid4tree <= #DLY  1'b0;
//end

assign valid4tree = (current_state == VALID)? 1'b1:1'b0;

always @(posedge clk)
begin
  if(rst)
    cnt_lines <= #DLY  11'b0;
  else
    if(current_state == INVALID && cnt_valid4tree == MoveCount-1)
      if(cnt_lines == StopScanLine-1)
        cnt_lines <= #DLY  11'b0;
      else
        cnt_lines <= #DLY  cnt_lines + 1'b1;
    else;
end


//***********************************************************
// output signals to clsf tree
//***********************************************************
assign  tree_data_in = {sreg_1,sreg_2,sreg_3,sreg_4,sreg_5,sreg_6,sreg_7,sreg_8,sreg_9,sreg_10,sreg_11,sreg_12,sreg_13,sreg_14,sreg_15,sreg_16,sreg_17,sreg_18,sreg_19,sreg_20,sreg_21,sreg_22,sreg_23,sreg_24};

`endif

always @(posedge clk)
begin
  if(rst)
    tree_data_in_reorder_reg <= #DLY  'b0;
  else
    tree_data_in_reorder_reg <= #DLY  tree_data_in_reorder;
end

always @(posedge clk)
begin
  if(rst)
    tree_data_in_reg <= #DLY  'b0;
  else
    tree_data_in_reg <= #DLY  tree_data_in;
end

`ifdef InjectFromImage
`else
integer i;
`endif

always @(tree_data_in)
begin
  for(i=0; i< TreeInputWidth; i=i+1)
  begin
	  tree_data_in_reorder[TreeInputWidth-1 - i] = tree_data_in[i];
  end
end

// turn the patch by 180 degree
//integer i;
//integer j;
//always @(tree_data_in)
//begin
//  for(i=0; i< 24; i=i+1)
//    for(j=0; j<24; j=j+1)
//    begin
//	    tree_data_in_reorder[j*24+i] = tree_data_in[i*24+j];
//    end
//end

always @(posedge clk)
begin
  if(rst)
    valid4tree_reg <= #DLY  1'b0;
  else
    valid4tree_reg <= #DLY  valid4tree;
end

`ifdef InjectFromImage

`else

//************************************************************

//Ram-based shift register: width 2, depth 628
//always @(posedge clk)
//begin
//  if(rst)
//    clk_en <= #DLY 1'b1;
//  else
//    clk_en <= #DLY  data4sr_valid;
//end

assign clk_en =  data4sr_valid||current_state == SHIFT||current_state == VALID||current_state == INVALID;

// 2015-4-5, 21:20:6
always @(posedge clk)
begin
  if(rst)
    sreg_1 <= 24'b0;
  else
    // if(data4sr_valid == 1'b1)
    if(data4sr_valid||current_state == SHIFT||current_state == VALID||current_state == INVALID)
    begin
    	sreg_1[23] <=  data4sr;
    	sreg_1[22:0]  <= sreg_1[23:1];
    end
    else;
end
always @(posedge clk)
begin
  if(rst)
    sreg_2 <= 24'b0;
  else
    //if(data4sr_valid == 1'b1)
    if(data4sr_valid||current_state == SHIFT||current_state == VALID||current_state == INVALID)
    begin
    	sreg_2[23] <=  shift_data_out1_down;
    	sreg_2[22:0]  <= sreg_2[23:1];
    end
    else;
end
always @(posedge clk)
begin
  if(rst)
    sreg_3 <= 24'b0;
  else
    //if(data4sr_valid == 1'b1)
    if(data4sr_valid||current_state == SHIFT||current_state == VALID||current_state == INVALID)
    begin
    	sreg_3[23] <=  shift_data_out2_down;
    	sreg_3[22:0]  <= sreg_3[23:1];
    end
    else;
end
always @(posedge clk)
begin
  if(rst)
    sreg_4 <= 24'b0;
  else
    //if(data4sr_valid == 1'b1)
    if(data4sr_valid||current_state == SHIFT||current_state == VALID||current_state == INVALID)
    begin
    	sreg_4[23] <=  shift_data_out3_down;
    	sreg_4[22:0]  <= sreg_4[23:1];
    end
    else;
end
always @(posedge clk)
begin
  if(rst)
    sreg_5 <= 24'b0;
  else
    //if(data4sr_valid == 1'b1)
    if(data4sr_valid||current_state == SHIFT||current_state == VALID||current_state == INVALID)
    begin
    	sreg_5[23] <=  shift_data_out4_down;
    	sreg_5[22:0]  <= sreg_5[23:1];
    end
    else;
end
always @(posedge clk)
begin
  if(rst)
    sreg_6 <= 24'b0;
  else
    //if(data4sr_valid == 1'b1)
    if(data4sr_valid||current_state == SHIFT||current_state == VALID||current_state == INVALID)
    begin
    	sreg_6[23] <=  shift_data_out5_down;
    	sreg_6[22:0]  <= sreg_6[23:1];
    end
    else;
end
always @(posedge clk)
begin
  if(rst)
    sreg_7 <= 24'b0;
  else
    //if(data4sr_valid == 1'b1)
    if(data4sr_valid||current_state == SHIFT||current_state == VALID||current_state == INVALID)
    begin
    	sreg_7[23] <=  shift_data_out6_down;
    	sreg_7[22:0]  <= sreg_7[23:1];
    end
    else;
end
always @(posedge clk)
begin
  if(rst)
    sreg_8 <= 24'b0;
  else
    //if(data4sr_valid == 1'b1)
    if(data4sr_valid||current_state == SHIFT||current_state == VALID||current_state == INVALID)
    begin
    	sreg_8[23] <=  shift_data_out7_down;
    	sreg_8[22:0]  <= sreg_8[23:1];
    end
    else;
end
always @(posedge clk)
begin
  if(rst)
    sreg_9 <= 24'b0;
  else
    //if(data4sr_valid == 1'b1)
    if(data4sr_valid||current_state == SHIFT||current_state == VALID||current_state == INVALID)
    begin
    	sreg_9[23] <=  shift_data_out8_down;
    	sreg_9[22:0]  <= sreg_9[23:1];
    end
    else;
end
always @(posedge clk)
begin
  if(rst)
    sreg_10 <= 24'b0;
  else
    //if(data4sr_valid == 1'b1)
    if(data4sr_valid||current_state == SHIFT||current_state == VALID||current_state == INVALID)
    begin
    	sreg_10[23] <=  shift_data_out9_down;
    	sreg_10[22:0]  <= sreg_10[23:1];
    end
    else;
end
always @(posedge clk)
begin
  if(rst)
    sreg_11 <= 24'b0;
  else
    //if(data4sr_valid == 1'b1)
    if(data4sr_valid||current_state == SHIFT||current_state == VALID||current_state == INVALID)
    begin
    	sreg_11[23] <=  shift_data_out10_down;
    	sreg_11[22:0]  <= sreg_11[23:1];
    end
    else;
end
always @(posedge clk)
begin
  if(rst)
    sreg_12 <= 24'b0;
  else
    //if(data4sr_valid == 1'b1)
    if(data4sr_valid||current_state == SHIFT||current_state == VALID||current_state == INVALID)
    begin
    	sreg_12[23] <=  shift_data_out11_down;
    	sreg_12[22:0]  <= sreg_12[23:1];
    end
    else;
end
always @(posedge clk)
begin
  if(rst)
    sreg_13 <= 24'b0;
  else
    //if(data4sr_valid == 1'b1)
    if(data4sr_valid||current_state == SHIFT||current_state == VALID||current_state == INVALID)
    begin
    	sreg_13[23] <=  shift_data_out12_down;
    	sreg_13[22:0]  <= sreg_13[23:1];
    end
    else;
end
always @(posedge clk)
begin
  if(rst)
    sreg_14 <= 24'b0;
  else
    //if(data4sr_valid == 1'b1)
    if(data4sr_valid||current_state == SHIFT||current_state == VALID||current_state == INVALID)
    begin
    	sreg_14[23] <=  shift_data_out13_down;
    	sreg_14[22:0]  <= sreg_14[23:1];
    end
    else;
end
always @(posedge clk)
begin
  if(rst)
    sreg_15 <= 24'b0;
  else
    //if(data4sr_valid == 1'b1)
    if(data4sr_valid||current_state == SHIFT||current_state == VALID||current_state == INVALID)
    begin
    	sreg_15[23] <=  shift_data_out14_down;
    	sreg_15[22:0]  <= sreg_15[23:1];
    end
    else;
end
always @(posedge clk)
begin
  if(rst)
    sreg_16 <= 24'b0;
  else
    //if(data4sr_valid == 1'b1)
    if(data4sr_valid||current_state == SHIFT||current_state == VALID||current_state == INVALID)
    begin
    	sreg_16[23] <=  shift_data_out15_down;
    	sreg_16[22:0]  <= sreg_16[23:1];
    end
    else;
end
always @(posedge clk)
begin
  if(rst)
    sreg_17 <= 24'b0;
  else
    //if(data4sr_valid == 1'b1)
    if(data4sr_valid||current_state == SHIFT||current_state == VALID||current_state == INVALID)
    begin
    	sreg_17[23] <=  shift_data_out16_down;
    	sreg_17[22:0]  <= sreg_17[23:1];
    end
    else;
end
always @(posedge clk)
begin
  if(rst)
    sreg_18 <= 24'b0;
  else
    //if(data4sr_valid == 1'b1)
    if(data4sr_valid||current_state == SHIFT||current_state == VALID||current_state == INVALID)
    begin
    	sreg_18[23] <=  shift_data_out17_down;
    	sreg_18[22:0]  <= sreg_18[23:1];
    end
    else;
end
always @(posedge clk)
begin
  if(rst)
    sreg_19 <= 24'b0;
  else
    //if(data4sr_valid == 1'b1)
    if(data4sr_valid||current_state == SHIFT||current_state == VALID||current_state == INVALID)
    begin
    	sreg_19[23] <=  shift_data_out18_down;
    	sreg_19[22:0]  <= sreg_19[23:1];
    end
    else;
end
always @(posedge clk)
begin
  if(rst)
    sreg_20 <= 24'b0;
  else
    //if(data4sr_valid == 1'b1)
    if(data4sr_valid||current_state == SHIFT||current_state == VALID||current_state == INVALID)
    begin
    	sreg_20[23] <=  shift_data_out19_down;
    	sreg_20[22:0]  <= sreg_20[23:1];
    end
    else;
end
always @(posedge clk)
begin
  if(rst)
    sreg_21 <= 24'b0;
  else
    //if(data4sr_valid == 1'b1)
    if(data4sr_valid||current_state == SHIFT||current_state == VALID||current_state == INVALID)
    begin
    	sreg_21[23] <=  shift_data_out20_down;
    	sreg_21[22:0]  <= sreg_21[23:1];
    end
    else;
end
always @(posedge clk)
begin
  if(rst)
    sreg_22 <= 24'b0;
  else
    //if(data4sr_valid == 1'b1)
    if(data4sr_valid||current_state == SHIFT||current_state == VALID||current_state == INVALID)
    begin
    	sreg_22[23] <=  shift_data_out21_down;
    	sreg_22[22:0]  <= sreg_22[23:1];
    end
    else;
end
always @(posedge clk)
begin
  if(rst)
    sreg_23 <= 24'b0;
  else
    //if(data4sr_valid == 1'b1)
    if(data4sr_valid||current_state == SHIFT||current_state == VALID||current_state == INVALID)
    begin
    	sreg_23[23] <=  shift_data_out22_down;
    	sreg_23[22:0]  <= sreg_23[23:1];
    end
    else;
end
always @(posedge clk)
begin
  if(rst)
    sreg_24 <= 24'b0;
  else
    //if(data4sr_valid == 1'b1)
    if(data4sr_valid||current_state == SHIFT||current_state == VALID||current_state == INVALID)
    begin
    	sreg_24[23] <=  shift_data_out23_down;
    	sreg_24[22:0]  <= sreg_24[23:1];
    end
    else;
end

shift_regby1 u_shift_regby1px1_up(
           .clk (clk),
           .ce  (clk_en),
           .d   (sreg_1[0]),
           .q   (shift_data_out1_up)
           );    
shift_regby1 u_shift_regby1px1down(
           .clk (clk),
           .ce  (clk_en),
           .d   (shift_data_out1_up),
           .q   (shift_data_out1_down)
           );

shift_regby1 u_shift_regby1px2_up(
           .clk (clk),
           .ce  (clk_en),
           .d   (sreg_2[0]),
           .q   (shift_data_out2_up)
           );    
shift_regby1 u_shift_regby1px2down(
           .clk (clk),
           .ce  (clk_en),
           .d   (shift_data_out2_up),
           .q   (shift_data_out2_down)
           );

shift_regby1 u_shift_regby1px3_up(
           .clk (clk),
           .ce  (clk_en),
           .d   (sreg_3[0]),
           .q   (shift_data_out3_up)
           );    
shift_regby1 u_shift_regby1px3down(
           .clk (clk),
           .ce  (clk_en),
           .d   (shift_data_out3_up),
           .q   (shift_data_out3_down)
           );

shift_regby1 u_shift_regby1px4_up(
           .clk (clk),
           .ce  (clk_en),
           .d   (sreg_4[0]),
           .q   (shift_data_out4_up)
           );    
shift_regby1 u_shift_regby1px4down(
           .clk (clk),
           .ce  (clk_en),
           .d   (shift_data_out4_up),
           .q   (shift_data_out4_down)
           );

shift_regby1 u_shift_regby1px5_up(
           .clk (clk),
           .ce  (clk_en),
           .d   (sreg_5[0]),
           .q   (shift_data_out5_up)
           );    
shift_regby1 u_shift_regby1px5down(
           .clk (clk),
           .ce  (clk_en),
           .d   (shift_data_out5_up),
           .q   (shift_data_out5_down)
           );

shift_regby1 u_shift_regby1px6_up(
           .clk (clk),
           .ce  (clk_en),
           .d   (sreg_6[0]),
           .q   (shift_data_out6_up)
           );    
shift_regby1 u_shift_regby1px6down(
           .clk (clk),
           .ce  (clk_en),
           .d   (shift_data_out6_up),
           .q   (shift_data_out6_down)
           );

shift_regby1 u_shift_regby1px7_up(
           .clk (clk),
           .ce  (clk_en),
           .d   (sreg_7[0]),
           .q   (shift_data_out7_up)
           );    
shift_regby1 u_shift_regby1px7down(
           .clk (clk),
           .ce  (clk_en),
           .d   (shift_data_out7_up),
           .q   (shift_data_out7_down)
           );

shift_regby1 u_shift_regby1px8_up(
           .clk (clk),
           .ce  (clk_en),
           .d   (sreg_8[0]),
           .q   (shift_data_out8_up)
           );    
shift_regby1 u_shift_regby1px8down(
           .clk (clk),
           .ce  (clk_en),
           .d   (shift_data_out8_up),
           .q   (shift_data_out8_down)
           );

shift_regby1 u_shift_regby1px9_up(
           .clk (clk),
           .ce  (clk_en),
           .d   (sreg_9[0]),
           .q   (shift_data_out9_up)
           );    
shift_regby1 u_shift_regby1px9down(
           .clk (clk),
           .ce  (clk_en),
           .d   (shift_data_out9_up),
           .q   (shift_data_out9_down)
           );

shift_regby1 u_shift_regby1px10_up(
           .clk (clk),
           .ce  (clk_en),
           .d   (sreg_10[0]),
           .q   (shift_data_out10_up)
           );    
shift_regby1 u_shift_regby1px10down(
           .clk (clk),
           .ce  (clk_en),
           .d   (shift_data_out10_up),
           .q   (shift_data_out10_down)
           );

shift_regby1 u_shift_regby1px11_up(
           .clk (clk),
           .ce  (clk_en),
           .d   (sreg_11[0]),
           .q   (shift_data_out11_up)
           );    
shift_regby1 u_shift_regby1px11down(
           .clk (clk),
           .ce  (clk_en),
           .d   (shift_data_out11_up),
           .q   (shift_data_out11_down)
           );

shift_regby1 u_shift_regby1px12_up(
           .clk (clk),
           .ce  (clk_en),
           .d   (sreg_12[0]),
           .q   (shift_data_out12_up)
           );    
shift_regby1 u_shift_regby1px12down(
           .clk (clk),
           .ce  (clk_en),
           .d   (shift_data_out12_up),
           .q   (shift_data_out12_down)
           );

shift_regby1 u_shift_regby1px13_up(
           .clk (clk),
           .ce  (clk_en),
           .d   (sreg_13[0]),
           .q   (shift_data_out13_up)
           );    
shift_regby1 u_shift_regby1px13down(
           .clk (clk),
           .ce  (clk_en),
           .d   (shift_data_out13_up),
           .q   (shift_data_out13_down)
           );

shift_regby1 u_shift_regby1px14_up(
           .clk (clk),
           .ce  (clk_en),
           .d   (sreg_14[0]),
           .q   (shift_data_out14_up)
           );    
shift_regby1 u_shift_regby1px14down(
           .clk (clk),
           .ce  (clk_en),
           .d   (shift_data_out14_up),
           .q   (shift_data_out14_down)
           );

shift_regby1 u_shift_regby1px15_up(
           .clk (clk),
           .ce  (clk_en),
           .d   (sreg_15[0]),
           .q   (shift_data_out15_up)
           );    
shift_regby1 u_shift_regby1px15down(
           .clk (clk),
           .ce  (clk_en),
           .d   (shift_data_out15_up),
           .q   (shift_data_out15_down)
           );

shift_regby1 u_shift_regby1px16_up(
           .clk (clk),
           .ce  (clk_en),
           .d   (sreg_16[0]),
           .q   (shift_data_out16_up)
           );    
shift_regby1 u_shift_regby1px16down(
           .clk (clk),
           .ce  (clk_en),
           .d   (shift_data_out16_up),
           .q   (shift_data_out16_down)
           );

shift_regby1 u_shift_regby1px17_up(
           .clk (clk),
           .ce  (clk_en),
           .d   (sreg_17[0]),
           .q   (shift_data_out17_up)
           );    
shift_regby1 u_shift_regby1px17down(
           .clk (clk),
           .ce  (clk_en),
           .d   (shift_data_out17_up),
           .q   (shift_data_out17_down)
           );

shift_regby1 u_shift_regby1px18_up(
           .clk (clk),
           .ce  (clk_en),
           .d   (sreg_18[0]),
           .q   (shift_data_out18_up)
           );    
shift_regby1 u_shift_regby1px18down(
           .clk (clk),
           .ce  (clk_en),
           .d   (shift_data_out18_up),
           .q   (shift_data_out18_down)
           );

shift_regby1 u_shift_regby1px19_up(
           .clk (clk),
           .ce  (clk_en),
           .d   (sreg_19[0]),
           .q   (shift_data_out19_up)
           );    
shift_regby1 u_shift_regby1px19down(
           .clk (clk),
           .ce  (clk_en),
           .d   (shift_data_out19_up),
           .q   (shift_data_out19_down)
           );

shift_regby1 u_shift_regby1px20_up(
           .clk (clk),
           .ce  (clk_en),
           .d   (sreg_20[0]),
           .q   (shift_data_out20_up)
           );    
shift_regby1 u_shift_regby1px20down(
           .clk (clk),
           .ce  (clk_en),
           .d   (shift_data_out20_up),
           .q   (shift_data_out20_down)
           );

shift_regby1 u_shift_regby1px21_up(
           .clk (clk),
           .ce  (clk_en),
           .d   (sreg_21[0]),
           .q   (shift_data_out21_up)
           );    
shift_regby1 u_shift_regby1px21down(
           .clk (clk),
           .ce  (clk_en),
           .d   (shift_data_out21_up),
           .q   (shift_data_out21_down)
           );

shift_regby1 u_shift_regby1px22_up(
           .clk (clk),
           .ce  (clk_en),
           .d   (sreg_22[0]),
           .q   (shift_data_out22_up)
           );    
shift_regby1 u_shift_regby1px22down(
           .clk (clk),
           .ce  (clk_en),
           .d   (shift_data_out22_up),
           .q   (shift_data_out22_down)
           );

shift_regby1 u_shift_regby1px23_up(
           .clk (clk),
           .ce  (clk_en),
           .d   (sreg_23[0]),
           .q   (shift_data_out23_up)
           );    
shift_regby1 u_shift_regby1px23down(
           .clk (clk),
           .ce  (clk_en),
           .d   (shift_data_out23_up),
           .q   (shift_data_out23_down)
           );

shift_regby1 u_shift_regby1px24_up(
           .clk (clk),
           .ce  (clk_en),
           .d   (sreg_24[0]),
           .q   (shift_data_out24_up)
           );    
shift_regby1 u_shift_regby1px24down(
           .clk (clk),
           .ce  (clk_en),
           .d   (shift_data_out24_up),
           .q   (shift_data_out24_down)
           );



`endif

clsf_tree  #(
             .TreeInputWidth(TreeInputWidth)
             )
       u_clsf_tree(
                       .rx_fifo_clock  (clk ),
                       .rx_fifo_resetn (~rst),
                       `ifdef InjectFromImage
                       .data_in        (tree_data_in), 
                       //.data_in        (tree_data_in_reorder), // turn the patch by 180 degree
                       `else
                       .data_in        (tree_data_in_reg),
                       `endif
                       .data_valid     (valid4tree_reg),
                       .result_data    (result_data)
                   );




result_buf            #(
                        .LineNumber(LineNumber)
                        )
                      u_result_buf(
                                   .clk                    (clk                   ),
                                   .rst                    (rst                   ),
                                   .valid                  (valid4tree_reg        ),
                                   .data_in                (result_data           ),
                                   .rd_row_data_done       (rd_row_data_done      ),
                                   .rd_en                  (rd_en                 ),
                                   .rd_addr                (rd_addr_result        ),
                                   .rd_data                (rd_data_result        ),
                                   .pkt_ready              (pkt_ready_result      ),
                                   .debug_result_buf       (debug_result_buf      ),
                                   .result_buf_full        (result_buf_full       )

                                   );

endmodule