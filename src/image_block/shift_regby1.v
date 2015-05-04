////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: P.68d
//  \   \         Application: netgen
//  /   /         Filename: shift_regby1.v
// /___/   /\     Timestamp: Sun Jan 18 11:26:18 2015
// \   \  /  \ 
//  \___\/\___\
//             
// Command	: -w -sim -ofmt verilog E:/study_in_UdeM/project/sim_for_video_evaluation/sim_v16_macddr/par/ipcore_dir/tmp/_cg/shift_regby1.ngc E:/study_in_UdeM/project/sim_for_video_evaluation/sim_v16_macddr/par/ipcore_dir/tmp/_cg/shift_regby1.v 
// Device	: 7k325tffg900-2
// Input file	: E:/study_in_UdeM/project/sim_for_video_evaluation/sim_v16_macddr/par/ipcore_dir/tmp/_cg/shift_regby1.ngc
// Output file	: E:/study_in_UdeM/project/sim_for_video_evaluation/sim_v16_macddr/par/ipcore_dir/tmp/_cg/shift_regby1.v
// # of Modules	: 1
// Design Name	: shift_regby1
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

module shift_regby1 (
  clk, ce, d, q
)/* synthesis syn_black_box syn_noprune=1 */;
  input clk;
  input ce;
  input [0 : 0] d;
  output [0 : 0] q;
  
  // synthesis translate_off
  
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
  wire \blk00000001/blk00000002/sig0000000a ;
  wire \blk00000001/blk00000002/sig00000009 ;
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
  \blk00000001/blk00000002/blk0000001d  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/blk00000002/sig00000022 ),
    .Q(q[0])
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk0000001c  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig00000021 ),
    .CE(ce),
    .Q(\blk00000001/blk00000002/sig00000022 ),
    .Q31(\NLW_blk00000001/blk00000002/blk0000001c_Q31_UNCONNECTED ),
    .A({\blk00000001/blk00000002/sig0000000d , \blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e , 
\blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000d })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk0000001b  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig00000020 ),
    .CE(ce),
    .Q(\NLW_blk00000001/blk00000002/blk0000001b_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig00000021 ),
    .A({\blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e , 
\blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk0000001a  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig0000001f ),
    .CE(ce),
    .Q(\NLW_blk00000001/blk00000002/blk0000001a_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig00000020 ),
    .A({\blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e , 
\blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000019  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig0000000b ),
    .CE(ce),
    .Q(\NLW_blk00000001/blk00000002/blk00000019_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig0000001f ),
    .A({\blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e , 
\blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e })
  );
  FDE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000002/blk00000018  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/blk00000002/sig0000001e ),
    .Q(\blk00000001/blk00000002/sig0000000b )
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000017  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig0000001d ),
    .CE(ce),
    .Q(\blk00000001/blk00000002/sig0000001e ),
    .Q31(\NLW_blk00000001/blk00000002/blk00000017_Q31_UNCONNECTED ),
    .A({\blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e , 
\blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000016  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig0000001c ),
    .CE(ce),
    .Q(\NLW_blk00000001/blk00000002/blk00000016_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig0000001d ),
    .A({\blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e , 
\blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000015  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig0000001b ),
    .CE(ce),
    .Q(\NLW_blk00000001/blk00000002/blk00000015_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig0000001c ),
    .A({\blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e , 
\blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000014  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig0000000a ),
    .CE(ce),
    .Q(\NLW_blk00000001/blk00000002/blk00000014_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig0000001b ),
    .A({\blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e , 
\blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e })
  );
  FDE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000002/blk00000013  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/blk00000002/sig0000001a ),
    .Q(\blk00000001/blk00000002/sig0000000a )
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000012  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig00000019 ),
    .CE(ce),
    .Q(\blk00000001/blk00000002/sig0000001a ),
    .Q31(\NLW_blk00000001/blk00000002/blk00000012_Q31_UNCONNECTED ),
    .A({\blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e , 
\blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000011  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig00000018 ),
    .CE(ce),
    .Q(\NLW_blk00000001/blk00000002/blk00000011_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig00000019 ),
    .A({\blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e , 
\blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000010  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig00000017 ),
    .CE(ce),
    .Q(\NLW_blk00000001/blk00000002/blk00000010_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig00000018 ),
    .A({\blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e , 
\blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk0000000f  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig00000009 ),
    .CE(ce),
    .Q(\NLW_blk00000001/blk00000002/blk0000000f_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig00000017 ),
    .A({\blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e , 
\blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e })
  );
  FDE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000002/blk0000000e  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/blk00000002/sig00000016 ),
    .Q(\blk00000001/blk00000002/sig00000009 )
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk0000000d  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig00000015 ),
    .CE(ce),
    .Q(\blk00000001/blk00000002/sig00000016 ),
    .Q31(\NLW_blk00000001/blk00000002/blk0000000d_Q31_UNCONNECTED ),
    .A({\blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e , 
\blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk0000000c  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig00000014 ),
    .CE(ce),
    .Q(\NLW_blk00000001/blk00000002/blk0000000c_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig00000015 ),
    .A({\blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e , 
\blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk0000000b  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig00000013 ),
    .CE(ce),
    .Q(\NLW_blk00000001/blk00000002/blk0000000b_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig00000014 ),
    .A({\blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e , 
\blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk0000000a  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig0000000c ),
    .CE(ce),
    .Q(\NLW_blk00000001/blk00000002/blk0000000a_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig00000013 ),
    .A({\blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e , 
\blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e })
  );
  FDE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000002/blk00000009  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/blk00000002/sig00000012 ),
    .Q(\blk00000001/blk00000002/sig0000000c )
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000008  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig00000011 ),
    .CE(ce),
    .Q(\blk00000001/blk00000002/sig00000012 ),
    .Q31(\NLW_blk00000001/blk00000002/blk00000008_Q31_UNCONNECTED ),
    .A({\blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e , 
\blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000007  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig00000010 ),
    .CE(ce),
    .Q(\NLW_blk00000001/blk00000002/blk00000007_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig00000011 ),
    .A({\blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e , 
\blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000006  (
    .CLK(clk),
    .D(\blk00000001/blk00000002/sig0000000f ),
    .CE(ce),
    .Q(\NLW_blk00000001/blk00000002/blk00000006_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig00000010 ),
    .A({\blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e , 
\blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e })
  );
  SRLC32E #(
    .INIT ( 32'h00000000 ))
  \blk00000001/blk00000002/blk00000005  (
    .CLK(clk),
    .D(d[0]),
    .CE(ce),
    .Q(\NLW_blk00000001/blk00000002/blk00000005_Q_UNCONNECTED ),
    .Q31(\blk00000001/blk00000002/sig0000000f ),
    .A({\blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e , 
\blk00000001/blk00000002/sig0000000e , \blk00000001/blk00000002/sig0000000e })
  );
  VCC   \blk00000001/blk00000002/blk00000004  (
    .P(\blk00000001/blk00000002/sig0000000e )
  );
  GND   \blk00000001/blk00000002/blk00000003  (
    .G(\blk00000001/blk00000002/sig0000000d )
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
