/*



*/


module image_proc2px #(
                    parameter   LineNumber = 36
                    )
                 (
                  input               clk,
                  input               rst,
                  input                 ddr_clk,
                  input                 ddr_rst,
                  input   [511:0]       app_rd_data,
                  input                 app_rd_data_valid ,
                  input                 app_rdy ,                        
                  input       [2:0]     app_cmd ,
                  input                 app_en  ,
                  
                  output              clsf_result0,
                  output              clsf_result1,
                  output              clsf_result2,
                  output              clsf_result3,
                  output              post_ddr_ram_full,
                  output  reg         valid4tree_reg
                  );

localparam   LinePixelNum = 1280;
localparam   MoveStep = 2;
localparam   MoveCount = LinePixelNum/MoveStep;
localparam   PreCnt4Valid = MoveCount*23 + 12 - 2;
localparam   LineMoveLimit = MoveCount - 12;
//localparam   LineNumber = 36;
localparam   TreeInputWidth = 576;  // 24x24x1bit
localparam   StopScanLine = LineNumber - 24;


localparam   IDLE = 0,
             SHIFT = 1,
             VALID = 2,
             INVALID = 3;
             

reg      [23:0] sreg_1,sreg_2,sreg_3,sreg_4,sreg_5,sreg_6,sreg_7,sreg_8,sreg_9,sreg_10,sreg_11,sreg_12,sreg_13,sreg_14,sreg_15,sreg_16,sreg_17,sreg_18,sreg_19,sreg_20,sreg_21,sreg_22,sreg_23,sreg_24;
wire     [1:0]  shift_data_out1,shift_data_out2,shift_data_out3,shift_data_out4,shift_data_out5,shift_data_out6,shift_data_out7,shift_data_out8,shift_data_out9,shift_data_out10,shift_data_out11,shift_data_out12,shift_data_out13,shift_data_out14,shift_data_out15,shift_data_out16,shift_data_out17,shift_data_out18,shift_data_out19,shift_data_out20,shift_data_out21,shift_data_out22,shift_data_out23,shift_data_out24;
wire     [TreeInputWidth-1:0] tree_data_in;
reg      [TreeInputWidth-1:0] tree_data_in_reg;
reg      [TreeInputWidth-1:0] tree_data_in_reorder_reg;

reg      [1:0]  current_state, next_state;
reg      [15:0] cnt_valid4tree;
wire            valid4tree;
//reg             valid4tree_reg;
reg    [TreeInputWidth-1:0] tree_data_in_reorder;
reg      [10:0] cnt_lines;
wire     [1:0]       data4sr;
wire                 data4sr_valid;

   post_ddr_buf u_post_ddr_buf(
                             .clk               (ddr_clk),
                             .rst               (ddr_rst),
                             .image_clk         (clk),
                             .image_rst         (rst),
                             .app_rd_data       (app_rd_data),
                             .app_rd_data_valid (app_rd_data_valid),
                             .app_rdy           (app_rdy),                         
                             .app_cmd           (app_cmd), 
                             .app_en            (app_en),  
                             .data4sr           (data4sr),
                             .data4sr_valid     (data4sr_valid    ),
                             .post_ddr_ram_full (post_ddr_ram_full)
                           );


//**************************************
// state machine to output valid signal to clsf_tree
//**************************************
always @(posedge clk)
begin
  if(rst)
    current_state <= IDLE;
  else
    current_state <= next_state;
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
		               
		INVALID:     if(cnt_valid4tree == MoveCount-1)
		               if(cnt_lines == StopScanLine-1)
		                 next_state = IDLE;
		               else
		                 next_state = VALID;
		             else
		               next_state = INVALID;
		               
	endcase
end


always @(posedge clk)
begin
  if(rst)
    cnt_valid4tree <= 16'b0;
  else
    if(current_state == SHIFT)
      if(cnt_valid4tree == PreCnt4Valid)
        cnt_valid4tree <= 'd0;
      else
        cnt_valid4tree <= cnt_valid4tree + 1'b1;
    else
      if(current_state == VALID)
        cnt_valid4tree <= cnt_valid4tree + 1'b1;
      else
        if(current_state == INVALID)
          if(cnt_valid4tree == MoveCount-1)
            cnt_valid4tree <= 'd0;
          else
            cnt_valid4tree <= cnt_valid4tree + 1'b1;
        else
          cnt_valid4tree <= 16'b0;  
