////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: P.68d
//  \   \         Application: netgen
//  /   /         Filename: shift_reg.v
// /___/   /\     Timestamp: Thu Dec 04 15:07:20 2014
// \   \  /  \ 
//  \___\/\___\
//             
// Command	: -w -sim -ofmt verilog E:/study_in_UdeM/project/sim_for_video_evaluation/sim_v15_macddr/par/ipcore_dir/tmp/_cg/shift_reg.ngc E:/study_in_UdeM/project/sim_for_video_evaluation/sim_v15_macddr/par/ipcore_dir/tmp/_cg/shift_reg.v 
// Device	: 7k325tffg900-2
// Input file	: E:/study_in_UdeM/project/sim_for_video_evaluation/sim_v15_macddr/par/ipcore_dir/tmp/_cg/shift_reg.ngc
// Output file	: E:/study_in_UdeM/project/sim_for_video_evaluation/sim_v15_macddr/par/ipcore_dir/tmp/_cg/shift_reg.v
// # of Modules	: 1
// Design Name	: shift_reg
// Xilinx        : F:\Xilinx\14.6\ISE_DS\ISE\
//             
// Purpose:    
//     This verilog netlist is a verification model and uses simulation 
//     primitives which may not represent the true implementation of the 
//     device, however the netlist is functionally correct and should not 
//     be modified. This file cannot be synthesized and should only be used 
//     with supported simulation tools.
//             
// Reference:  
//     Command Line Tools User Guide, Chapter 23 and Synthesis and Simulation Design Guide, Chapter 6
//             
////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns/1 ps

