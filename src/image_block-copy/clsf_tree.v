/*


*/


module   clsf_tree(
                   input               rx_fifo_clock,
                   input               rx_fifo_resetn,
                   input       [1727:0] data_in,
//                   input       [1535:0] data_in,
                   input               data_valid,
                   output              clsf_result0,
                   output              clsf_result1,
                   output              clsf_result2,
                   output              clsf_result_mul
                   
                   );
                   
wire   [1728:0]tree_input0;
wire   [1728:0]tree_input1;
wire   [1728:0]tree_input2;
wire   [1728:0]tree_input3;
wire   [1728:0]tree_input4;
wire   [1728:0]tree_input5;
wire   [1728:0]tree_input6;
wire   [1728:0]tree_input7;
wire   [1728:0]tree_input8;
wire   [1728:0]tree_input9;
wire   [1728:0]tree_input10;
wire   [1728:0]tree_input11;
wire   [1728:0]tree_input12;
wire   [1728:0]tree_input13;
wire   [1728:0]tree_input14;
wire   [1728:0]tree_input15;
wire   [1728:0]tree_input16;
wire   [1728:0]tree_input17;

wire           clsf_result3;
wire           clsf_result4;
wire           clsf_result5;
wire           clsf_result6;
wire           clsf_result7;
wire           clsf_result8;
wire           clsf_result9;
wire           clsf_result10;
wire           clsf_result11;
wire           clsf_result12;
wire           clsf_result13;
wire           clsf_result14;
wire           clsf_result15;
wire           clsf_result16;
wire           clsf_result17;

assign         clsf_result_mul = 1'b0;
//assign         clsf_result_mul = clsf_result3 & clsf_result4 & clsf_result5 & clsf_result6 & clsf_result7 & clsf_result8 & clsf_result9 & clsf_result10 & clsf_result11 & clsf_result12 & clsf_result13 & clsf_result14 & clsf_result15 & clsf_result16 & clsf_result17;
//assign         clsf_result_mul = clsf_result3 & clsf_result4 & clsf_result5;
//wire   [46655:0]tree_input0;
//wire   [46655:0]tree_input1;
//wire   [46655:0]tree_input2;

assign  clsf_result1 = 1'b0;
assign  clsf_result2 = 1'b0;



//*************************************************************************//