end


//always @(posedge clk)
//begin
//  if(rst)
//    valid4tree <= 1'b0;
//  else
//    if(current_state == VALID)
//      valid4tree <= 1'b1;
//    else
//      valid4tree <= 1'b0;
//end

assign valid4tree = (current_state == VALID)? 1'b1:1'b0;

always @(posedge clk)
begin
  if(rst)
    cnt_lines <= 11'b0;
  else
    if(current_state == INVALID && cnt_valid4tree == MoveCount-1)
      if(cnt_lines == LineNumber-1)
        cnt_lines <= 11'b0;
      else
        cnt_lines <= cnt_lines + 1'b1;
    else;
end


//***********************************************************
// output signals to clsf tree
//***********************************************************
assign  tree_data_in = {sreg_1,sreg_2,sreg_3,sreg_4,sreg_5,sreg_6,sreg_7,sreg_8,sreg_9,sreg_10,sreg_11,sreg_12,sreg_13,sreg_14,sreg_15,sreg_16,sreg_17,sreg_18,sreg_19,sreg_20,sreg_21,sreg_22,sreg_23,sreg_24};


always @(posedge clk)
begin
  if(rst)
    tree_data_in_reorder_reg <= 'b0;
  else
    tree_data_in_reorder_reg <= tree_data_in_reorder;
end

always @(posedge clk)
begin
  if(rst)
    tree_data_in_reg <= 'b0;
  else
    tree_data_in_reg <= tree_data_in;
end


//integer i;
//always @(tree_data_in)
//begin
//  for(i=0; i< TreeInputWidth; i=i+1)
//  begin
//	  tree_data_in_reorder[TreeInputWidth-1 - i] = tree_data_in[i];
//  end
//end


integer i;
integer j;
always @(tree_data_in)
begin
  for(i=0; i< 24; i=i+1)
    for(j=0; j<24; j=j+1)
    begin
	    tree_data_in_reorder[j*24+i] = tree_data_in[i*24+j];
    end
end

always @(posedge clk)
begin
  if(rst)
    valid4tree_reg <= 1'b0;
  else
    valid4tree_reg <= valid4tree;
end

//************************************************************

//Ram-based shift register: width 2, depth 628


