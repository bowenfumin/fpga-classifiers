//*****************************************************************************
// (c) Copyright 2009 - 2013 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor             : Xilinx
// \   \   \/     Version            : 1.9
//  \   \         Application        : MIG
//  /   /         Filename           : example_top.v
// /___/   /\     Date Last Modified : $Date: 2011/06/02 08:35:03 $
// \   \  /  \    Date Created       : Tue Sept 21 2010
//  \___\/\___\
//
// Device           : 7 Series
// Design Name      : DDR3 SDRAM
// Purpose          :
//   Top-level  module. This module serves both as an example,
//   and allows the user to synthesize a self-contained design,
//   which they can be used to test their hardware.
//   In addition to the memory controller, the module instantiates:
//     1. Synthesizable testbench - used to model user's backend logic
//        and generate different traffic patterns
// Reference        :
// Revision History :
//*****************************************************************************

`timescale 1ps/1ps

module example_top #
  (

   //***************************************************************************
   // Traffic Gen related parameters
   //***************************************************************************
   parameter BL_WIDTH              = 10,
   parameter PORT_MODE             = "BI_MODE",
   parameter DATA_MODE             = 4'b0010,
   parameter ADDR_MODE             = 4'b0011,
   parameter TST_MEM_INSTR_MODE    = "R_W_INSTR_MODE",
   parameter EYE_TEST              = "FALSE",
                                     // set EYE_TEST = "TRUE" to probe memory
                                     // signals. Traffic Generator will only
                                     // write to one single location and no
                                     // read transactions will be generated.
   parameter DATA_PATTERN          = "DGEN_ALL",
                                      // For small devices, choose one only.
                                      // For large device, choose "DGEN_ALL"
                                      // "DGEN_HAMMER", "DGEN_WALKING1",
                                      // "DGEN_WALKING0","DGEN_ADDR","
                                      // "DGEN_NEIGHBOR","DGEN_PRBS","DGEN_ALL"
   parameter CMD_PATTERN           = "CGEN_ALL",
                                      // "CGEN_PRBS","CGEN_FIXED","CGEN_BRAM",
                                      // "CGEN_SEQUENTIAL", "CGEN_ALL"
   parameter BEGIN_ADDRESS         = 32'h00000000,
   parameter END_ADDRESS           = 32'h00ffffff,
   parameter MEM_ADDR_ORDER
     = "TG_TEST",
   parameter PRBS_EADDR_MASK_POS   = 32'hff000000,
   parameter CMD_WDT               = 'h3FF,
   parameter WR_WDT                = 'h1FFF,
   parameter RD_WDT                = 'h3FF,
   parameter SEL_VICTIM_LINE       = 0,

   //***************************************************************************
   // The following parameters refer to width of various ports
   //***************************************************************************
   parameter BANK_WIDTH            = 3,
                                     // # of memory Bank Address bits.
   parameter CK_WIDTH              = 1,
                                     // # of CK/CK# outputs to memory.
   parameter COL_WIDTH             = 10,
                                     // # of memory Column Address bits.
   parameter CS_WIDTH              = 1,
                                     // # of unique CS outputs to memory.
   parameter nCS_PER_RANK          = 1,
                                     // # of unique CS outputs per rank for phy
   parameter CKE_WIDTH             = 1,
                                     // # of CKE outputs to memory.
   parameter DATA_BUF_ADDR_WIDTH   = 5,
   parameter DQ_CNT_WIDTH          = 6,
                                     // = ceil(log2(DQ_WIDTH))
   parameter DQ_PER_DM             = 8,
   parameter DM_WIDTH              = 8,
                                     // # of DM (data mask)
   parameter DQ_WIDTH              = 64,
                                     // # of DQ (data)
   parameter DQS_WIDTH             = 8,
   parameter DQS_CNT_WIDTH         = 3,
                                     // = ceil(log2(DQS_WIDTH))
   parameter DRAM_WIDTH            = 8,
                                     // # of DQ per DQS
   parameter ECC                   = "OFF",
   parameter nBANK_MACHS           = 4,
   parameter RANKS                 = 1,
                                     // # of Ranks.
   parameter ODT_WIDTH             = 1,
                                     // # of ODT outputs to memory.
   parameter ROW_WIDTH             = 14,
                                     // # of memory Row Address bits.
   parameter ADDR_WIDTH            = 28,
                                     // # = RANK_WIDTH + BANK_WIDTH
                                     //     + ROW_WIDTH + COL_WIDTH;
                                     // Chip Select is always tied to low for
                                     // single rank devices
   parameter USE_CS_PORT          = 1,
                                     // # = 1, When Chip Select (CS#) output is enabled
                                     //   = 0, When Chip Select (CS#) output is disabled
                                     // If CS_N disabled, user must connect
                                     // DRAM CS_N input(s) to ground
   parameter USE_DM_PORT           = 1,
                                     // # = 1, When Data Mask option is enabled
                                     //   = 0, When Data Mask option is disbaled
                                     // When Data Mask option is disabled in
                                     // MIG Controller Options page, the logic
                                     // related to Data Mask should not get
                                     // synthesized
   parameter USE_ODT_PORT          = 1,
                                     // # = 1, When ODT output is enabled
                                     //   = 0, When ODT output is disabled
                                     // Parameter configuration for Dynamic ODT support:
                                     // USE_ODT_PORT = 0, RTT_NOM = "DISABLED", RTT_WR = "60/120".
                                     // This configuration allows to save ODT pin mapping from FPGA.
                                     // The user can tie the ODT input of DRAM to HIGH.
   parameter PHY_CONTROL_MASTER_BANK = 1,
                                     // The bank index where master PHY_CONTROL resides,
                                     // equal to the PLL residing bank
   parameter MEM_DENSITY           = "1Gb",
                                     // Indicates the density of the Memory part
                                     // Added for the sake of Vivado simulations
   parameter MEM_SPEEDGRADE        = "125",
                                     // Indicates the Speed grade of Memory Part
                                     // Added for the sake of Vivado simulations
   parameter MEM_DEVICE_WIDTH      = 8,
                                     // Indicates the device width of the Memory Part
                                     // Added for the sake of Vivado simulations

   //***************************************************************************
   // The following parameters are mode register settings
   //***************************************************************************
   parameter AL                    = "0",
                                     // DDR3 SDRAM:
                                     // Additive Latency (Mode Register 1).
                                     // # = "0", "CL-1", "CL-2".
                                     // DDR2 SDRAM:
                                     // Additive Latency (Extended Mode Register).
   parameter nAL                   = 0,
                                     // # Additive Latency in number of clock
                                     // cycles.
   parameter BURST_MODE            = "8",
                                     // DDR3 SDRAM:
                                     // Burst Length (Mode Register 0).
                                     // # = "8", "4", "OTF".
                                     // DDR2 SDRAM:
                                     // Burst Length (Mode Register).
                                     // # = "8", "4".
   parameter BURST_TYPE            = "SEQ",
                                     // DDR3 SDRAM: Burst Type (Mode Register 0).
                                     // DDR2 SDRAM: Burst Type (Mode Register).
                                     // # = "SEQ" - (Sequential),
                                     //   = "INT" - (Interleaved).
   parameter CL                    = 11,
                                     // in number of clock cycles
                                     // DDR3 SDRAM: CAS Latency (Mode Register 0).
                                     // DDR2 SDRAM: CAS Latency (Mode Register).
   parameter CWL                   = 8,
                                     // in number of clock cycles
                                     // DDR3 SDRAM: CAS Write Latency (Mode Register 2).
                                     // DDR2 SDRAM: Can be ignored
   parameter OUTPUT_DRV            = "HIGH",
                                     // Output Driver Impedance Control (Mode Register 1).
                                     // # = "HIGH" - RZQ/7,
                                     //   = "LOW" - RZQ/6.
   parameter RTT_NOM               = "40",
                                     // RTT_NOM (ODT) (Mode Register 1).
                                     //   = "120" - RZQ/2,
                                     //   = "60"  - RZQ/4,
                                     //   = "40"  - RZQ/6.
   parameter RTT_WR                = "OFF",
                                     // RTT_WR (ODT) (Mode Register 2).
                                     // # = "OFF" - Dynamic ODT off,
                                     //   = "120" - RZQ/2,
                                     //   = "60"  - RZQ/4,
   parameter ADDR_CMD_MODE         = "1T" ,
                                     // # = "1T", "2T".
   parameter REG_CTRL              = "OFF",
                                     // # = "ON" - RDIMMs,
                                     //   = "OFF" - Components, SODIMMs, UDIMMs.
   parameter CA_MIRROR             = "OFF",
                                     // C/A mirror opt for DDR3 dual rank
   
   //***************************************************************************
   // The following parameters are multiplier and divisor factors for PLLE2.
   // Based on the selected design frequency these parameters vary.
   //***************************************************************************
   parameter CLKIN_PERIOD          = 5000,
                                     // Input Clock Period
   parameter CLKFBOUT_MULT         = 8,
                                     // write PLL VCO multiplier
   parameter DIVCLK_DIVIDE         = 1,
                                     // write PLL VCO divisor
   parameter CLKOUT0_PHASE         = 337.5,
                                     // Phase for PLL output clock (CLKOUT0)
   parameter CLKOUT0_DIVIDE        = 2,
                                     // VCO output divisor for PLL output clock (CLKOUT0)
   parameter CLKOUT1_DIVIDE        = 2,
                                     // VCO output divisor for PLL output clock (CLKOUT1)
   parameter CLKOUT2_DIVIDE        = 32,
                                     // VCO output divisor for PLL output clock (CLKOUT2)
   parameter CLKOUT3_DIVIDE        = 8,
                                     // VCO output divisor for PLL output clock (CLKOUT3)

   //***************************************************************************
   // Memory Timing Parameters. These parameters varies based on the selected
   // memory part.
   //***************************************************************************
   parameter tCKE                  = 5000,
                                     // memory tCKE paramter in pS
   parameter tFAW                  = 30000,
                                     // memory tRAW paramter in pS.
   parameter tRAS                  = 35000,
                                     // memory tRAS paramter in pS.
   parameter tRCD                  = 13125,
                                     // memory tRCD paramter in pS.
   parameter tREFI                 = 7800000,
                                     // memory tREFI paramter in pS.
   parameter tRFC                  = 110000,
                                     // memory tRFC paramter in pS.
   parameter tRP                   = 13125,
                                     // memory tRP paramter in pS.
   parameter tRRD                  = 6000,
                                     // memory tRRD paramter in pS.
   parameter tRTP                  = 7500,
                                     // memory tRTP paramter in pS.
   parameter tWTR                  = 7500,
                                     // memory tWTR paramter in pS.
   parameter tZQI                  = 128_000_000,
                                     // memory tZQI paramter in nS.
   parameter tZQCS                 = 64,
                                     // memory tZQCS paramter in clock cycles.

   //***************************************************************************
   // Simulation parameters
   //***************************************************************************
   parameter SIM_BYPASS_INIT_CAL   = "OFF",
                                     // # = "OFF" -  Complete memory init &
                                     //              calibration sequence
                                     // # = "SKIP" - Not supported
                                     // # = "FAST" - Complete memory init & use
                                     //              abbreviated calib sequence

   parameter SIMULATION            = "FALSE",
                                     // Should be TRUE during design simulations and
                                     // FALSE during implementations

   //***************************************************************************
   // The following parameters varies based on the pin out entered in MIG GUI.
   // Do not change any of these parameters directly by editing the RTL.
   // Any changes required should be done through GUI and the design regenerated.
   //***************************************************************************
   parameter BYTE_LANES_B0         = 4'b1111,
                                     // Byte lanes used in an IO column.
   parameter BYTE_LANES_B1         = 4'b0111,
                                     // Byte lanes used in an IO column.
   parameter BYTE_LANES_B2         = 4'b1111,
                                     // Byte lanes used in an IO column.
   parameter BYTE_LANES_B3         = 4'b0000,
                                     // Byte lanes used in an IO column.
   parameter BYTE_LANES_B4         = 4'b0000,
                                     // Byte lanes used in an IO column.
   parameter DATA_CTL_B0           = 4'b1111,
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
   parameter DATA_CTL_B1           = 4'b0000,
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
   parameter DATA_CTL_B2           = 4'b1111,
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
   parameter DATA_CTL_B3           = 4'b0000,
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
   parameter DATA_CTL_B4           = 4'b0000,
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
   parameter PHY_0_BITLANES        = 48'h3FE_3FE_3FE_2FF,
   parameter PHY_1_BITLANES        = 48'h000_CB0_473_FFF,
   parameter PHY_2_BITLANES        = 48'h3FE_3FE_3FE_2FF,

   // control/address/data pin mapping parameters
   parameter CK_BYTE_MAP
     = 144'h00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_11,
   parameter ADDR_MAP
     = 192'h000_000_111_110_109_108_107_106_10B_10A_105_104_103_102_101_100,
   parameter BANK_MAP   = 36'h11A_115_114,
   parameter CAS_MAP    = 12'h12A,
   parameter CKE_ODT_BYTE_MAP = 8'h00,
   parameter CKE_MAP    = 96'h000_000_000_000_000_000_000_116,
   parameter ODT_MAP    = 96'h000_000_000_000_000_000_000_127,
   parameter CS_MAP     = 120'h000_000_000_000_000_000_000_000_000_12B,
   parameter PARITY_MAP = 12'h000,
   parameter RAS_MAP    = 12'h125,
   parameter WE_MAP     = 12'h124,
   parameter DQS_BYTE_MAP
     = 144'h00_00_00_00_00_00_00_00_00_00_03_02_01_00_23_22_21_20,
   parameter DATA0_MAP  = 96'h200_209_206_203_204_205_202_207,
   parameter DATA1_MAP  = 96'h219_218_214_215_217_212_216_213,
   parameter DATA2_MAP  = 96'h225_224_229_226_223_222_228_227,
   parameter DATA3_MAP  = 96'h238_236_234_233_235_237_232_239,
   parameter DATA4_MAP  = 96'h005_003_000_009_007_006_004_002,
   parameter DATA5_MAP  = 96'h013_012_018_019_015_014_017_016,
   parameter DATA6_MAP  = 96'h023_027_022_029_024_025_028_026,
   parameter DATA7_MAP  = 96'h039_037_033_032_035_034_038_036,
   parameter DATA8_MAP  = 96'h000_000_000_000_000_000_000_000,
   parameter DATA9_MAP  = 96'h000_000_000_000_000_000_000_000,
   parameter DATA10_MAP = 96'h000_000_000_000_000_000_000_000,
   parameter DATA11_MAP = 96'h000_000_000_000_000_000_000_000,
   parameter DATA12_MAP = 96'h000_000_000_000_000_000_000_000,
   parameter DATA13_MAP = 96'h000_000_000_000_000_000_000_000,
   parameter DATA14_MAP = 96'h000_000_000_000_000_000_000_000,
   parameter DATA15_MAP = 96'h000_000_000_000_000_000_000_000,
   parameter DATA16_MAP = 96'h000_000_000_000_000_000_000_000,
   parameter DATA17_MAP = 96'h000_000_000_000_000_000_000_000,
   parameter MASK0_MAP  = 108'h000_031_021_011_001_231_221_211_201,
   parameter MASK1_MAP  = 108'h000_000_000_000_000_000_000_000_000,

   parameter SLOT_0_CONFIG         = 8'b0000_0001,
                                     // Mapping of Ranks.
   parameter SLOT_1_CONFIG         = 8'b0000_0000,
                                     // Mapping of Ranks.

   //***************************************************************************
   // IODELAY and PHY related parameters
   //***************************************************************************
   parameter IODELAY_HP_MODE       = "ON",
                                     // to phy_top
   parameter IBUF_LPWR_MODE        = "OFF",
                                     // to phy_top
   parameter DATA_IO_IDLE_PWRDWN   = "ON",
                                     // # = "ON", "OFF"
   parameter BANK_TYPE             = "HP_IO",
                                     // # = "HP_IO", "HPL_IO", "HR_IO", "HRL_IO"
   parameter DATA_IO_PRIM_TYPE     = "HP_LP",
                                     // # = "HP_LP", "HR_LP", "DEFAULT"
   parameter CKE_ODT_AUX           = "FALSE",
   parameter USER_REFRESH          = "OFF",
   parameter WRLVL                 = "ON",
                                     // # = "ON" - DDR3 SDRAM
                                     //   = "OFF" - DDR2 SDRAM.
   parameter ORDERING              = "NORM",
                                     // # = "NORM", "STRICT", "RELAXED".
   parameter CALIB_ROW_ADD         = 16'h0000,
                                     // Calibration row address will be used for
                                     // calibration read and write operations
   parameter CALIB_COL_ADD         = 12'h000,
                                     // Calibration column address will be used for
                                     // calibration read and write operations
   parameter CALIB_BA_ADD          = 3'h0,
                                     // Calibration bank address will be used for
                                     // calibration read and write operations
   parameter TCQ                   = 100,
   parameter IODELAY_GRP           = "IODELAY_MIG",
                                     // It is associated to a set of IODELAYs with
                                     // an IDELAYCTRL that have same IODELAY CONTROLLER
                                     // clock frequency.
   parameter SYSCLK_TYPE           = "DIFFERENTIAL",
                                     // System clock type DIFFERENTIAL, SINGLE_ENDED,
                                     // NO_BUFFER
   parameter REFCLK_TYPE           = "USE_SYSTEM_CLOCK",
                                     // Reference clock type DIFFERENTIAL, SINGLE_ENDED,
                                     // NO_BUFFER, USE_SYSTEM_CLOCK
   parameter SYS_RST_PORT          = "FALSE",
                                     // "TRUE" - if pin is selected for sys_rst
                                     //          and IBUF will be instantiated.
                                     // "FALSE" - if pin is not selected for sys_rst
      
   parameter DRAM_TYPE             = "DDR3",
   parameter CAL_WIDTH             = "HALF",
   parameter STARVE_LIMIT          = 2,
                                     // # = 2,3,4.

   //***************************************************************************
   // Referece clock frequency parameters
   //***************************************************************************
   parameter REFCLK_FREQ           = 200.0,
                                     // IODELAYCTRL reference clock frequency
   parameter DIFF_TERM_REFCLK      = "TRUE",
                                     // Differential Termination for idelay
                                     // reference clock input pins
   //***************************************************************************
   // System clock frequency parameters
   //***************************************************************************
   parameter tCK                   = 1250,
                                     // memory tCK paramter.
                                     // # = Clock Period in pS.
   parameter nCK_PER_CLK           = 4,
                                     // # of memory CKs per fabric CLK
   parameter DIFF_TERM_SYSCLK      = "FALSE",
                                     // Differential Termination for System
                                     // clock input pins

   

   //***************************************************************************
   // Debug parameters
   //***************************************************************************
   parameter DEBUG_PORT            = "ON",
                                     // # = "ON" Enable debug signals/controls.
                                     //   = "OFF" Disable debug signals/controls.

   //***************************************************************************
   // Temparature monitor parameter
   //***************************************************************************
   parameter TEMP_MON_CONTROL                          = "INTERNAL",
                                     // # = "INTERNAL", "EXTERNAL"
      
   parameter RST_ACT_LOW           = 0   // modification
                                     // =1 for active low reset,
                                     // =0 for active high.
   )
  (

   // Inouts
   inout [DQ_WIDTH-1:0]                         ddr3_dq,
   inout [DQS_WIDTH-1:0]                        ddr3_dqs_n,
   inout [DQS_WIDTH-1:0]                        ddr3_dqs_p,

   // Outputs
   output [ROW_WIDTH-1:0]                       ddr3_addr,
   output [BANK_WIDTH-1:0]                      ddr3_ba,
   output                                       ddr3_ras_n,
   output                                       ddr3_cas_n,
   output                                       ddr3_we_n,
   output                                       ddr3_reset_n,
   output [CK_WIDTH-1:0]                        ddr3_ck_p,
   output [CK_WIDTH-1:0]                        ddr3_ck_n,
   output [CKE_WIDTH-1:0]                       ddr3_cke,
   output [CS_WIDTH*nCS_PER_RANK-1:0]           ddr3_cs_n,
   output [DM_WIDTH-1:0]                        ddr3_dm,
   output [ODT_WIDTH-1:0]                       ddr3_odt,

   // Inputs
   // Differential system clocks
   input                                        sys_clk_p,
   input                                        sys_clk_n,
   
   
   //output                                       tg_compare_error,
   //output                                       init_calib_complete,
   
      
   output [3:0]                                 led,
   // System reset - Default polarity of sys_rst pin is Active Low.
   // System reset polarity will change based on the option 
   // selected in GUI.
   input                                        sys_rst
   );

function integer clogb2 (input integer size);
    begin
      size = size - 1;
      for (clogb2=1; size>1; clogb2=clogb2+1)
        size = size >> 1;
    end
  endfunction // clogb2

  function integer STR_TO_INT;
    input [7:0] in;
    begin
      if(in == "8")
        STR_TO_INT = 8;
      else if(in == "4")
        STR_TO_INT = 4;
      else
        STR_TO_INT = 0;
    end
  endfunction


  localparam CMD_PIPE_PLUS1        = "ON";
                                     // add pipeline stage between MC and PHY
  localparam DATA_WIDTH            = 64;
  localparam ECC_WIDTH = (ECC == "OFF")?
                           0 : (DATA_WIDTH <= 4)?
                            4 : (DATA_WIDTH <= 10)?
                             5 : (DATA_WIDTH <= 26)?
                              6 : (DATA_WIDTH <= 57)?
                               7 : (DATA_WIDTH <= 120)?
                                8 : (DATA_WIDTH <= 247)?
                                 9 : 10;
  localparam ECC_TEST              = "OFF";
  localparam RANK_WIDTH = clogb2(RANKS);
  localparam DATA_BUF_OFFSET_WIDTH = 1;
  localparam MC_ERR_ADDR_WIDTH = ((CS_WIDTH == 1) ? 0 : RANK_WIDTH)
                                 + BANK_WIDTH + ROW_WIDTH + COL_WIDTH
                                 + DATA_BUF_OFFSET_WIDTH;
  localparam tPRDI                 = 1_000_000;
                                     // memory tPRDI paramter in pS.
  localparam PAYLOAD_WIDTH         = (ECC_TEST == "OFF") ? DATA_WIDTH : DQ_WIDTH;
  localparam BURST_LENGTH          = STR_TO_INT(BURST_MODE);
  localparam APP_DATA_WIDTH        = 2 * nCK_PER_CLK * PAYLOAD_WIDTH;
  localparam APP_MASK_WIDTH        = APP_DATA_WIDTH / 8;

  //***************************************************************************
  // Traffic Gen related parameters (derived)
  //***************************************************************************
  localparam  TG_ADDR_WIDTH = ((CS_WIDTH == 1) ? 0 : RANK_WIDTH)
                                 + BANK_WIDTH + ROW_WIDTH + COL_WIDTH;
  localparam MASK_SIZE             = DATA_WIDTH/8;
      

  // Wire declarations
      
  wire [2*nCK_PER_CLK-1:0]              app_ecc_multiple_err;
  wire [ADDR_WIDTH-1:0]                 app_addr;
  wire [2:0]                            app_cmd;
  wire                                  app_en;
  wire                                  app_rdy;
  wire [APP_DATA_WIDTH-1:0]             app_rd_data;
  wire                                  app_rd_data_end;
  wire                                  app_rd_data_valid;
  wire [APP_DATA_WIDTH-1:0]             app_wdf_data;
  wire                                  app_wdf_end;
  wire [APP_MASK_WIDTH-1:0]             app_wdf_mask;
  wire                                  app_wdf_rdy;
  wire                                  app_sr_req;
  wire                                  app_sr_active;
  wire                                  app_ref_req;
  wire                                  app_ref_ack;
  wire                                  app_zq_req;
  wire                                  app_zq_ack;
  wire                                  app_wdf_wren;
  wire [64 + (2*APP_DATA_WIDTH - 1):0]      error_status;
  wire [PAYLOAD_WIDTH/8 - 1:0] cumlative_dq_lane_error;
  wire                                  mem_pattern_init_done;
  wire                                  modify_enable_sel;
  wire [2:0]                            data_mode_manual_sel;
  wire [2:0]                            addr_mode_manual_sel;
  wire [APP_DATA_WIDTH-1:0]             cmp_data;
  reg [63:0]                            cmp_data_r;
  wire                                  cmp_data_valid;
  reg                                   cmp_data_valid_r;
  wire                                  cmp_error;
  wire [47:0]                           wr_data_counts;
  wire [47:0]                           rd_data_counts;
  wire [PAYLOAD_WIDTH/8-1:0]            dq_error_bytelane_cmp;

  wire                                  clk;
  wire                                  rst;

  wire                                  vio_modify_enable;
  wire [3:0]                            vio_data_mode_value;
  wire                                  vio_pause_traffic;
  wire [2:0]                            vio_addr_mode_value;
  wire [3:0]                            vio_instr_mode_value;
  wire [1:0]                            vio_bl_mode_value;
  wire [9:0]                            vio_fixed_bl_value;
  wire [2:0]                            vio_fixed_instr_value;
  wire                                  vio_data_mask_gen;
  wire                                  vio_tg_rst;
  wire                                  dbg_sel_pi_incdec;
  wire                                  dbg_pi_f_inc;
  wire                                  dbg_pi_f_dec;
  wire                                  dbg_sel_po_incdec;
  wire                                  dbg_po_f_inc;
  wire                                  dbg_po_f_stg23_sel;
  wire                                  dbg_po_f_dec;
    // Debug port wire declarations
  wire [35:0]                           ddr3_ila_basic_control;
  wire [35:0]                           ddr3_ila_wrpath_control;
  wire [35:0]                           ddr3_ila_rdpath_control;
  wire [35:0]                           ddr3_vio_sync_out72_control;
  wire [35:0]                           ddr3_vio_sync_in_async_out_control;

  reg  [71:0]                           ddr3_vio_sync_out;
  wire [71:0]                           ddr3_vio_sync_out_w;

  wire [71:0]                           ddr3_vio_async_out;

  wire [255:0]                          ddr3_ila_basic_w;
  reg  [255:0]                          ddr3_ila_basic;
  reg  [63:0]                           ddr_ila_basic_rd_data;
  reg  [63:0]                           ddr_ila_basic_rd_data_r;
  wire [255:0]                          ddr3_ila_wrpath_w;
  reg  [255:0]                          ddr3_ila_wrpath;
  wire [1023:0]                         ddr3_ila_rdpath_w;
  reg  [1023:0]                         ddr3_ila_rdpath;

  wire [4:0]                            dbg_dqs;

  wire [127:0]                          ddr3_vio_sync_out_twm;
  (* keep = "true" *) wire [127:0]      ddr3_vio_async_in_twm /* synthesis syn_keep = 1 */;

  wire                                  win_start;
  wire                                  vio_win_byte_select_inc;
  wire                                  vio_win_byte_select_dec;
  wire [5:0]                            dbg_pi_counter_read_val;
  wire [8:0]                            dbg_po_counter_read_val;
  wire [5:0]                            pi_win_left_ram_out;
  wire [5:0]                            pi_win_right_ram_out;
  wire [8:0]                            po_win_left_ram_out;
  wire [8:0]                            po_win_right_ram_out;
  wire                                  win_clr_error;
  wire                                  manual_clear_error;

  wire                                  win_active;
  wire [3:0]                            vio_sel_mux_rdd;
  wire [6:0]                            win_current_bit;
  wire [3:0]                            win_current_byte;
  wire [63:0]                           dbg_win_chk;
  wire                                  pi_win_up;
  wire                                  pi_win_down;
  wire                                  po_win_up;
  wire                                  po_stg23_sel;
  wire                                  po_win_down;
  wire                                  po_win_tg_rst;

  reg                                   app_rd_data_valid_r1;
  reg                                   app_rd_data_valid_r2;
  reg                                   app_rd_data_valid_r3;
  reg [6:0]                             win_byte_select;
  reg [2*nCK_PER_CLK*PAYLOAD_WIDTH-1:0]      app_rd_data_r1;
  reg [2*nCK_PER_CLK*PAYLOAD_WIDTH-1:0]      app_rd_data_r2;
  reg [2*nCK_PER_CLK*PAYLOAD_WIDTH-1:0]      app_rd_data_r3;
  reg [DQS_CNT_WIDTH:0]                 dbg_byte_sel_r;
  reg [255:0]                           tg_simple_data;
  wire [1:0]                            vio_tg_simple_data_sel;
  wire                                  wdt_en_w;
  wire                                  cmd_wdt_err_w;
  wire                                  wr_wdt_err_w;
  wire                                  rd_wdt_err_w;
  wire                                  dbg_clear_error;

//***************************************************************************






      
// Start of User Design top instance
//***************************************************************************
// The User design is instantiated below. The memory interface ports are
// connected to the top-level and the application interface ports are
// connected to the traffic generator module. This provides a reference
// for connecting the memory controller to system.
//***************************************************************************

  ddr_test #
    (
     
     .TCQ                              (TCQ),
     .ADDR_CMD_MODE                    (ADDR_CMD_MODE),
     .AL                               (AL),
     .PAYLOAD_WIDTH                    (PAYLOAD_WIDTH),
     .BANK_WIDTH                       (BANK_WIDTH),
     .BURST_MODE                       (BURST_MODE),
     .BURST_TYPE                       (BURST_TYPE),
     .CA_MIRROR                        (CA_MIRROR),
     .CK_WIDTH                         (CK_WIDTH),
     .COL_WIDTH                        (COL_WIDTH),
     .CMD_PIPE_PLUS1                   (CMD_PIPE_PLUS1),
     .CS_WIDTH                         (CS_WIDTH),
     .nCS_PER_RANK                     (nCS_PER_RANK),
     .CKE_WIDTH                        (CKE_WIDTH),
     .DATA_WIDTH                       (DATA_WIDTH),
     .DATA_BUF_ADDR_WIDTH              (DATA_BUF_ADDR_WIDTH),
     .DQ_CNT_WIDTH                     (DQ_CNT_WIDTH),
     .DQ_PER_DM                        (DQ_PER_DM),
     .DQ_WIDTH                         (DQ_WIDTH),
     .DQS_CNT_WIDTH                    (DQS_CNT_WIDTH),
     .DQS_WIDTH                        (DQS_WIDTH),
     .DRAM_WIDTH                       (DRAM_WIDTH),
     .ECC                              (ECC),
     .ECC_WIDTH                        (ECC_WIDTH),
     .ECC_TEST                         (ECC_TEST),
     .MC_ERR_ADDR_WIDTH                (MC_ERR_ADDR_WIDTH),
     .nAL                              (nAL),
     .nBANK_MACHS                      (nBANK_MACHS),
     .CKE_ODT_AUX                      (CKE_ODT_AUX),
     .ORDERING                         (ORDERING),
     .OUTPUT_DRV                       (OUTPUT_DRV),
     .IBUF_LPWR_MODE                   (IBUF_LPWR_MODE),
     .IODELAY_HP_MODE                  (IODELAY_HP_MODE),
     .DATA_IO_IDLE_PWRDWN              (DATA_IO_IDLE_PWRDWN),
     .BANK_TYPE                        (BANK_TYPE),
     .DATA_IO_PRIM_TYPE                (DATA_IO_PRIM_TYPE),
     .REG_CTRL                         (REG_CTRL),
     .RTT_NOM                          (RTT_NOM),
     .RTT_WR                           (RTT_WR),
     .CL                               (CL),
     .CWL                              (CWL),
     .tCKE                             (tCKE),
     .tFAW                             (tFAW),
     .tPRDI                            (tPRDI),
     .tRAS                             (tRAS),
     .tRCD                             (tRCD),
     .tREFI                            (tREFI),
     .tRFC                             (tRFC),
     .tRP                              (tRP),
     .tRRD                             (tRRD),
     .tRTP                             (tRTP),
     .tWTR                             (tWTR),
     .tZQI                             (tZQI),
     .tZQCS                            (tZQCS),
     .USER_REFRESH                     (USER_REFRESH),
     .WRLVL                            (WRLVL),
     .DEBUG_PORT                       (DEBUG_PORT),
     .RANKS                            (RANKS),
     .ODT_WIDTH                        (ODT_WIDTH),
     .ROW_WIDTH                        (ROW_WIDTH),
     .ADDR_WIDTH                       (ADDR_WIDTH),
     .SIM_BYPASS_INIT_CAL              (SIM_BYPASS_INIT_CAL),
     .SIMULATION                       (SIMULATION),
     .BYTE_LANES_B0                    (BYTE_LANES_B0),
     .BYTE_LANES_B1                    (BYTE_LANES_B1),
     .BYTE_LANES_B2                    (BYTE_LANES_B2),
     .BYTE_LANES_B3                    (BYTE_LANES_B3),
     .BYTE_LANES_B4                    (BYTE_LANES_B4),
     .DATA_CTL_B0                      (DATA_CTL_B0),
     .DATA_CTL_B1                      (DATA_CTL_B1),
     .DATA_CTL_B2                      (DATA_CTL_B2),
     .DATA_CTL_B3                      (DATA_CTL_B3),
     .DATA_CTL_B4                      (DATA_CTL_B4),
     .PHY_0_BITLANES                   (PHY_0_BITLANES),
     .PHY_1_BITLANES                   (PHY_1_BITLANES),
     .PHY_2_BITLANES                   (PHY_2_BITLANES),
     .CK_BYTE_MAP                      (CK_BYTE_MAP),
     .ADDR_MAP                         (ADDR_MAP),
     .BANK_MAP                         (BANK_MAP),
     .CAS_MAP                          (CAS_MAP),
     .CKE_ODT_BYTE_MAP                 (CKE_ODT_BYTE_MAP),
     .CKE_MAP                          (CKE_MAP),
     .ODT_MAP                          (ODT_MAP),
     .CS_MAP                           (CS_MAP),
     .PARITY_MAP                       (PARITY_MAP),
     .RAS_MAP                          (RAS_MAP),
     .WE_MAP                           (WE_MAP),
     .DQS_BYTE_MAP                     (DQS_BYTE_MAP),
     .DATA0_MAP                        (DATA0_MAP),
     .DATA1_MAP                        (DATA1_MAP),
     .DATA2_MAP                        (DATA2_MAP),
     .DATA3_MAP                        (DATA3_MAP),
     .DATA4_MAP                        (DATA4_MAP),
     .DATA5_MAP                        (DATA5_MAP),
     .DATA6_MAP                        (DATA6_MAP),
     .DATA7_MAP                        (DATA7_MAP),
     .DATA8_MAP                        (DATA8_MAP),
     .DATA9_MAP                        (DATA9_MAP),
     .DATA10_MAP                       (DATA10_MAP),
     .DATA11_MAP                       (DATA11_MAP),
     .DATA12_MAP                       (DATA12_MAP),
     .DATA13_MAP                       (DATA13_MAP),
     .DATA14_MAP                       (DATA14_MAP),
     .DATA15_MAP                       (DATA15_MAP),
     .DATA16_MAP                       (DATA16_MAP),
     .DATA17_MAP                       (DATA17_MAP),
     .MASK0_MAP                        (MASK0_MAP),
     .MASK1_MAP                        (MASK1_MAP),
     .CALIB_ROW_ADD                    (CALIB_ROW_ADD),
     .CALIB_COL_ADD                    (CALIB_COL_ADD),
     .CALIB_BA_ADD                     (CALIB_BA_ADD),
     .SLOT_0_CONFIG                    (SLOT_0_CONFIG),
     .SLOT_1_CONFIG                    (SLOT_1_CONFIG),
     .MEM_ADDR_ORDER                   (MEM_ADDR_ORDER),
     .USE_CS_PORT                      (USE_CS_PORT),
     .USE_DM_PORT                      (USE_DM_PORT),
     .USE_ODT_PORT                     (USE_ODT_PORT),
     .PHY_CONTROL_MASTER_BANK          (PHY_CONTROL_MASTER_BANK),
     .TEMP_MON_CONTROL                 (TEMP_MON_CONTROL),
      
     
     .DM_WIDTH                         (DM_WIDTH),
     
     .nCK_PER_CLK                      (nCK_PER_CLK),
     .tCK                              (tCK),
     .DIFF_TERM_SYSCLK                 (DIFF_TERM_SYSCLK),
     .CLKIN_PERIOD                     (CLKIN_PERIOD),
     .CLKFBOUT_MULT                    (CLKFBOUT_MULT),
     .DIVCLK_DIVIDE                    (DIVCLK_DIVIDE),
     .CLKOUT0_PHASE                    (CLKOUT0_PHASE),
     .CLKOUT0_DIVIDE                   (CLKOUT0_DIVIDE),
     .CLKOUT1_DIVIDE                   (CLKOUT1_DIVIDE),
     .CLKOUT2_DIVIDE                   (CLKOUT2_DIVIDE),
     .CLKOUT3_DIVIDE                   (CLKOUT3_DIVIDE),
     
     .SYSCLK_TYPE                      (SYSCLK_TYPE),
     .REFCLK_TYPE                      (REFCLK_TYPE),
     .SYS_RST_PORT                     (SYS_RST_PORT),
     .REFCLK_FREQ                      (REFCLK_FREQ),
     .DIFF_TERM_REFCLK                 (DIFF_TERM_REFCLK),
     .IODELAY_GRP                      (IODELAY_GRP),
      
     .CAL_WIDTH                        (CAL_WIDTH),
     .STARVE_LIMIT                     (STARVE_LIMIT),
     .DRAM_TYPE                        (DRAM_TYPE),
      
      
     .RST_ACT_LOW                      (RST_ACT_LOW)
     )
    u_ddr_test
      (
       
       
// Memory interface ports
       .ddr3_addr                      (ddr3_addr),
       .ddr3_ba                        (ddr3_ba),
       .ddr3_cas_n                     (ddr3_cas_n),
       .ddr3_ck_n                      (ddr3_ck_n),
       .ddr3_ck_p                      (ddr3_ck_p),
       .ddr3_cke                       (ddr3_cke),
       .ddr3_ras_n                     (ddr3_ras_n),
       .ddr3_reset_n                   (ddr3_reset_n),
       .ddr3_we_n                      (ddr3_we_n),
       .ddr3_dq                        (ddr3_dq),
       .ddr3_dqs_n                     (ddr3_dqs_n),
       .ddr3_dqs_p                     (ddr3_dqs_p),
       .init_calib_complete            (init_calib_complete),
      
       .ddr3_cs_n                      (ddr3_cs_n),
       .ddr3_dm                        (ddr3_dm),
       .ddr3_odt                       (ddr3_odt),
// Application interface ports
       .app_addr                       (app_addr),
       .app_cmd                        (app_cmd),
       .app_en                         (app_en),
       .app_wdf_data                   (app_wdf_data),
       .app_wdf_end                    (app_wdf_end),
       .app_wdf_wren                   (app_wdf_wren),
       .app_rd_data                    (app_rd_data),
       .app_rd_data_end                (app_rd_data_end),
       .app_rd_data_valid              (app_rd_data_valid),
       .app_rdy                        (app_rdy),
       .app_wdf_rdy                    (app_wdf_rdy),
       .app_sr_req                     (1'b0),
       .app_sr_active                  (app_sr_active),
       .app_ref_req                    (1'b0),
       .app_ref_ack                    (app_ref_ack),
       .app_zq_req                     (1'b0),
       .app_zq_ack                     (app_zq_ack),
       .ui_clk                         (clk),
       .ui_clk_sync_rst                (rst),
      
       .app_wdf_mask                   (app_wdf_mask),
      
// Debug Ports
       .ddr3_ila_basic                 (ddr3_ila_basic_w[119:0]),
       .ddr3_ila_wrpath                (ddr3_ila_wrpath_w),
       .ddr3_ila_rdpath                (ddr3_ila_rdpath_w),

       .ddr3_vio_sync_out              (ddr3_vio_sync_out[35:0]),

       .dbg_pi_counter_read_val        (dbg_pi_counter_read_val),
       .dbg_sel_pi_incdec              (dbg_sel_pi_incdec),
       .dbg_po_counter_read_val        (dbg_po_counter_read_val),
       .dbg_sel_po_incdec              (dbg_sel_po_incdec),
       .dbg_byte_sel                   (dbg_byte_sel_r),
       .dbg_pi_f_inc                   (dbg_pi_f_inc),
       .dbg_pi_f_dec                   (dbg_pi_f_dec),
       .dbg_po_f_inc                   (dbg_po_f_inc),
       .dbg_po_f_stg23_sel             (dbg_po_f_stg23_sel),
       .dbg_po_f_dec                   (dbg_po_f_dec),
       
// System Clock Ports
       .sys_clk_p                       (sys_clk_p),
       .sys_clk_n                       (sys_clk_n),
      
       .sys_rst                        (sys_rst)
       );
// End of User Design top instance


//***************************************************************************
// The traffic generation module instantiated below drives traffic (patterns)
// on the application interface of the memory controller
//***************************************************************************

  mig_7series_v1_9_traffic_gen_top #
    (
     .TCQ                 (TCQ),
     .SIMULATION          (SIMULATION),
     .FAMILY              ("VIRTEX7"),
     .MEM_TYPE            (DRAM_TYPE),
     .TST_MEM_INSTR_MODE  (TST_MEM_INSTR_MODE),
     //.BL_WIDTH            (BL_WIDTH),
     .nCK_PER_CLK         (nCK_PER_CLK),
     .NUM_DQ_PINS         (PAYLOAD_WIDTH),
     .MEM_BURST_LEN       (BURST_LENGTH),
     .MEM_COL_WIDTH       (COL_WIDTH),
     .PORT_MODE           (PORT_MODE),
     .DATA_PATTERN        (DATA_PATTERN),
     .CMD_PATTERN         (CMD_PATTERN),
     .DATA_WIDTH          (APP_DATA_WIDTH),
     .ADDR_WIDTH          (TG_ADDR_WIDTH),
     .MASK_SIZE           (MASK_SIZE),
     .BEGIN_ADDRESS       (BEGIN_ADDRESS),
     .DATA_MODE           (DATA_MODE),
     .END_ADDRESS         (END_ADDRESS),
     .PRBS_EADDR_MASK_POS (PRBS_EADDR_MASK_POS),
     .SEL_VICTIM_LINE     (SEL_VICTIM_LINE),
     .CMD_WDT             (CMD_WDT),
     .RD_WDT              (RD_WDT),
     .WR_WDT              (WR_WDT),
     .EYE_TEST            (EYE_TEST)
     )
    u_traffic_gen_top
      (
       .clk                  (clk),
       .rst                  (rst),
       .tg_only_rst          (po_win_tg_rst | vio_tg_rst),
       .manual_clear_error   (manual_clear_error),
       .memc_init_done       (init_calib_complete),
       .memc_cmd_full        (~app_rdy),
       .memc_cmd_en          (app_en),
       .memc_cmd_instr       (app_cmd),
       .memc_cmd_bl          (),
       .memc_cmd_addr        (app_addr),
       .memc_wr_en           (app_wdf_wren),
       .memc_wr_end          (app_wdf_end),
       .memc_wr_mask         (app_wdf_mask),
       .memc_wr_data         (app_wdf_data),
       .memc_wr_full         (~app_wdf_rdy),
       .memc_rd_en           (),
       .memc_rd_data         (app_rd_data),
       .memc_rd_empty        (~app_rd_data_valid),
       .qdr_wr_cmd_o         (),
       .qdr_rd_cmd_o         (),
       .vio_pause_traffic    (vio_pause_traffic),
       .vio_modify_enable    (vio_modify_enable),
       .vio_data_mode_value  (vio_data_mode_value),
       .vio_addr_mode_value  (vio_addr_mode_value),
       .vio_instr_mode_value (vio_instr_mode_value),
       .vio_bl_mode_value    (vio_bl_mode_value),
       .vio_fixed_bl_value   (vio_fixed_bl_value),
       .vio_fixed_instr_value(vio_fixed_instr_value),
       .vio_data_mask_gen    (vio_data_mask_gen),
       .fixed_addr_i         (32'b0),
       .fixed_data_i         (32'b0),
       .simple_data0         (32'b0),
       .simple_data1         (32'b0),
       .simple_data2         (32'b0),
       .simple_data3         (32'b0),
       .simple_data4         (32'b0),
       .simple_data5         (32'b0),
       .simple_data6         (32'b0),
       .simple_data7         (32'b0),
       .wdt_en_i             (wdt_en_w),
       .bram_cmd_i           (39'b0),
       .bram_valid_i         (1'b0),
       .bram_rdy_o           (),
       .cmp_data             (cmp_data),
       .cmp_data_valid       (cmp_data_valid),
       .cmp_error            (cmp_error),
       .wr_data_counts       (wr_data_counts),
       .rd_data_counts       (rd_data_counts),
       .dq_error_bytelane_cmp (dq_error_bytelane_cmp),
       .error                (tg_compare_error),
       .error_status         (error_status),
       .cumlative_dq_lane_error (cumlative_dq_lane_error),
       .cmd_wdt_err_o         (cmd_wdt_err_w),
       .wr_wdt_err_o          (wr_wdt_err_w),
       .rd_wdt_err_o          (rd_wdt_err_w),
       .mem_pattern_init_done   (mem_pattern_init_done)
       );


 generate
    if (DEBUG_PORT=="ON") begin: CHIPSCOPE_INST

       assign dbg_dqs = ddr3_vio_sync_out[13:9];

       always @(posedge clk) begin
         cmp_data_valid_r  <= #TCQ cmp_data_valid;
         ddr_ila_basic_rd_data_r  <= #TCQ ddr_ila_basic_rd_data;
         if (cmp_data_valid_r) begin
           cmp_data_r[7:0]   <= #TCQ cmp_data[(8*dbg_dqs)+:8];
           cmp_data_r[15:8]  <= #TCQ cmp_data[(8*dbg_dqs)+PAYLOAD_WIDTH+:8];
           cmp_data_r[23:16] <= #TCQ cmp_data[(8*dbg_dqs)+2*PAYLOAD_WIDTH+:8];
           cmp_data_r[31:24] <= #TCQ cmp_data[(8*dbg_dqs)+3*PAYLOAD_WIDTH+:8];
           cmp_data_r[39:32] <= #TCQ (nCK_PER_CLK == 2 && DQ_WIDTH == 8) ? 8'h0 :
                                      cmp_data[(8*dbg_dqs)+4*PAYLOAD_WIDTH+:8];
           cmp_data_r[47:40] <= #TCQ (nCK_PER_CLK == 2 && DQ_WIDTH == 8) ? 8'h0 :
                                      cmp_data[(8*dbg_dqs)+5*PAYLOAD_WIDTH+:8];
           cmp_data_r[55:48] <= #TCQ (nCK_PER_CLK == 2 && DQ_WIDTH == 8) ? 8'h0 :
                                      cmp_data[(8*dbg_dqs)+6*PAYLOAD_WIDTH+:8];
           cmp_data_r[63:56] <= #TCQ (nCK_PER_CLK == 2 && DQ_WIDTH == 8) ? 8'h0 :
                                      cmp_data[(8*dbg_dqs)+7*PAYLOAD_WIDTH+:8];
           ddr_ila_basic_rd_data[7:0]   <= #TCQ app_rd_data_r2[(8*dbg_dqs)+:8];
           ddr_ila_basic_rd_data[15:8]  <= #TCQ app_rd_data_r2[(8*dbg_dqs)+PAYLOAD_WIDTH+:8];
           ddr_ila_basic_rd_data[23:16] <= #TCQ app_rd_data_r2[(8*dbg_dqs)+2*PAYLOAD_WIDTH+:8];
           ddr_ila_basic_rd_data[31:24] <= #TCQ app_rd_data_r2[(8*dbg_dqs)+3*PAYLOAD_WIDTH+:8];
           ddr_ila_basic_rd_data[39:32] <= #TCQ (nCK_PER_CLK == 2 && DQ_WIDTH == 8) ? 8'h0 :
                                              app_rd_data_r2[(8*dbg_dqs)+4*PAYLOAD_WIDTH+:8];
           ddr_ila_basic_rd_data[47:40] <= #TCQ (nCK_PER_CLK == 2 && DQ_WIDTH == 8) ? 8'h0 :
                                              app_rd_data_r2[(8*dbg_dqs)+5*PAYLOAD_WIDTH+:8];
           ddr_ila_basic_rd_data[55:48] <= #TCQ (nCK_PER_CLK == 2 && DQ_WIDTH == 8) ? 8'h0 :
                                              app_rd_data_r2[(8*dbg_dqs)+6*PAYLOAD_WIDTH+:8];
           ddr_ila_basic_rd_data[63:56] <= #TCQ (nCK_PER_CLK == 2 && DQ_WIDTH == 8) ? 8'h0 :
                                              app_rd_data_r2[(8*dbg_dqs)+7*PAYLOAD_WIDTH+:8];
         end else begin
       cmp_data_r <= #TCQ 'b0;
           ddr_ila_basic_rd_data  <= #TCQ 'b0;
         end
       end



       assign vio_modify_enable         = ddr3_vio_sync_out[36];
       assign vio_data_mode_value       = ddr3_vio_sync_out[40:37];
       assign vio_addr_mode_value       = ddr3_vio_sync_out[43:41];
       assign vio_instr_mode_value      = ddr3_vio_sync_out[47:44];
       assign vio_bl_mode_value         = ddr3_vio_sync_out[49:48];
       assign vio_fixed_bl_value        = ddr3_vio_sync_out[57:50];
       assign vio_data_mask_gen         = ddr3_vio_sync_out[58];
       assign vio_pause_traffic         = ddr3_vio_sync_out[59];
       assign vio_fixed_instr_value     = ddr3_vio_sync_out[62:60];
       assign dbg_clear_error           = ddr3_vio_sync_out[63];
       assign vio_tg_rst                = ddr3_vio_sync_out[64];
       assign wdt_en_w                  = ddr3_vio_sync_out[65];
       assign ddr3_ila_basic_w[124:120]   = 'b0;
       assign ddr3_ila_basic_w[125]       = cmd_wdt_err_w;
       assign ddr3_ila_basic_w[126]       = rd_wdt_err_w;
       assign ddr3_ila_basic_w[127]       = wr_wdt_err_w;
       assign ddr3_ila_basic_w[128]       = tg_compare_error;
       assign ddr3_ila_basic_w[129]       = cmp_data_valid_r;
       assign ddr3_ila_basic_w[130]       = cmp_error;
       assign ddr3_ila_basic_w[131+:64]   = cmp_data_r;
       assign ddr3_ila_basic_w[195+:9]    = dq_error_bytelane_cmp;
       assign ddr3_ila_basic_w[212:204]   = cumlative_dq_lane_error;
       assign ddr3_ila_basic_w[244:213]   = error_status[31:0];  // cmp_addr_i
       assign ddr3_ila_basic_w[250:245]   = error_status[37:32]; // cmp_bl_i
       assign ddr3_ila_basic_w[251]       = error_status[40];    // mcb_cmd_full_i
       assign ddr3_ila_basic_w[252]       = error_status[41];    // mcb_wr_full_i
       assign ddr3_ila_basic_w[253]       = error_status[42];    // mcb_rd_empty_i
       assign ddr3_ila_basic_w[255:254]   = ddr3_ila_rdpath[765:764];

       ddr_icon u_icon
         (
          .CONTROL0 (ddr3_ila_basic_control),
          .CONTROL1 (ddr3_ila_wrpath_control),
          .CONTROL2 (ddr3_ila_rdpath_control),
          .CONTROL3 (ddr3_vio_sync_out72_control),
          .CONTROL4 (ddr3_vio_sync_in_async_out_control)
          );

       ddr_ila_basic u_ddr_ila_basic
         (
          .CLK     (clk),
          .DATA    ({ddr3_ila_basic[255:93],ddr_ila_basic_rd_data_r,ddr3_ila_basic[28:0]}),
          .TRIG0   ({4'b0,ddr3_ila_basic[127:125],ddr3_ila_rdpath[765:764],ddr3_ila_basic[130],ddr3_ila_basic[21:0]}),
          .CONTROL (ddr3_ila_basic_control)
          );

       ddr_ila_wrpath u_ddr_ila_wrpath
         (
          .CLK     (clk),
          .DATA    (ddr3_ila_wrpath),
          .TRIG0   ({8'b00,ddr3_ila_rdpath[765:764],ddr3_ila_basic[21:0]}),
          .CONTROL (ddr3_ila_wrpath_control)
          );

       ddr_ila_rdpath u_ddr_ila_rdpath
         (
          .CLK     (clk),
          .DATA    (ddr3_ila_rdpath),
          .TRIG0   ({29'b0,ddr3_ila_rdpath[772:760],ddr3_ila_basic[21:0]}),
          .CONTROL (ddr3_ila_rdpath_control)
          );

       ddr_vio_sync_async_out72 u_ddr_vio_sync_async_out72
         (
          .SYNC_OUT (ddr3_vio_sync_out_w),
          .ASYNC_OUT(ddr3_vio_async_out),
          .CLK      (clk),
          .CONTROL  (ddr3_vio_sync_out72_control)
          );

          always @ (posedge clk or posedge rst)
          begin
            if (rst)
            begin
              ddr3_vio_sync_out <= 'b0;
              ddr3_ila_basic    <= 'b0;
              ddr3_ila_rdpath   <= 'b0;
              ddr3_ila_wrpath   <= 'b0;
            end
            else
            begin
              ddr3_vio_sync_out <= ddr3_vio_sync_out_w;
              ddr3_ila_basic    <= ddr3_ila_basic_w;
              ddr3_ila_rdpath   <= ddr3_ila_rdpath_w;
              ddr3_ila_wrpath   <= ddr3_ila_wrpath_w;
            end
          end

       ddr_vio_async_in_sync_out u_ddr_vio_async_in_sync_out
         (
          .ASYNC_IN  (ddr3_vio_async_in_twm),
          .SYNC_OUT  (ddr3_vio_sync_out_twm),
          .CLK       (clk),
          .CONTROL   (ddr3_vio_sync_in_async_out_control)
          );

       assign dbg_sel_pi_incdec  = (!win_active) ? ddr3_vio_sync_out_twm[2] : 1'b1;
       assign dbg_sel_po_incdec  = (!win_active) ? ddr3_vio_sync_out_twm[5] : 1'b1;
       assign manual_clear_error = (!win_active) ? dbg_clear_error : win_clr_error;
       assign dbg_pi_f_inc       = (!win_active) ? ddr3_vio_sync_out_twm[3] : pi_win_up;
       assign dbg_pi_f_dec       = (!win_active) ? ddr3_vio_sync_out_twm[4] : pi_win_down;
       assign dbg_po_f_inc       = (!win_active) ? ddr3_vio_sync_out_twm[6] : po_win_up;
       assign dbg_po_f_dec       = (!win_active) ? ddr3_vio_sync_out_twm[7] : po_win_down;
       assign dbg_po_f_stg23_sel= (!win_active) ?  ddr3_vio_sync_out_twm[10] : po_stg23_sel;
       assign win_start          = ddr3_vio_sync_out_twm[0];
       assign win_sel_pi_pon     = ddr3_vio_sync_out_twm[1];

       assign vio_win_byte_select_inc = ddr3_vio_sync_out_twm[8];
       assign vio_win_byte_select_dec = ddr3_vio_sync_out_twm[9];
       assign vio_sel_mux_rdd         = ddr3_vio_sync_out_twm[19:16];
       assign vio_tg_simple_data_sel  = ddr3_vio_sync_out_twm[21:20];

       assign ddr3_vio_async_in_twm [0]      = win_start;
       assign ddr3_vio_async_in_twm [6:1]    = 6'h0;
       assign ddr3_vio_async_in_twm [12:7]   = dbg_pi_counter_read_val;
       assign ddr3_vio_async_in_twm [18:13]  = pi_win_left_ram_out;
       assign ddr3_vio_async_in_twm [24:19]  = pi_win_right_ram_out;
       assign ddr3_vio_async_in_twm [25]     = win_active;
       assign ddr3_vio_async_in_twm [26+:32] = dbg_win_chk;
       assign ddr3_vio_async_in_twm [64:58]  = win_current_bit;
       assign ddr3_vio_async_in_twm [68:65]  = win_current_byte;
       assign ddr3_vio_async_in_twm [75:69]  = win_byte_select;
       assign ddr3_vio_async_in_twm [84:76]  = po_win_left_ram_out;
       assign ddr3_vio_async_in_twm [93:85]  = po_win_right_ram_out;
       assign ddr3_vio_async_in_twm [102:94] = dbg_po_counter_read_val;
       assign ddr3_vio_async_in_twm [103]    = mem_pattern_init_done;

       always @(posedge clk)
       begin
         app_rd_data_valid_r1  <= #TCQ app_rd_data_valid;
         app_rd_data_valid_r2  <= #TCQ app_rd_data_valid_r1;
         app_rd_data_valid_r3  <= #TCQ app_rd_data_valid_r2;
         app_rd_data_r1        <= app_rd_data;
         app_rd_data_r2        <= app_rd_data_r1;
         app_rd_data_r3        <= app_rd_data_r2;
       end

       always @(posedge clk)
         if (rst)
           win_byte_select <= #TCQ 'b0;
         else if (vio_win_byte_select_inc) begin
           if (win_byte_select == (DQ_WIDTH/DRAM_WIDTH))
             win_byte_select <= #TCQ 'b0;
           else
             win_byte_select <= #TCQ win_byte_select + 1;
         end else if (vio_win_byte_select_dec) begin
           if (win_byte_select == 0)
             win_byte_select <= #TCQ (DQ_WIDTH/DRAM_WIDTH) -1;
           else
             win_byte_select <= #TCQ win_byte_select - 1;
         end

       always @(posedge clk) begin
         if (rst)
           dbg_byte_sel_r <= #TCQ 'd0;
         else begin
           if (!win_active)
             dbg_byte_sel_r <= #TCQ vio_sel_mux_rdd;
           else
             dbg_byte_sel_r <= #TCQ win_current_byte;
         end
       end

       mig_7series_v1_9_chk_win #
         (
          .TCQ         (TCQ),
          .nCK_PER_CLK (nCK_PER_CLK),
          .DLY_WIDTH   (26),
          .DQ_PER_DQS  (DRAM_WIDTH),
          .DQ_WIDTH    (PAYLOAD_WIDTH),
          .SC_WIDTH    (3),
          .SDC_WIDTH   (5),
          .WIN_SIZE    (6),
          .SIM_OPTION  (SIMULATION)
          )
         u_chk_win
           (
            .clk                   (clk),
            .rst                   (rst),
            .mem_pattern_init_done (mem_pattern_init_done),
            .win_start             (win_start),
            .read_valid            (app_rd_data_valid_r2),
            .win_byte_select       (win_byte_select),
            .cmp_data              (cmp_data),
            .rd_data               (app_rd_data_r2),
            .win_sel_pi_pon        (win_sel_pi_pon),
            .pi_curr_tap_cnt       (dbg_pi_counter_read_val),
            .po_curr_tap_cnt       (dbg_po_counter_read_val),
            .pi_left_ram_out       (pi_win_left_ram_out),
            .pi_right_ram_out      (pi_win_right_ram_out),
            .po_left_ram_out       (po_win_left_ram_out),
            .po_right_ram_out      (po_win_right_ram_out),
            .win_active            (win_active),
            .win_clr_error         (win_clr_error),
            .pi_win_up             (pi_win_up),
            .pi_win_down           (pi_win_down),
            .po_win_up             (po_win_up),
            .po_stg23_sel          (po_stg23_sel),
            .po_win_down           (po_win_down),
            .po_win_tg_rst         (po_win_tg_rst),
            .win_current_bit       (win_current_bit),
            .win_current_byte      (win_current_byte),
            .dbg_clear_error       (dbg_clear_error),
            .dbg_win_chk           (dbg_win_chk)
            );

    end
    else begin: NO_CHIPSCOPE
       assign vio_modify_enable     = 1'b0;
       assign vio_data_mode_value   = 4'b0010;
       assign vio_addr_mode_value   = 3'b011;
       assign vio_instr_mode_value  = 4'b0010;
       assign vio_bl_mode_value     = 2'b10;
       assign vio_fixed_bl_value    = 'd16;
       assign vio_data_mask_gen     = 1'b0;
       assign vio_pause_traffic     = 1'b0;
       assign vio_fixed_instr_value = 3'b001;
       assign dbg_clear_error       = 1'b0;
       always @ ( * ) ddr3_vio_sync_out  = 72'b0;

       assign dbg_sel_pi_incdec       = 'b0;
       assign dbg_sel_po_incdec       = 'b0;
       assign manual_clear_error      = 'b0;
       assign dbg_pi_f_inc            = 'b0;
       assign dbg_pi_f_dec            = 'b0;
       assign dbg_po_f_inc            = 'b0;
       assign dbg_po_f_dec            = 'b0;
       assign dbg_po_f_stg23_sel      = 'b0;
       assign win_start               = 'b0;
       assign win_sel_pi_pon          = 'b0;

       assign vio_win_byte_select_inc = 'b0;
       assign vio_win_byte_select_dec = 'b0;
       assign vio_sel_mux_rdd         = 'b0;
       assign vio_tg_simple_data_sel  = 'b0;
       assign po_win_tg_rst           = 'b0;
       assign vio_tg_rst              = 'b0;
       assign wdt_en_w                = 'b1;


    end
 endgenerate

   //***************************************************************************
  // External display drivers
  //***************************************************************************
      
  led_display_driver u_led_display_driver
    (
     .rst            (rst),
     .clk            (clk),
     .clkdiv         (clk),
     .init_done_i    (init_calib_complete),
     .error_i        (tg_compare_error),
     .valid_i        (app_rd_data_valid),
     .seven_seg_n    (seven_seg_n),
     .seven_seg_dp_n (seven_seg_dp_n),
     .led            (led[3:0])
     );
      

endmodule