module shift_reg (
  clk, d, q
)/* synthesis syn_black_box syn_noprune=1 */;
  input clk;
  input [1 : 0] d;
  output [1 : 0] q;
  
  // synthesis translate_off
  
  wire \blk00000001/blk00000002/sig0000003c ;
  wire \blk00000001/blk00000002/sig0000003b ;
  wire \blk00000001/blk00000002/sig0000003a ;
  wire \blk00000001/blk00000002/sig00000039 ;
  wire \blk00000001/blk00000002/sig00000038 ;
  wire \blk00000001/blk00000002/sig00000037 ;
  wire \blk00000001/blk00000002/sig00000036 ;
  wire \blk00000001/blk00000002/sig00000035 ;
  wire \blk00000001/blk00000002/sig00000034 ;
  wire \blk00000001/blk00000002/sig00000033 ;
  wire \blk00000001/blk00000002/sig00000032 ;
  wire \blk00000001/blk00000002/sig00000031 ;
  wire \blk00000001/blk00000002/sig00000030 ;
  wire \blk00000001/blk00000002/sig0000002f ;
  wire \blk00000001/blk00000002/sig0000002e ;
  wire \blk00000001/blk00000002/sig0000002d ;
  wire \blk00000001/blk00000002/sig0000002c ;
  wire \blk00000001/blk00000002/sig0000002b ;
  wire \blk00000001/blk00000002/sig0000002a ;
  wire \blk00000001/blk00000002/sig00000029 ;
  wire \blk00000001/blk00000002/sig00000028 ;
  wire \blk00000001/blk00000002/sig00000027 ;
  wire \blk00000001/blk00000002/sig00000026 ;
  wire \blk00000001/blk00000002/sig00000025 ;
  wire \blk00000001/blk00000002/sig00000024 ;
  wire \blk00000001/blk00000002/sig00000023 ;
  wire \blk00000001/blk00000002/sig00000022 ;
  wire \blk00000001/blk00000002/sig00000021 ;
  wire \blk00000001/blk00000002/sig00000020 ;
  wire \blk00000001/blk00000002/sig0000001f ;
  wire \blk00000001/blk00000002/sig0000001e ;
  wire \blk00000001/blk00000002/sig0000001d ;
  wire \blk00000001/blk00000002/sig0000001c ;
  wire \blk00000001/blk00000002/sig0000001b ;
  wire \blk00000001/blk00000002/sig0000001a ;
  wire \blk00000001/blk00000002/sig00000019 ;
  wire \blk00000001/blk00000002/sig00000018 ;
  wire \blk00000001/blk00000002/sig00000017 ;
  wire \blk00000001/blk00000002/sig00000016 ;
  wire \blk00000001/blk00000002/sig00000015 ;
  wire \blk00000001/blk00000002/sig00000014 ;
  wire \blk00000001/blk00000002/sig00000013 ;
  wire \blk00000001/blk00000002/sig00000012 ;
  wire \blk00000001/blk00000002/sig00000011 ;
  wire \blk00000001/blk00000002/sig00000010 ;
  wire \blk00000001/blk00000002/sig0000000f ;
  wire \blk00000001/blk00000002/sig0000000e ;
  wire \blk00000001/blk00000002/sig0000000d ;
  wire \blk00000001/blk00000002/sig0000000c ;
  wire \blk00000001/blk00000002/sig0000000b ;
  wire \NLW_blk00000001/blk00000002/blk00000035_Q31_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk00000034_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk00000033_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk00000032_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk00000030_Q31_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk0000002f_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk0000002e_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk0000002d_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk0000002b_Q31_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk0000002a_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk00000029_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk00000028_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk00000026_Q31_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk00000025_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk00000024_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk00000023_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk00000021_Q31_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk00000020_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk0000001f_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk0000001e_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk0000001c_Q31_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk0000001b_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk0000001a_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk00000019_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk00000017_Q31_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk00000016_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk00000015_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk00000014_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk00000012_Q31_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk00000011_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk00000010_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk0000000f_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk0000000d_Q31_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk0000000c_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk0000000b_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk0000000a_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk00000008_Q31_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk00000007_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk00000006_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk00000005_Q_UNCONNECTED ;
  FDE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000002/blk00000036  (
    .C(clk),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .D(\blk00000001/blk00000002/sig0000003c ),
    .Q(q[1])
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000035  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig0000003b ),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\blk00000001/blk00000002/sig0000003c ),
    .Q31(\NLW_blk00000001/blk00000002/blk00000035_Q31_UNCONNECTED ),
    .A({\blk00000001/blk00000002/sig00000013 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000013 })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000034  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig0000003a ),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\NLW_blk00000001/blk00000002/blk00000034_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig0000003b ),
    .A({\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000033  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig00000039 ),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\NLW_blk00000001/blk00000002/blk00000033_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig0000003a ),
    .A({\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000032  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig00000011 ),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\NLW_blk00000001/blk00000002/blk00000032_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig00000039 ),
    .A({\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 })
  );
  FDE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000002/blk00000031  (
    .C(clk),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .D(\blk00000001/blk00000002/sig00000038 ),
    .Q(q[0])
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000030  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig00000037 ),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\blk00000001/blk00000002/sig00000038 ),
    .Q31(\NLW_blk00000001/blk00000002/blk00000030_Q31_UNCONNECTED ),
    .A({\blk00000001/blk00000002/sig00000013 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000013 })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk0000002f  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig00000036 ),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\NLW_blk00000001/blk00000002/blk0000002f_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig00000037 ),
    .A({\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk0000002e  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig00000035 ),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\NLW_blk00000001/blk00000002/blk0000002e_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig00000036 ),
    .A({\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk0000002d  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig00000010 ),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\NLW_blk00000001/blk00000002/blk0000002d_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig00000035 ),
    .A({\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 })
  );
  FDE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000002/blk0000002c  (
    .C(clk),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .D(\blk00000001/blk00000002/sig00000034 ),
    .Q(\blk00000001/blk00000002/sig00000010 )
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk0000002b  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig00000033 ),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\blk00000001/blk00000002/sig00000034 ),
    .Q31(\NLW_blk00000001/blk00000002/blk0000002b_Q31_UNCONNECTED ),
    .A({\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk0000002a  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig00000032 ),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\NLW_blk00000001/blk00000002/blk0000002a_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig00000033 ),
    .A({\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000029  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig00000031 ),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\NLW_blk00000001/blk00000002/blk00000029_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig00000032 ),
    .A({\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000028  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig0000000e ),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\NLW_blk00000001/blk00000002/blk00000028_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig00000031 ),
    .A({\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 })
  );
  FDE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000002/blk00000027  (
    .C(clk),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .D(\blk00000001/blk00000002/sig00000030 ),
    .Q(\blk00000001/blk00000002/sig00000011 )
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000026  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig0000002f ),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\blk00000001/blk00000002/sig00000030 ),
    .Q31(\NLW_blk00000001/blk00000002/blk00000026_Q31_UNCONNECTED ),
    .A({\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000025  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig0000002e ),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\NLW_blk00000001/blk00000002/blk00000025_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig0000002f ),
    .A({\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000024  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig0000002d ),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\NLW_blk00000001/blk00000002/blk00000024_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig0000002e ),
    .A({\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000023  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig0000000f ),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\NLW_blk00000001/blk00000002/blk00000023_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig0000002d ),
    .A({\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 })
  );
  FDE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000002/blk00000022  (
    .C(clk),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .D(\blk00000001/blk00000002/sig0000002c ),
    .Q(\blk00000001/blk00000002/sig0000000f )
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000021  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig0000002b ),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\blk00000001/blk00000002/sig0000002c ),
    .Q31(\NLW_blk00000001/blk00000002/blk00000021_Q31_UNCONNECTED ),
    .A({\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000020  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig0000002a ),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\NLW_blk00000001/blk00000002/blk00000020_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig0000002b ),
    .A({\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk0000001f  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig00000029 ),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\NLW_blk00000001/blk00000002/blk0000001f_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig0000002a ),
    .A({\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk0000001e  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig0000000d ),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\NLW_blk00000001/blk00000002/blk0000001e_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig00000029 ),
    .A({\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 })
  );
  FDE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000002/blk0000001d  (
    .C(clk),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .D(\blk00000001/blk00000002/sig00000028 ),
    .Q(\blk00000001/blk00000002/sig0000000e )
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk0000001c  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig00000027 ),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\blk00000001/blk00000002/sig00000028 ),
    .Q31(\NLW_blk00000001/blk00000002/blk0000001c_Q31_UNCONNECTED ),
    .A({\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk0000001b  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig00000026 ),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\NLW_blk00000001/blk00000002/blk0000001b_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig00000027 ),
    .A({\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk0000001a  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig00000025 ),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\NLW_blk00000001/blk00000002/blk0000001a_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig00000026 ),
    .A({\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000019  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig0000000c ),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\NLW_blk00000001/blk00000002/blk00000019_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig00000025 ),
    .A({\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 })
  );
  FDE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000002/blk00000018  (
    .C(clk),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .D(\blk00000001/blk00000002/sig00000024 ),
    .Q(\blk00000001/blk00000002/sig0000000c )
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000017  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig00000023 ),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\blk00000001/blk00000002/sig00000024 ),
    .Q31(\NLW_blk00000001/blk00000002/blk00000017_Q31_UNCONNECTED ),
    .A({\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000016  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig00000022 ),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\NLW_blk00000001/blk00000002/blk00000016_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig00000023 ),
    .A({\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000015  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig00000021 ),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\NLW_blk00000001/blk00000002/blk00000015_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig00000022 ),
    .A({\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000014  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig00000012 ),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\NLW_blk00000001/blk00000002/blk00000014_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig00000021 ),
    .A({\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 })
  );
  FDE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000002/blk00000013  (
    .C(clk),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .D(\blk00000001/blk00000002/sig00000020 ),
    .Q(\blk00000001/blk00000002/sig0000000d )
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000012  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig0000001f ),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\blk00000001/blk00000002/sig00000020 ),
    .Q31(\NLW_blk00000001/blk00000002/blk00000012_Q31_UNCONNECTED ),
    .A({\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000011  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig0000001e ),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\NLW_blk00000001/blk00000002/blk00000011_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig0000001f ),
    .A({\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000010  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig0000001d ),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\NLW_blk00000001/blk00000002/blk00000010_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig0000001e ),
    .A({\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk0000000f  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig0000000b ),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\NLW_blk00000001/blk00000002/blk0000000f_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig0000001d ),
    .A({\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 })
  );
  FDE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000002/blk0000000e  (
    .C(clk),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .D(\blk00000001/blk00000002/sig0000001c ),
    .Q(\blk00000001/blk00000002/sig00000012 )
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk0000000d  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig0000001b ),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\blk00000001/blk00000002/sig0000001c ),
    .Q31(\NLW_blk00000001/blk00000002/blk0000000d_Q31_UNCONNECTED ),
    .A({\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk0000000c  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig0000001a ),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\NLW_blk00000001/blk00000002/blk0000000c_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig0000001b ),
    .A({\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk0000000b  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig00000019 ),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\NLW_blk00000001/blk00000002/blk0000000b_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig0000001a ),
    .A({\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk0000000a  (
    .CLK(clk),
    .D(d[0]),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\NLW_blk00000001/blk00000002/blk0000000a_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig00000019 ),
    .A({\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 })
  );
  FDE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000002/blk00000009  (
    .C(clk),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .D(\blk00000001/blk00000002/sig00000018 ),
    .Q(\blk00000001/blk00000002/sig0000000b )
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000008  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig00000017 ),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\blk00000001/blk00000002/sig00000018 ),
    .Q31(\NLW_blk00000001/blk00000002/blk00000008_Q31_UNCONNECTED ),
    .A({\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000007  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig00000016 ),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\NLW_blk00000001/blk00000002/blk00000007_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig00000017 ),
    .A({\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000006  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig00000015 ),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\NLW_blk00000001/blk00000002/blk00000006_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig00000016 ),
    .A({\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000005  (
    .CLK(clk),
    .D(d[1]),
    .CE(\blk00000001/blk00000002/sig00000014 ),
    .Q(\NLW_blk00000001/blk00000002/blk00000005_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig00000015 ),
    .A({\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 , 
\blk00000001/blk00000002/sig00000014 , \blk00000001/blk00000002/sig00000014 })
  );
  VCC   \blk00000001/blk00000002/blk00000004  (
    .P(\blk00000001/blk00000002/sig00000014 )
  );
  GND   \blk00000001/blk00000002/blk00000003  (
    .G(\blk00000001/blk00000002/sig00000013 )
  );

// synthesis translate_on

endmodule

// synthesis translate_off

`ifndef GLBL
`define GLBL

`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;

    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (weak1, weak0) GSR = GSR_int;
    assign (weak1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule

`endif

// synthesis translate_on