assign  tree_input0 = {data_in, 1'b0};


lut_5level_tree0 u_lut_5level_tree0(
                                 .rx_fifo_clock  (rx_fifo_clock ),
                                 .rx_fifo_resetn (rx_fifo_resetn),
                                 .data_in        (tree_input0    ),
                                 .data_valid     (data_valid    ),
                                 .data_out       (clsf_result0   )
                                 );

//lut_5level_tree1 u_lut_5level_tree1(
//                                 .rx_fifo_clock  (rx_fifo_clock ),
//                                 .rx_fifo_resetn (rx_fifo_resetn),
//                                 .data_in        (tree_input1    ),
//                                 .data_valid     (data_valid    ),
//                                 .data_out       (clsf_result1   )
//                                 );
//
//lut_5level_tree2 u_lut_5level_tree2(
//                                 .rx_fifo_clock  (rx_fifo_clock ),
//                                 .rx_fifo_resetn (rx_fifo_resetn),
//                                 .data_in        (tree_input2    ),
//                                 .data_valid     (data_valid    ),
//                                 .data_out       (clsf_result2   )
//                                 );
//
//
//lut_5level_tree3 u_lut_5level_tree3(
//                                 .rx_fifo_clock  (rx_fifo_clock ),
//                                 .rx_fifo_resetn (rx_fifo_resetn),
//                                 .data_in        (tree_input3    ),
//                                 .data_valid     (data_valid    ),
//                                 .data_out       (clsf_result3   )
//                                 );
//lut_5level_tree4 u_lut_5level_tree4(
//                                 .rx_fifo_clock  (rx_fifo_clock ),
//                                 .rx_fifo_resetn (rx_fifo_resetn),
//                                 .data_in        (tree_input4    ),
//                                 .data_valid     (data_valid    ),
//                                 .data_out       (clsf_result4   )
//                                 );
//lut_5level_tree5 u_lut_5level_tree5(
//                                 .rx_fifo_clock  (rx_fifo_clock ),
//                                 .rx_fifo_resetn (rx_fifo_resetn),
//                                 .data_in        (tree_input5    ),
//                                 .data_valid     (data_valid    ),
//                                 .data_out       (clsf_result5   )
//                                 );
//lut_5level_tree6 u_lut_5level_tree6(
//                                 .rx_fifo_clock  (rx_fifo_clock ),
//                                 .rx_fifo_resetn (rx_fifo_resetn),
//                                 .data_in        (tree_input6    ),
//                                 .data_valid     (data_valid    ),
//                                 .data_out       (clsf_result6   )
//                                 );
//lut_5level_tree7 u_lut_5level_tree7(
//                                 .rx_fifo_clock  (rx_fifo_clock ),
//                                 .rx_fifo_resetn (rx_fifo_resetn),
//                                 .data_in        (tree_input7    ),
//                                 .data_valid     (data_valid    ),
//                                 .data_out       (clsf_result7   )
//                                 );
//lut_5level_tree8 u_lut_5level_tree8(
//                                 .rx_fifo_clock  (rx_fifo_clock ),
//                                 .rx_fifo_resetn (rx_fifo_resetn),
//                                 .data_in        (tree_input8    ),
//                                 .data_valid     (data_valid    ),
//                                 .data_out       (clsf_result8   )
//                                 );
//lut_5level_tree9 u_lut_5level_tree9(
//                                 .rx_fifo_clock  (rx_fifo_clock ),
//                                 .rx_fifo_resetn (rx_fifo_resetn),
//                                 .data_in        (tree_input9    ),
//                                 .data_valid     (data_valid    ),
//                                 .data_out       (clsf_result9   )
//                                 );
//lut_5level_tree10 u_lut_5level_tree10(
//                                 .rx_fifo_clock  (rx_fifo_clock ),
//                                 .rx_fifo_resetn (rx_fifo_resetn),
//                                 .data_in        (tree_input10    ),
//                                 .data_valid     (data_valid    ),
//                                 .data_out       (clsf_result10   )
//                                 );
//lut_5level_tree11 u_lut_5level_tree11(
//                                 .rx_fifo_clock  (rx_fifo_clock ),
//                                 .rx_fifo_resetn (rx_fifo_resetn),
//                                 .data_in        (tree_input11    ),
//                                 .data_valid     (data_valid    ),
//                                 .data_out       (clsf_result11   )
//                                 );
//lut_5level_tree12 u_lut_5level_tree12(
//                                 .rx_fifo_clock  (rx_fifo_clock ),
//                                 .rx_fifo_resetn (rx_fifo_resetn),
//                                 .data_in        (tree_input12    ),
//                                 .data_valid     (data_valid    ),
//                                 .data_out       (clsf_result12   )
//                                 );
//lut_5level_tree13 u_lut_5level_tree13(
//                                 .rx_fifo_clock  (rx_fifo_clock ),
//                                 .rx_fifo_resetn (rx_fifo_resetn),
//                                 .data_in        (tree_input13    ),
//                                 .data_valid     (data_valid    ),
//                                 .data_out       (clsf_result13   )
//                                 );
//lut_5level_tree14 u_lut_5level_tree14(
//                                 .rx_fifo_clock  (rx_fifo_clock ),
//                                 .rx_fifo_resetn (rx_fifo_resetn),
//                                 .data_in        (tree_input14    ),
//                                 .data_valid     (data_valid    ),
//                                 .data_out       (clsf_result14   )
//                                 );
//lut_5level_tree15 u_lut_5level_tree15(
//                                 .rx_fifo_clock  (rx_fifo_clock ),
//                                 .rx_fifo_resetn (rx_fifo_resetn),
//                                 .data_in        (tree_input15    ),
//                                 .data_valid     (data_valid    ),
//                                 .data_out       (clsf_result15   )
//                                 );
//lut_5level_tree16 u_lut_5level_tree16(
//                                 .rx_fifo_clock  (rx_fifo_clock ),
//                                 .rx_fifo_resetn (rx_fifo_resetn),
//                                 .data_in        (tree_input16    ),
//                                 .data_valid     (data_valid    ),
//                                 .data_out       (clsf_result16   )
//                                 );
//lut_5level_tree17 u_lut_5level_tree17(
//                                 .rx_fifo_clock  (rx_fifo_clock ),
//                                 .rx_fifo_resetn (rx_fifo_resetn),
//                                 .data_in        (tree_input17    ),
//                                 .data_valid     (data_valid    ),
//                                 .data_out       (clsf_result17   )
//                                 );


endmodule
                   