always @(posedge clk)
begin
  if(rst)
    sreg_1 <= 24'b0;
  else
    if(data4sr_valid == 1'b1)
      begin
        sreg_1[23:22] <= data4sr;
      	sreg_1[21:0]  <= sreg_1[23:2];
      end
end

// 2014-11-27, 17:9:40
always @(posedge clk)
begin
  if(rst)
    sreg_2 <= 24'b0;
  else
    begin
    	sreg_2[23:22] <=  shift_data_out1;
    	sreg_2[21:0]  <= sreg_2[23:2];
    end
end
always @(posedge clk)
begin
  if(rst)
    sreg_3 <= 24'b0;
  else
    begin
    	sreg_3[23:22] <=  shift_data_out2;
    	sreg_3[21:0]  <= sreg_3[23:2];
    end
end
always @(posedge clk)
begin
  if(rst)
    sreg_4 <= 24'b0;
  else
    begin
    	sreg_4[23:22] <=  shift_data_out3;
    	sreg_4[21:0]  <= sreg_4[23:2];
    end
end
always @(posedge clk)
begin
  if(rst)
    sreg_5 <= 24'b0;
  else
    begin
    	sreg_5[23:22] <=  shift_data_out4;
    	sreg_5[21:0]  <= sreg_5[23:2];
    end
end
always @(posedge clk)
begin
  if(rst)
    sreg_6 <= 24'b0;
  else
    begin
    	sreg_6[23:22] <=  shift_data_out5;
    	sreg_6[21:0]  <= sreg_6[23:2];
    end
end
always @(posedge clk)
begin
  if(rst)
    sreg_7 <= 24'b0;
  else
    begin
    	sreg_7[23:22] <=  shift_data_out6;
    	sreg_7[21:0]  <= sreg_7[23:2];
    end
end
always @(posedge clk)
begin
  if(rst)
    sreg_8 <= 24'b0;
  else
    begin
    	sreg_8[23:22] <=  shift_data_out7;
    	sreg_8[21:0]  <= sreg_8[23:2];
    end
end
always @(posedge clk)
begin
  if(rst)
    sreg_9 <= 24'b0;
  else
    begin
    	sreg_9[23:22] <=  shift_data_out8;
    	sreg_9[21:0]  <= sreg_9[23:2];
    end
end
always @(posedge clk)
begin
  if(rst)
    sreg_10 <= 24'b0;
  else
    begin
    	sreg_10[23:22] <=  shift_data_out9;
    	sreg_10[21:0]  <= sreg_10[23:2];
    end
end
always @(posedge clk)
begin
  if(rst)
    sreg_11 <= 24'b0;
  else
    begin
    	sreg_11[23:22] <=  shift_data_out10;
    	sreg_11[21:0]  <= sreg_11[23:2];
    end
end
always @(posedge clk)
begin
  if(rst)
    sreg_12 <= 24'b0;
  else
    begin
    	sreg_12[23:22] <=  shift_data_out11;
    	sreg_12[21:0]  <= sreg_12[23:2];
    end
end
always @(posedge clk)
begin
  if(rst)
    sreg_13 <= 24'b0;
  else
    begin
    	sreg_13[23:22] <=  shift_data_out12;
    	sreg_13[21:0]  <= sreg_13[23:2];
    end
end
always @(posedge clk)
begin
  if(rst)
    sreg_14 <= 24'b0;
  else
    begin
    	sreg_14[23:22] <=  shift_data_out13;
    	sreg_14[21:0]  <= sreg_14[23:2];
    end
end
always @(posedge clk)
begin
  if(rst)
    sreg_15 <= 24'b0;
  else
    begin
    	sreg_15[23:22] <=  shift_data_out14;
    	sreg_15[21:0]  <= sreg_15[23:2];
    end
end
always @(posedge clk)
begin
  if(rst)
    sreg_16 <= 24'b0;
  else
    begin
    	sreg_16[23:22] <=  shift_data_out15;
    	sreg_16[21:0]  <= sreg_16[23:2];
    end
end
always @(posedge clk)
begin
  if(rst)
    sreg_17 <= 24'b0;
  else
    begin
    	sreg_17[23:22] <=  shift_data_out16;
    	sreg_17[21:0]  <= sreg_17[23:2];
    end
end
always @(posedge clk)
begin
  if(rst)
    sreg_18 <= 24'b0;
  else
    begin
    	sreg_18[23:22] <=  shift_data_out17;
    	sreg_18[21:0]  <= sreg_18[23:2];
    end
end
always @(posedge clk)
begin
  if(rst)
    sreg_19 <= 24'b0;
  else
    begin
    	sreg_19[23:22] <=  shift_data_out18;
    	sreg_19[21:0]  <= sreg_19[23:2];
    end
end
always @(posedge clk)
begin
  if(rst)
    sreg_20 <= 24'b0;
  else
    begin
    	sreg_20[23:22] <=  shift_data_out19;
    	sreg_20[21:0]  <= sreg_20[23:2];
    end
end
always @(posedge clk)
begin
  if(rst)
    sreg_21 <= 24'b0;
  else
    begin
    	sreg_21[23:22] <=  shift_data_out20;
    	sreg_21[21:0]  <= sreg_21[23:2];
    end
end
always @(posedge clk)
begin
  if(rst)
    sreg_22 <= 24'b0;
  else
    begin
    	sreg_22[23:22] <=  shift_data_out21;
    	sreg_22[21:0]  <= sreg_22[23:2];
    end
end
always @(posedge clk)
begin
  if(rst)
    sreg_23 <= 24'b0;
  else
    begin
    	sreg_23[23:22] <=  shift_data_out22;
    	sreg_23[21:0]  <= sreg_23[23:2];
    end
end
always @(posedge clk)
begin
  if(rst)
    sreg_24 <= 24'b0;
  else
    begin
    	sreg_24[23:22] <=  shift_data_out23;
    	sreg_24[21:0]  <= sreg_24[23:2];
    end
end
shift_reg u_shift_reg1(
           .clk (clk),
           .d   (sreg_1[1:0]),
           .q   (shift_data_out1)
           );
shift_reg u_shift_reg2(
           .clk (clk),
           .d   (sreg_2[1:0]),
           .q   (shift_data_out2)
           );
shift_reg u_shift_reg3(
           .clk (clk),
           .d   (sreg_3[1:0]),
           .q   (shift_data_out3)
           );
shift_reg u_shift_reg4(
           .clk (clk),
           .d   (sreg_4[1:0]),
           .q   (shift_data_out4)
           );
shift_reg u_shift_reg5(
           .clk (clk),
           .d   (sreg_5[1:0]),
           .q   (shift_data_out5)
           );
shift_reg u_shift_reg6(
           .clk (clk),
           .d   (sreg_6[1:0]),
           .q   (shift_data_out6)
           );
shift_reg u_shift_reg7(
           .clk (clk),
           .d   (sreg_7[1:0]),
           .q   (shift_data_out7)
           );
shift_reg u_shift_reg8(
           .clk (clk),
           .d   (sreg_8[1:0]),
           .q   (shift_data_out8)
           );
shift_reg u_shift_reg9(
           .clk (clk),
           .d   (sreg_9[1:0]),
           .q   (shift_data_out9)
           );
shift_reg u_shift_reg10(
           .clk (clk),
           .d   (sreg_10[1:0]),
           .q   (shift_data_out10)
           );
shift_reg u_shift_reg11(
           .clk (clk),
           .d   (sreg_11[1:0]),
           .q   (shift_data_out11)
           );
shift_reg u_shift_reg12(
           .clk (clk),
           .d   (sreg_12[1:0]),
           .q   (shift_data_out12)
           );
shift_reg u_shift_reg13(
           .clk (clk),
           .d   (sreg_13[1:0]),
           .q   (shift_data_out13)
           );
shift_reg u_shift_reg14(
           .clk (clk),
           .d   (sreg_14[1:0]),
           .q   (shift_data_out14)
           );
shift_reg u_shift_reg15(
           .clk (clk),
           .d   (sreg_15[1:0]),
           .q   (shift_data_out15)
           );
shift_reg u_shift_reg16(
           .clk (clk),
           .d   (sreg_16[1:0]),
           .q   (shift_data_out16)
           );
shift_reg u_shift_reg17(
           .clk (clk),
           .d   (sreg_17[1:0]),
           .q   (shift_data_out17)
           );
shift_reg u_shift_reg18(
           .clk (clk),
           .d   (sreg_18[1:0]),
           .q   (shift_data_out18)
           );
shift_reg u_shift_reg19(
           .clk (clk),
           .d   (sreg_19[1:0]),
           .q   (shift_data_out19)
           );
shift_reg u_shift_reg20(
           .clk (clk),
           .d   (sreg_20[1:0]),
           .q   (shift_data_out20)
           );
shift_reg u_shift_reg21(
           .clk (clk),
           .d   (sreg_21[1:0]),
           .q   (shift_data_out21)
           );
shift_reg u_shift_reg22(
           .clk (clk),
           .d   (sreg_22[1:0]),
           .q   (shift_data_out22)
           );
shift_reg u_shift_reg23(
           .clk (clk),
           .d   (sreg_23[1:0]),
           .q   (shift_data_out23)
           );
shift_reg u_shift_reg24(
           .clk (clk),
           .d   (sreg_24[1:0]),
           .q   (shift_data_out24)
           );





clsf_tree  #(
             .TreeInputWidth(TreeInputWidth)
             )
       u_clsf_tree(
                       .rx_fifo_clock  (clk ),
                       .rx_fifo_resetn (~rst),
                       .data_in        (tree_data_in_reorder_reg),//tree_data_in_reg),
                       .data_valid     (valid4tree_reg),
                       .clsf_result0    (clsf_result0),
                       .clsf_result1    (clsf_result1),
                       .clsf_result2    (clsf_result2),
                       .clsf_result_mul (clsf_result3)
                   );


