////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: P.68d
//  \   \         Application: netgen
//  /   /         Filename: shift_reg.v
// /___/   /\     Timestamp: Wed Aug 27 16:33:40 2014
// \   \  /  \ 
//  \___\/\___\
//             
// Command	: -w -sim -ofmt verilog E:/study_in_UdeM/project/sim_for_video_evaluation/sim_v7_mac/par/ipcore_dir/tmp/_cg/shift_reg.ngc E:/study_in_UdeM/project/sim_for_video_evaluation/sim_v7_mac/par/ipcore_dir/tmp/_cg/shift_reg.v 
// Device	: 7k325tffg900-2
// Input file	: E:/study_in_UdeM/project/sim_for_video_evaluation/sim_v7_mac/par/ipcore_dir/tmp/_cg/shift_reg.ngc
// Output file	: E:/study_in_UdeM/project/sim_for_video_evaluation/sim_v7_mac/par/ipcore_dir/tmp/_cg/shift_reg.v
// # of Modules	: 1
// Design Name	: shift_reg
// Xilinx        : C:\Xilinx\14.6\ISE_DS\ISE\
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
  input [5 : 0] d;
  output [5 : 0] q;
  
  // synthesis translate_off
  
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
  wire \NLW_blk00000001/blk00000002/blk0000001b_Q31_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk0000001a_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk00000019_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk00000017_Q31_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk00000016_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk00000015_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk00000013_Q31_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk00000012_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk00000011_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk0000000f_Q31_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk0000000e_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk0000000d_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk0000000b_Q31_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk0000000a_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk00000009_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk00000007_Q31_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk00000006_Q_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000002/blk00000005_Q_UNCONNECTED ;
  FDE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000002/blk0000001c  (
    .C(clk),
    .CE(\blk00000001/blk00000002/sig0000001c ),
    .D(\blk00000001/blk00000002/sig0000002e ),
    .Q(q[4])
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk0000001b  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig0000002d ),
    .CE(\blk00000001/blk00000002/sig0000001c ),
    .Q(\blk00000001/blk00000002/sig0000002e ),
    .Q31(\NLW_blk00000001/blk00000002/blk0000001b_Q31_UNCONNECTED ),
    .A({\blk00000001/blk00000002/sig0000001b , \blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c , 
\blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001b })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk0000001a  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig0000002c ),
    .CE(\blk00000001/blk00000002/sig0000001c ),
    .Q(\NLW_blk00000001/blk00000002/blk0000001a_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig0000002d ),
    .A({\blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c , 
\blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000019  (
    .CLK(clk),
    .D(d[4]),
    .CE(\blk00000001/blk00000002/sig0000001c ),
    .Q(\NLW_blk00000001/blk00000002/blk00000019_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig0000002c ),
    .A({\blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c , 
\blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c })
  );
  FDE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000002/blk00000018  (
    .C(clk),
    .CE(\blk00000001/blk00000002/sig0000001c ),
    .D(\blk00000001/blk00000002/sig0000002b ),
    .Q(q[3])
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000017  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig0000002a ),
    .CE(\blk00000001/blk00000002/sig0000001c ),
    .Q(\blk00000001/blk00000002/sig0000002b ),
    .Q31(\NLW_blk00000001/blk00000002/blk00000017_Q31_UNCONNECTED ),
    .A({\blk00000001/blk00000002/sig0000001b , \blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c , 
\blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001b })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000016  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig00000029 ),
    .CE(\blk00000001/blk00000002/sig0000001c ),
    .Q(\NLW_blk00000001/blk00000002/blk00000016_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig0000002a ),
    .A({\blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c , 
\blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000015  (
    .CLK(clk),
    .D(d[3]),
    .CE(\blk00000001/blk00000002/sig0000001c ),
    .Q(\NLW_blk00000001/blk00000002/blk00000015_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig00000029 ),
    .A({\blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c , 
\blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c })
  );
  FDE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000002/blk00000014  (
    .C(clk),
    .CE(\blk00000001/blk00000002/sig0000001c ),
    .D(\blk00000001/blk00000002/sig00000028 ),
    .Q(q[5])
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000013  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig00000027 ),
    .CE(\blk00000001/blk00000002/sig0000001c ),
    .Q(\blk00000001/blk00000002/sig00000028 ),
    .Q31(\NLW_blk00000001/blk00000002/blk00000013_Q31_UNCONNECTED ),
    .A({\blk00000001/blk00000002/sig0000001b , \blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c , 
\blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001b })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000012  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig00000026 ),
    .CE(\blk00000001/blk00000002/sig0000001c ),
    .Q(\NLW_blk00000001/blk00000002/blk00000012_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig00000027 ),
    .A({\blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c , 
\blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000011  (
    .CLK(clk),
    .D(d[5]),
    .CE(\blk00000001/blk00000002/sig0000001c ),
    .Q(\NLW_blk00000001/blk00000002/blk00000011_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig00000026 ),
    .A({\blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c , 
\blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c })
  );
  FDE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000002/blk00000010  (
    .C(clk),
    .CE(\blk00000001/blk00000002/sig0000001c ),
    .D(\blk00000001/blk00000002/sig00000025 ),
    .Q(q[1])
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk0000000f  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig00000024 ),
    .CE(\blk00000001/blk00000002/sig0000001c ),
    .Q(\blk00000001/blk00000002/sig00000025 ),
    .Q31(\NLW_blk00000001/blk00000002/blk0000000f_Q31_UNCONNECTED ),
    .A({\blk00000001/blk00000002/sig0000001b , \blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c , 
\blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001b })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk0000000e  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig00000023 ),
    .CE(\blk00000001/blk00000002/sig0000001c ),
    .Q(\NLW_blk00000001/blk00000002/blk0000000e_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig00000024 ),
    .A({\blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c , 
\blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk0000000d  (
    .CLK(clk),
    .D(d[1]),
    .CE(\blk00000001/blk00000002/sig0000001c ),
    .Q(\NLW_blk00000001/blk00000002/blk0000000d_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig00000023 ),
    .A({\blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c , 
\blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c })
  );
  FDE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000002/blk0000000c  (
    .C(clk),
    .CE(\blk00000001/blk00000002/sig0000001c ),
    .D(\blk00000001/blk00000002/sig00000022 ),
    .Q(q[0])
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk0000000b  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig00000021 ),
    .CE(\blk00000001/blk00000002/sig0000001c ),
    .Q(\blk00000001/blk00000002/sig00000022 ),
    .Q31(\NLW_blk00000001/blk00000002/blk0000000b_Q31_UNCONNECTED ),
    .A({\blk00000001/blk00000002/sig0000001b , \blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c , 
\blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001b })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk0000000a  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig00000020 ),
    .CE(\blk00000001/blk00000002/sig0000001c ),
    .Q(\NLW_blk00000001/blk00000002/blk0000000a_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig00000021 ),
    .A({\blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c , 
\blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000009  (
    .CLK(clk),
    .D(d[0]),
    .CE(\blk00000001/blk00000002/sig0000001c ),
    .Q(\NLW_blk00000001/blk00000002/blk00000009_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig00000020 ),
    .A({\blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c , 
\blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c })
  );
  FDE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000002/blk00000008  (
    .C(clk),
    .CE(\blk00000001/blk00000002/sig0000001c ),
    .D(\blk00000001/blk00000002/sig0000001f ),
    .Q(q[2])
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000007  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig0000001e ),
    .CE(\blk00000001/blk00000002/sig0000001c ),
    .Q(\blk00000001/blk00000002/sig0000001f ),
    .Q31(\NLW_blk00000001/blk00000002/blk00000007_Q31_UNCONNECTED ),
    .A({\blk00000001/blk00000002/sig0000001b , \blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c , 
\blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001b })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000006  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig0000001d ),
    .CE(\blk00000001/blk00000002/sig0000001c ),
    .Q(\NLW_blk00000001/blk00000002/blk00000006_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig0000001e ),
    .A({\blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c , 
\blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000005  (
    .CLK(clk),
    .D(d[2]),
    .CE(\blk00000001/blk00000002/sig0000001c ),
    .Q(\NLW_blk00000001/blk00000002/blk00000005_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig0000001d ),
    .A({\blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c , 
\blk00000001/blk00000002/sig0000001c , \blk00000001/blk00000002/sig0000001c })
  );
  VCC   \blk00000001/blk00000002/blk00000004  (
    .P(\blk00000001/blk00000002/sig0000001c )
  );
  GND   \blk00000001/blk00000002/blk00000003  (
    .G(\blk00000001/blk00000002/sig0000001b )
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
