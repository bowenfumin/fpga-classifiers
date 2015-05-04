/*


*/


module   clsf_tree #(parameter TreeInputWidth = 576)
                   (
                   input               rx_fifo_clock,
                   input               rx_fifo_resetn,
                   input       [TreeInputWidth-1:0] data_in,
//                   input       [1535:0] data_in,
                   input               data_valid,
                   output    [7:0]     result_data
                   
                   );
                   
wire   [TreeInputWidth:0]tree_input0;

wire clsf_result0;
wire clsf_result1;
wire clsf_result2;
wire clsf_result3;
wire clsf_result4;
wire clsf_result5;
wire clsf_result6;
wire clsf_result7;

assign  result_data = {clsf_result7,clsf_result6,clsf_result5, clsf_result4,clsf_result3,clsf_result2,clsf_result1,clsf_result0};

//*************************************************************************//

assign  tree_input0 = {data_in, 1'b0};


lut_5level_tree0 u_lut_5level_tree0(
                                 .rx_fifo_clock  (rx_fifo_clock ),
                                 .rx_fifo_resetn (rx_fifo_resetn),
                                 .data_in        (tree_input0    ),
                                 .data_valid     (data_valid    ),
                                 .data_out       (clsf_result0   )
                                 );


lut_5level_tree1 u_lut_5level_tree1(
                                 .rx_fifo_clock  (rx_fifo_clock ),
                                 .rx_fifo_resetn (rx_fifo_resetn),
                                 .data_in        (tree_input0    ),
                                 .data_valid     (data_valid    ),
                                 .data_out       (clsf_result1   )
                                 );

lut_5level_tree2 u_lut_5level_tree2(
                                 .rx_fifo_clock  (rx_fifo_clock ),
                                 .rx_fifo_resetn (rx_fifo_resetn),
                                 .data_in        (tree_input0    ),
                                 .data_valid     (data_valid    ),
                                 .data_out       (clsf_result2   )
                                 );

lut_5level_tree3 u_lut_5level_tree3(
                                 .rx_fifo_clock  (rx_fifo_clock ),
                                 .rx_fifo_resetn (rx_fifo_resetn),
                                 .data_in        (tree_input0    ),
                                 .data_valid     (data_valid    ),
                                 .data_out       (clsf_result3   )
                                 );
lut_5level_tree4 u_lut_5level_tree4(
                                 .rx_fifo_clock  (rx_fifo_clock ),
                                 .rx_fifo_resetn (rx_fifo_resetn),
                                 .data_in        (tree_input0    ),
                                 .data_valid     (data_valid    ),
                                 .data_out       (clsf_result4   )
                                 );

lut_5level_tree5 u_lut_5level_tree5(
                                 .rx_fifo_clock  (rx_fifo_clock ),
                                 .rx_fifo_resetn (rx_fifo_resetn),
                                 .data_in        (tree_input0    ),
                                 .data_valid     (data_valid    ),
                                 .data_out       (clsf_result5   )
                                 );

lut_5level_tree6 u_lut_5level_tree6(
                                 .rx_fifo_clock  (rx_fifo_clock ),
                                 .rx_fifo_resetn (rx_fifo_resetn),
                                 .data_in        (tree_input0    ),
                                 .data_valid     (data_valid    ),
                                 .data_out       (clsf_result6   )
                                 );
lut_5level_tree7 u_lut_5level_tree7(
                                 .rx_fifo_clock  (rx_fifo_clock ),
                                 .rx_fifo_resetn (rx_fifo_resetn),
                                 .data_in        (tree_input0    ),
                                 .data_valid     (data_valid    ),
                                 .data_out       (clsf_result7   )
                                 );


endmodule
                   