//***** temp signals for debug
//wire     [2:0] sreg1_1 ;
//wire     [2:0] sreg1_2 ;
//wire     [2:0] sreg1_3 ;
//wire     [2:0] sreg1_4 ;
//wire     [2:0] sreg1_5 ;
//wire     [2:0] sreg1_6 ;
//wire     [2:0] sreg1_7 ;
//wire     [2:0] sreg1_8 ;
//wire     [2:0] sreg1_9 ;
//wire     [2:0] sreg1_10;
//wire     [2:0] sreg1_11;
//wire     [2:0] sreg1_12;
//wire     [2:0] sreg1_13;
//wire     [2:0] sreg1_14;
//wire     [2:0] sreg1_15;
//wire     [2:0] sreg1_16;
//wire     [2:0] sreg1_17;
//wire     [2:0] sreg1_18;
//wire     [2:0] sreg1_19;
//wire     [2:0] sreg1_20;
//wire     [2:0] sreg1_21;
//wire     [2:0] sreg1_22;
//wire     [2:0] sreg1_23;
//wire     [2:0] sreg1_24;
//wire     [2:0] sreg1_25;
//wire     [2:0] sreg1_26;
//wire     [2:0] sreg1_27;
//wire     [2:0] sreg1_28;
//wire     [2:0] sreg1_29;
//wire     [2:0] sreg1_30;
//wire     [2:0] sreg1_31;
//wire     [2:0] sreg1_32;
//
//wire     [2:0] rd_data_1 ;
//wire     [2:0] rd_data_2 ;
//wire     [2:0] rd_data_3 ;
//wire     [2:0] rd_data_4 ;
//wire     [2:0] rd_data_5 ;
//wire     [2:0] rd_data_6 ;
//wire     [2:0] rd_data_7 ;
//wire     [2:0] rd_data_8 ;
//
//
//
//
//    assign sreg1_1 = sreg_1[2:0];
//    assign sreg1_2 = sreg_1[5:3];
//    assign sreg1_3 = sreg_1[8:6];
//    assign sreg1_4 = sreg_1[11:9];
//    assign sreg1_5 = sreg_1[14:12];
//    assign sreg1_6 = sreg_1[17:15];
//    assign sreg1_7 = sreg_1[20:18];
//    assign sreg1_8 = sreg_1[23:21];
//    assign sreg1_9 = sreg_1[26:24];
//    assign sreg1_10 = sreg_1[29:27];
//    assign sreg1_11 = sreg_1[32:30];
//    assign sreg1_12 = sreg_1[35:33];
//    assign sreg1_13 = sreg_1[38:36];
//    assign sreg1_14 = sreg_1[41:39];
//    assign sreg1_15 = sreg_1[44:42];
//    assign sreg1_16 = sreg_1[47:45];
//    assign sreg1_17 = sreg_1[50:48];
//    assign sreg1_18 = sreg_1[53:51];
//    assign sreg1_19 = sreg_1[56:54];
//    assign sreg1_20 = sreg_1[59:57];
//    assign sreg1_21 = sreg_1[62:60];
//    assign sreg1_22 = sreg_1[65:63];
//    assign sreg1_23 = sreg_1[68:66];
//    assign sreg1_24 = sreg_1[71:69];
//    assign sreg1_25 = sreg_1[74:72];
//    assign sreg1_26 = sreg_1[77:75];
//    assign sreg1_27 = sreg_1[80:78];
//    assign sreg1_28 = sreg_1[83:81];
//    assign sreg1_29 = sreg_1[86:84];
//    assign sreg1_30 = sreg_1[89:87];
//    assign sreg1_31 = sreg_1[92:90];
//    assign sreg1_32 = sreg_1[95:93];
//
//    assign rd_data_1 = rd_data_dly1[2:0];
//    assign rd_data_2 = rd_data_dly1[5:3];
//    assign rd_data_3 = rd_data_dly1[8:6];
//    assign rd_data_4 = rd_data_dly1[11:9];
//    assign rd_data_5 = rd_data_dly1[14:12];
//    assign rd_data_6 = rd_data_dly1[17:15];
//    assign rd_data_7 = rd_data_dly1[20:18];
//    assign rd_data_8 = rd_data_dly1[23:21];


endmodule